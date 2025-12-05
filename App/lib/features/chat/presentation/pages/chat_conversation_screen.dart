import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../data/models/chat_model.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatConversationScreen extends StatefulWidget {
  final String chatId;

  const ChatConversationScreen({
    super.key,
    required this.chatId,
  });

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;
  Chat? _lastChat;
  List<ChatMessage> _lastMessages = [];

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(ChatEvent.loadChat(widget.chatId));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _messageController.clear();

    context.read<ChatBloc>().add(ChatEvent.sendMessage(
      chatId: widget.chatId,
      content: content,
    ));

    // Scroll to bottom after sending
    Future.delayed(const Duration(milliseconds: 300), () {
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18.r,
              backgroundColor: AppColors.surface,
              child: Icon(Icons.person, size: 20.sp, color: AppColors.primary),
            ),
            SizedBox(width: 12.w),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vet'),
                  // You could show online status here
                ],
              ),
            ),
          ],
        ),
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          state.maybeWhen(
            error: (message) => CustomSnackbar.showError(context, message),
            messageSent: (_) {
              setState(() => _isSending = false);
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: Text('Loading...')),
            loading: () {
              // If we have cached data, show it while loading
              if (_lastChat != null && _lastMessages.isNotEmpty) {
                return _buildChatView(_lastChat!, _lastMessages);
              }
              return const Center(child: CircularProgressIndicator());
            },
            chatsLoaded: (_) => const SizedBox(),
            chatLoaded: (chat, messages, hasMore, currentPage) {
              // Cache the latest chat state
              _lastChat = chat;
              _lastMessages = messages;
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
          );
        },
      ),
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
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            SizedBox(width: 12.w),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  _isSending ? Icons.hourglass_empty : Icons.send,
                  color: AppColors.textOnPrimary,
                  size: 22.sp,
                ),
                onPressed: _isSending ? null : _sendMessage,
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

  // For now, assuming current user is always sender
  // You'd need to get actual user ID from auth state
  bool get isSentByMe => true; // Replace with actual logic

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: showSenderInfo ? 12.h : 4.h),
      child: Row(
        mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isSentByMe) ...[
            CircleAvatar(
              radius: 16.r,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(Icons.person, size: 16.sp, color: AppColors.primary),
            ),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isSentByMe ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: Radius.circular(isSentByMe ? 16.r : 4.r),
                  bottomRight: Radius.circular(isSentByMe ? 4.r : 16.r),
                ),
                border: isSentByMe ? null : Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSentByMe ? AppColors.textOnPrimary : AppColors.textPrimary,
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
                                ? AppColors.textOnPrimary.withOpacity(0.7)
                                : AppColors.textSecondary,
                            fontSize: 11.sp,
                          ),
                        ),
                        if (isSentByMe) ...[
                          SizedBox(width: 4.w),
                          Icon(
                            message.isRead ? Icons.done_all : Icons.done,
                            size: 14.sp,
                            color: message.isRead
                                ? Colors.blue
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
