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
            Icon(
              Icons.chat_bubble_outline,
              size: 64.sp,
              color: AppColors.neutral400,
            ),
            SizedBox(height: 16.h),
            Text(
              'No chats yet',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Start a conversation with a vet',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
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
        padding: EdgeInsets.symmetric(vertical: 12.h),
        itemCount: chats.length,
        separatorBuilder: (context, index) => Divider(
          height: 1.h,
          color: AppColors.border,
        ),
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
        color: AppColors.error,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        child: Icon(Icons.delete, color: Colors.white, size: 28.sp),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Chat'),
            content: const Text('Are you sure you want to delete this chat?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        context.read<ChatBloc>().add(ChatEvent.deleteChat(chat.id));
      },
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        leading: UserAvatar(
          imageUrl: chat.otherUserPhoto,
          size: 56.w,
          showBorder: true,
        ),
        title: Text(
          chat.otherUserName ?? 'Chat',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: chat.lastMessage != null
            ? Text(
                chat.lastMessage!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: hasUnread ? AppColors.textPrimary : AppColors.textSecondary,
                  fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (chat.lastMessageAt != null)
              Text(
                timeago.format(chat.lastMessageAt!),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            if (hasUnread) ...[
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  unreadCount.toString(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
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
      ),
    );
  }
}
