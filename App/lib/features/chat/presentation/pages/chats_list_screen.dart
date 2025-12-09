import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../data/models/chat_model.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import 'chat_conversation_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  // Cache the last loaded chats list
  List<Chat> _cachedChats = [];

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(const ChatEvent.loadChats());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: AppColors.primary,
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          state.maybeWhen(
            chatsLoaded: (chats) {
              // Cache the chats list
              setState(() {
                _cachedChats = chats;
              });
            },
            error: (message) => CustomSnackbar.showError(context, message),
            chatDeleted: (_) {
              CustomSnackbar.showSuccess(context, 'Chat deleted');
              context.read<ChatBloc>().add(const ChatEvent.loadChats());
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: Text('Loading...')),
            loading: () {
              // Show cached list if available while loading
              if (_cachedChats.isNotEmpty) {
                return _buildChatsList(_cachedChats);
              }
              return const Center(child: CircularProgressIndicator());
            },
            chatsLoaded: (chats) {
              return _buildChatsList(chats);
            },
            chatLoaded: (_, __, ___, ____) {
              // Show cached list when viewing a chat
              if (_cachedChats.isNotEmpty) {
                return _buildChatsList(_cachedChats);
              }
              return const SizedBox();
            },
            chatStarted: (_) {
              // Show cached list after starting a chat
              if (_cachedChats.isNotEmpty) {
                return _buildChatsList(_cachedChats);
              }
              return const SizedBox();
            },
            messageSent: (_) {
              // Show cached list when message is sent
              if (_cachedChats.isNotEmpty) {
                return _buildChatsList(_cachedChats);
              }
              return const SizedBox();
            },
            messageMarkedAsRead: (_) {
              // Show cached list when message is marked as read
              if (_cachedChats.isNotEmpty) {
                return _buildChatsList(_cachedChats);
              }
              return const SizedBox();
            },
            chatDeleted: (_) {
              // Show cached list after deletion
              if (_cachedChats.isNotEmpty) {
                return _buildChatsList(_cachedChats);
              }
              return const SizedBox();
            },
            error: (message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
                  SizedBox(height: 16.h),
                  Text('Error loading chats', style: AppTextStyles.titleMedium),
                  SizedBox(height: 8.h),
                  Text(message, style: AppTextStyles.bodyMedium),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => context.read<ChatBloc>().add(const ChatEvent.loadChats()),
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

  Widget _buildChatsList(List<Chat> chats) {
    if (chats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(32.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(
                Icons.forum_outlined,
                size: 72.sp,
                color: AppColors.primary.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'No conversations yet',
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Start chatting with vets to get expert advice',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ChatBloc>().add(const ChatEvent.loadChats());
      },
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        itemCount: chats.length,
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          return _ChatTile(chat: chats[index]);
        },
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final Chat chat;

  const _ChatTile({required this.chat});

  @override
  Widget build(BuildContext context) {
    final hasUnread = chat.unreadCountOwner > 0 || chat.unreadCountVet > 0;
    final unreadCount = chat.unreadCountOwner + chat.unreadCountVet;

    return Dismissible(
      key: Key(chat.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.symmetric(vertical: 0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade400, Colors.red.shade600],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_rounded, color: Colors.white, size: 28.sp),
            SizedBox(height: 4.h),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: Row(
              children: [
                Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 28.sp),
                SizedBox(width: 12.w),
                const Text('Delete Chat'),
              ],
            ),
            content: const Text('Are you sure you want to delete this conversation? This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        context.read<ChatBloc>().add(ChatEvent.deleteChat(chat.id));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: hasUnread 
                  ? AppColors.primary.withOpacity(0.15)
                  : Colors.black.withOpacity(0.05),
              blurRadius: hasUnread ? 12 : 8,
              offset: Offset(0, hasUnread ? 3 : 2),
            ),
          ],
          border: hasUnread 
              ? Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1.5,
                )
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatConversationScreen(
                    chatId: chat.id,
                    otherUserName: chat.otherUserName,
                    otherUserPhoto: chat.otherUserPhoto,
                  ),
                ),
              );
              // Reload chats when returning from conversation
              if (context.mounted) {
                context.read<ChatBloc>().add(const ChatEvent.loadChats());
              }
            },
            borderRadius: BorderRadius.circular(16.r),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Stack(
                    children: [
                      UserAvatar(
                        imageUrl: chat.otherUserPhoto,
                        size: 58.w,
                        showBorder: true,
                      ),
                      if (hasUnread)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 16.w,
                            height: 16.w,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                chat.otherUserName ?? 'Chat',
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                                  color: AppColors.textPrimary,
                                  fontSize: 16.sp,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            if (chat.lastMessageAt != null)
                              Text(
                                timeago.format(chat.lastMessageAt!),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: hasUnread 
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  fontSize: 12.sp,
                                  fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Expanded(
                              child: chat.lastMessage != null
                                  ? Text(
                                      chat.lastMessage!,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: hasUnread 
                                            ? AppColors.textPrimary 
                                            : AppColors.textSecondary,
                                        fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
                                        fontSize: 14.sp,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : Text(
                                      'No messages yet',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textSecondary.withOpacity(0.6),
                                        fontStyle: FontStyle.italic,
                                        fontSize: 13.sp,
                                      ),
                                    ),
                            ),
                            if (hasUnread) ...[
                              SizedBox(width: 12.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 5.h,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      Color(0xFF00ACC1),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(14.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  unreadCount.toString(),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
