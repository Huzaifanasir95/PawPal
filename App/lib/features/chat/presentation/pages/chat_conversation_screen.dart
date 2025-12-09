import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/user_avatar.dart';
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
  StreamSubscription? _wsMessageSubscription;
  StreamSubscription? _wsConnectionSubscription;
  bool _isSending = false;
  bool _isConnected = false;
  bool _isLoadingMessages = true;
  Chat? _lastChat;
  List<ChatMessage> _lastMessages = [];

  @override
  void initState() {
    super.initState();
    // If we have user data passed from list, set it immediately
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
    
    // Connect WebSocket
    _connectWebSocket();
    
    // Load chat messages
    context.read<ChatBloc>().add(ChatEvent.loadChat(widget.chatId));
  }

  void _connectWebSocket() async {
    // Connect to WebSocket
    await _wsService.connect(widget.chatId);
    
    // Listen to connection status
    _wsConnectionSubscription = _wsService.connectionStream.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
          print('🔌 WebSocket connection status: $isConnected');
        });
      }
    });
    
    // Listen to incoming messages
    _wsMessageSubscription = _wsService.messageStream.listen((data) {
      final type = data['type'] as String?;
      
      if (type == 'new_message') {
        // New message received
        final messageData = data['message'] as Map<String, dynamic>;
        final newMessage = ChatMessage.fromJson(messageData);
        
        setState(() {
          _lastMessages = [..._lastMessages, newMessage];
        });
        
        // Scroll to bottom
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } else if (type == 'typing') {
        // Handle typing indicator
        final isTyping = data['isTyping'] as bool? ?? false;
        // You can show typing indicator UI here
        print('Other user is typing: $isTyping');
      }
    });
  }

  @override
  void dispose() {
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

    // Get current user ID
    final currentUserId = context.read<AuthBloc>().state.maybeWhen(
      authenticated: (user) => user.uid,
      orElse: () => '',
    );

    setState(() => _isSending = true);
    _messageController.clear();

    // Optimistic update - add message to UI immediately
    final tempMessage = ChatMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      chatId: widget.chatId,
      senderId: currentUserId,
      content: content,
      isRead: false,
      createdAt: DateTime.now(),
    );

    setState(() {
      _lastMessages = [..._lastMessages, tempMessage];
    });

    // Send the actual message
    context.read<ChatBloc>().add(ChatEvent.sendMessage(
      chatId: widget.chatId,
      content: content,
    ));

    // Scroll to bottom immediately
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
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        state.maybeWhen(
          error: (message) => CustomSnackbar.showError(context, message),
          messageSent: (_) {
            setState(() => _isSending = false);
            // Don't reload chat here - we already have optimistic update
          },
          chatLoaded: (chat, messages, hasMore, currentPage) {
            // Update cached messages only, keep passed user data
            setState(() {
              // If we have passed data, preserve it. Don't overwrite with API data
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
              // Replace temp messages with real ones
              _lastMessages = messages;
              _isSending = false;
              _isLoadingMessages = false; // Messages loaded
            });
          },
          orElse: () {},
        );
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: _lastChat != null
                ? Row(
                    children: [
                      UserAvatar(
                        imageUrl: _lastChat!.otherUserPhoto,
                        size: 40.r,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _lastChat!.otherUserName ?? 'User',
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2.h),
                            // Connection status - only show when both connected and messages loaded
                            if (_isConnected && !_isLoadingMessages)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: EdgeInsets.only(right: 6.w),
                                    decoration: BoxDecoration(
                                      color: Colors.greenAccent,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.greenAccent.withOpacity(0.5),
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'Connected',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.greenAccent,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Text(
                                'Connecting...',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white70,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person, size: 22, color: Colors.white70),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Loading...',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ],
                  ),
          ),
          body: state.when(
            initial: () => const Center(child: Text('Loading...')),
            loading: () {
              // Show loading indicator until messages are fully loaded
              if (_isLoadingMessages) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      SizedBox(height: 16.h),
                      Text(
                        'Loading messages...',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }
              // If we have cached data and loading is complete, show it
              if (_lastChat != null && _lastMessages.isNotEmpty) {
                return _buildChatView(_lastChat!, _lastMessages);
              }
              return const Center(child: CircularProgressIndicator());
            },
            chatsLoaded: (_) => const SizedBox(),
            chatLoaded: (chat, messages, hasMore, currentPage) {
              return _buildChatView(chat, messages);
            },
            chatStarted: (_) => const SizedBox(),
            messageSent: (_) {
              // Keep showing the cached chat view while message is being sent
              if (_lastChat != null) {
                return _buildChatView(_lastChat!, _lastMessages);
              }
              return const Center(child: CircularProgressIndicator());
            },
            messageMarkedAsRead: (_) {
              // Keep showing the cached chat view
              if (_lastChat != null) {
                return _buildChatView(_lastChat!, _lastMessages);
              }
              return const SizedBox();
            },
            chatDeleted: (_) => const SizedBox(),
            error: (message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
                  SizedBox(height: 16.h),
                  Text('Error loading chat', style: AppTextStyles.titleMedium),
                  SizedBox(height: 8.h),
                  Text(message, style: AppTextStyles.bodyMedium),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => context.read<ChatBloc>().add(ChatEvent.loadChat(widget.chatId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatView(Chat chat, List<ChatMessage> messages) {
    if (messages.isEmpty) {
      return Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64.sp,
                    color: AppColors.neutral400,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No messages yet',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Start the conversation',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildMessageInput(),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final isNextSameSender = index < messages.length - 1 &&
                  messages[index + 1].senderId == message.senderId;
              
              return _MessageBubble(
                message: message,
                showSenderInfo: !isNextSameSender,
              );
            },
          ),
        ),
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: AppColors.border.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: null,
                  minLines: 1,
                  maxLength: 1000,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(fontSize: 15.sp),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.6),
                      fontSize: 15.sp,
                    ),
                    filled: false,
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
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isSending
                      ? [Colors.grey.shade400, Colors.grey.shade500]
                      : [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isSending ? null : _sendMessage,
                  borderRadius: BorderRadius.circular(24.r),
                  child: Icon(
                    _isSending ? Icons.hourglass_empty : Icons.send_rounded,
                    color: Colors.white,
                    size: 22.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showSenderInfo;

  const _MessageBubble({
    required this.message,
    required this.showSenderInfo,
  });

  @override
  Widget build(BuildContext context) {
    // Get current user ID from auth state
    final currentUserId = context.read<AuthBloc>().state.maybeWhen(
      authenticated: (user) => user.uid,
      orElse: () => '',
    );
    
    final isSentByMe = message.senderId == currentUserId;
    return Padding(
      padding: EdgeInsets.only(bottom: showSenderInfo ? 12.h : 4.h),
      child: Row(
        mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isSentByMe) ...[
            UserAvatar(
              imageUrl: message.senderPhoto,
              size: 32.w,
            ),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isSentByMe ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.r),
                  topRight: Radius.circular(18.r),
                  bottomLeft: Radius.circular(isSentByMe ? 18.r : 4.r),
                  bottomRight: Radius.circular(isSentByMe ? 4.r : 18.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSentByMe ? AppColors.textOnPrimary : AppColors.textPrimary,
                      fontSize: 15.sp,
                      height: 1.4,
                    ),
                  ),
                  if (showSenderInfo) ...[
                    SizedBox(height: 4.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timeago.format(message.createdAt),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isSentByMe
                                ? AppColors.textOnPrimary.withOpacity(0.8)
                                : AppColors.textSecondary,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        if (isSentByMe) ...[
                          SizedBox(width: 5.w),
                          Icon(
                            message.isRead ? Icons.done_all : Icons.done,
                            size: 16.sp,
                            color: message.isRead
                                ? Color(0xFF4FC3F7)
                                : AppColors.textOnPrimary.withOpacity(0.7),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isSentByMe) SizedBox(width: 48.w), // For alignment
          if (!isSentByMe) SizedBox(width: 48.w), // For alignment
        ],
      ),
    );
  }
}
