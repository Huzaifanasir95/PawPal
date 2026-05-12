import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../../../core/services/chat_cache_service.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/services/websocket_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/models/chat_model.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatConversationScreen extends StatefulWidget {
  final String chatId;
  final String? otherUserName;
  final String? otherUserPhoto;

  const ChatConversationScreen({
    super.key,
    required this.chatId,
    this.otherUserName,
    this.otherUserPhoto,
  });

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _wsService = WebSocketService();
  final _chatCacheService = ChatCacheService();
  StreamSubscription? _wsMessageSubscription;
  StreamSubscription? _wsConnectionSubscription;
  Timer? _sendTimeoutTimer;
  bool _isSending = false;
  bool _isLoadingMessages = true;
  Chat? _lastChat;
  List<ChatMessage> _lastMessages = [];
  String? _pendingTempMessageId;
  String? _pendingMessageContent;

  @override
  void initState() {
    super.initState();
    _isLoadingMessages = true;
    _lastMessages = [];
    
    if (widget.otherUserName != null || widget.otherUserPhoto != null) {
      _lastChat = Chat(
        id: widget.chatId,
        petOwnerId: '',
        vetId: '',
        otherUserName: widget.otherUserName,
        otherUserPhoto: widget.otherUserPhoto,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
    
    _hydrateCachedConversation();
    _connectWebSocket();
    context.read<ChatBloc>().add(ChatEvent.loadChat(widget.chatId));
  }

  Future<void> _hydrateCachedConversation() async {
    final cachedThread = await _chatCacheService.readThread(widget.chatId);
    if (!mounted || cachedThread == null) {
      return;
    }

    setState(() {
      _lastChat = cachedThread.chat;
      _lastMessages = cachedThread.messages;
      _isLoadingMessages = false;
    });

    _scrollToBottom();
  }

  void _connectWebSocket() async {
    await _wsService.connect(widget.chatId);
    
    _wsConnectionSubscription = _wsService.connectionStream.listen((isConnected) {
      if (mounted) setState(() {});
    });
    
    _wsMessageSubscription = _wsService.messageStream.listen((data) {
      final type = data['type'] as String?;
      
      if (type == 'new_message') {
        final messageData = data['message'] as Map<String, dynamic>;
        final newMessage = ChatMessage.fromJson(messageData);

        if (!mounted) return;
        
        setState(() {
          if (_lastMessages.any((message) => message.id == newMessage.id)) {
            return;
          }

          final isMine = newMessage.senderId == _currentUserId;
          final matchesPending =
              isMine &&
              _pendingTempMessageId != null &&
              _pendingMessageContent != null &&
              newMessage.content.trim() == _pendingMessageContent!.trim();

          if (matchesPending) {
            _replacePendingMessage(newMessage);
            _isSending = false;
            _sendTimeoutTimer?.cancel();
          } else {
            _lastMessages = [..._lastMessages, newMessage];
          }
        });

        _persistConversationCache();
        
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _sendTimeoutTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    _wsMessageSubscription?.cancel();
    _wsConnectionSubscription?.cancel();
    _wsService.disconnect();
    super.dispose();
  }

  void _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending) return;

    final currentUserId = _currentUserId;
    if (currentUserId.isEmpty) {
      CustomSnackbar.showError(context, 'Please sign in before sending messages.');
      return;
    }

    final tempMessageId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final tempMessage = ChatMessage(
      id: tempMessageId,
      chatId: widget.chatId,
      senderId: currentUserId,
      content: content,
      isRead: false,
      createdAt: DateTime.now(),
    );

    _sendTimeoutTimer?.cancel();

    setState(() {
      _isSending = true;
      _pendingTempMessageId = tempMessageId;
      _pendingMessageContent = content;
      _lastMessages = [..._lastMessages, tempMessage];
    });

    _persistConversationCache();

    _messageController.clear();

    _sendTimeoutTimer = Timer(const Duration(seconds: 15), () {
      if (!mounted || !_isSending) return;
      setState(() {
        _isSending = false;
        _restoreFailedDraft();
      });
      CustomSnackbar.showError(
        context,
        'Message is taking longer than expected. Please retry.',
      );
    });

    context.read<ChatBloc>().add(
      ChatEvent.sendMessage(chatId: widget.chatId, content: content),
    );

    _scrollToBottom();
  }

  String get _currentUserId {
    return context.read<AuthBloc>().state.maybeWhen(
      authenticated: (user) => user.uid,
      orElse: () => '',
    );
  }

  void _replacePendingMessage(ChatMessage confirmedMessage) {
    final pendingId = _pendingTempMessageId;

    if (pendingId != null) {
      final pendingIndex = _lastMessages.indexWhere(
        (message) => message.id == pendingId,
      );

      if (pendingIndex >= 0) {
        final updated = List<ChatMessage>.from(_lastMessages);
        updated[pendingIndex] = confirmedMessage;
        _lastMessages = updated;
      } else if (!_lastMessages.any((message) => message.id == confirmedMessage.id)) {
        _lastMessages = [..._lastMessages, confirmedMessage];
      }
    } else if (!_lastMessages.any((message) => message.id == confirmedMessage.id)) {
      _lastMessages = [..._lastMessages, confirmedMessage];
    }

    _pendingTempMessageId = null;
    _pendingMessageContent = null;
  }

  Future<void> _persistConversationCache() async {
    final chat = _lastChat;
    if (chat == null) {
      return;
    }

    await _chatCacheService.writeThread(chat, _lastMessages);
  }

  void _restoreFailedDraft() {
    final pendingId = _pendingTempMessageId;
    if (pendingId == null) return;

    final pendingIndex = _lastMessages.indexWhere(
      (message) => message.id == pendingId,
    );

    if (pendingIndex >= 0) {
      final pendingMessage = _lastMessages[pendingIndex];
      final updated = List<ChatMessage>.from(_lastMessages)..removeAt(pendingIndex);
      _lastMessages = updated;

      if (_messageController.text.trim().isEmpty) {
        _messageController.text = pendingMessage.content;
        _messageController.selection = TextSelection.fromPosition(
          TextPosition(offset: _messageController.text.length),
        );
      }
    }

    _pendingTempMessageId = null;
    _pendingMessageContent = null;
  }

  List<ChatMessage> _mergeWithPendingMessages(List<ChatMessage> serverMessages) {
    if (_pendingTempMessageId == null) {
      return serverMessages;
    }

    ChatMessage? pendingMessage;
    for (final message in _lastMessages) {
      if (message.id == _pendingTempMessageId) {
        pendingMessage = message;
        break;
      }
    }

    if (pendingMessage == null) {
      return serverMessages;
    }

    final resolvedPending = pendingMessage;

    if (serverMessages.any((msg) => msg.id == resolvedPending.id)) {
      return serverMessages;
    }

    return [...serverMessages, resolvedPending];
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      ),
      child: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          state.maybeWhen(
            error: (message) {
              _sendTimeoutTimer?.cancel();
              setState(() {
                _isSending = false;
                _restoreFailedDraft();
              });
              CustomSnackbar.showError(context, message);
            },
            messageSent: (message) {
              _sendTimeoutTimer?.cancel();
              setState(() {
                _isSending = false;
                _replacePendingMessage(message);
              });
              _persistConversationCache();
              _scrollToBottom();
            },
            chatLoaded: (chat, messages, hasMore, currentPage) {
              setState(() {
                if (widget.otherUserName != null || widget.otherUserPhoto != null) {
                  _lastChat = Chat(
                    id: chat.id,
                    petOwnerId: chat.petOwnerId,
                    vetId: chat.vetId,
                    otherUserName: widget.otherUserName,
                    otherUserPhoto: widget.otherUserPhoto,
                    createdAt: chat.createdAt,
                    updatedAt: chat.updatedAt,
                  );
                } else {
                  _lastChat = chat;
                }
                _lastMessages = _mergeWithPendingMessages(messages);
                _isSending = false;
                _isLoadingMessages = false;
              });
              _persistConversationCache();
              _scrollToBottom();
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          final theme = Theme.of(context);
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(child: _buildBody(state)),
                  _buildMessageInput(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(8.w, 8.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: colorScheme.onSurface,
                size: 24.sp,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14.r),
              image: (_lastChat?.otherUserPhoto ?? widget.otherUserPhoto) != null
                  ? DecorationImage(
                      image: NetworkImage(_lastChat?.otherUserPhoto ?? widget.otherUserPhoto!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: (_lastChat?.otherUserPhoto ?? widget.otherUserPhoto) == null
                ? Center(
                    child: Icon(
                      Icons.person_rounded,
                      color: colorScheme.primary,
                      size: 26.sp,
                    ),
                  )
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _lastChat?.otherUserName ?? widget.otherUserName ?? 'Chat',
                  style: TextStyle(
                    fontSize: 17.sp,
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  'Tap for info',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              // TODO: Show options menu
            },
            child: Icon(
              Icons.more_vert_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 24.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ChatState state) {
    if (_isLoadingMessages && _lastMessages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
            SizedBox(height: 16.h),
            Text(
              'Loading messages...',
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return state.maybeWhen(
      error: (message) {
        if (_lastMessages.isNotEmpty) {
          return _buildMessagesList();
        }
        return _buildErrorState(message);
      },
      orElse: () => _buildMessagesList(),
    );
  }

  Widget _buildErrorState(String message) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64.sp,
              color: const Color(0xFFEF4444),
            ),
            SizedBox(height: 16.h),
            Text(
              'Error loading chat',
              style: TextStyle(
                fontSize: 18.sp,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            GestureDetector(
              onTap: () => context.read<ChatBloc>().add(ChatEvent.loadChat(widget.chatId)),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    final colorScheme = Theme.of(context).colorScheme;

    if (_lastMessages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 40.sp,
                color: colorScheme.primary,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'No messages yet',
              style: TextStyle(
                fontSize: 18.sp,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Start the conversation',
              style: TextStyle(
                fontSize: 14.sp,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      itemCount: _lastMessages.length,
      itemBuilder: (context, index) {
        final message = _lastMessages[index];
        final isLastInGroup = index == _lastMessages.length - 1 ||
            _lastMessages[index + 1].senderId != message.senderId;

        return _MessageBubble(
          message: message,
          showTime: isLastInGroup,
        );
      },
    );
  }

  Widget _buildMessageInput() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: null,
                minLines: 1,
                maxLength: 1000,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 15.sp,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                  counterText: '',
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: _isSending ? null : _sendMessage,
            child: Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: _isSending
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.primary,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Center(
                child: _isSending
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 22.sp,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showTime;

  const _MessageBubble({
    required this.message,
    required this.showTime,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentUserId = context.read<AuthBloc>().state.maybeWhen(
      authenticated: (user) => user.uid,
      orElse: () => '',
    );
    
    final isSentByMe = message.senderId == currentUserId;
    
    return Padding(
      padding: EdgeInsets.only(bottom: showTime ? 12.h : 4.h),
      child: Row(
        mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (isSentByMe) SizedBox(width: 60.w),
          Flexible(
            child: Column(
              crossAxisAlignment: isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isSentByMe ? colorScheme.primary : colorScheme.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r),
                      bottomLeft: Radius.circular(isSentByMe ? 20.r : 6.r),
                      bottomRight: Radius.circular(isSentByMe ? 6.r : 20.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color:
                          isSentByMe
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                      height: 1.4,
                    ),
                  ),
                ),
                if (showTime) ...[
                  SizedBox(height: 4.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timeago.format(message.createdAt),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (isSentByMe) ...[
                          SizedBox(width: 4.w),
                          Icon(
                            message.isRead ? Icons.done_all_rounded : Icons.done_rounded,
                            size: 14.sp,
                            color: message.isRead
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!isSentByMe) SizedBox(width: 60.w),
        ],
      ),
    );
  }
}

