import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../core/services/api_client.dart';
import '../../data/models/post.dart';
import '../bloc/community_bloc.dart';
import '../bloc/community_event.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback? onLike;
  final Function(String content)? onComment;
  final VoidCallback? onTap;

  const PostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onTap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _showCommentInput = false;
  final TextEditingController _commentController = TextEditingController();
  bool _isLikeLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _toggleCommentInput() {
    setState(() {
      _showCommentInput = !_showCommentInput;
      if (!_showCommentInput) {
        _commentController.clear();
      }
    });
  }

  void _submitComment() {
    final content = _commentController.text.trim();
    if (content.isNotEmpty && widget.onComment != null) {
      widget.onComment!(content);
      _commentController.clear();
      setState(() {
        _showCommentInput = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 6.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF1F6F8),
              Color(0xFFDDE9EE),
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12.r,
              offset: Offset(0, 5.h),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFB9CBD4),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Header with user info and timestamp
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                // User Avatar
                UserAvatar(
                  imageUrl: widget.post.userAvatar,
                  size: 40.w,
                  fallbackIcon: Icons.person,
                ),
                SizedBox(width: 12.w),
                // User name and timestamp
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.userName ?? 'Anonymous User',
                        style: AppTextStyles.onboardingBody.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF324B49),
                        ),
                      ),
                      Text(
                        _formatTimestamp(widget.post.createdAt),
                        style: AppTextStyles.onboardingBody.copyWith(
                          fontSize: 12.sp,
                          color: const Color(0xFFA1A1A1),
                        ),
                      ),
                    ],
                  ),
                ),
                // Three-dot menu for post owner
                if (ApiClient.instance.userId == widget.post.userId)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: const Color(0xFF324B49)),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditDialog(context);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(context);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20.sp, color: const Color(0xFF324B49)),
                            SizedBox(width: 8.w),
                            Text('Edit', style: AppTextStyles.onboardingBody.copyWith(fontSize: 14.sp)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20.sp, color: Colors.red),
                            SizedBox(width: 8.w),
                            Text('Delete', style: AppTextStyles.onboardingBody.copyWith(fontSize: 14.sp, color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Category Badge and Post Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    PostCategory.getLabel(widget.post.category),
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 10.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    widget.post.title,
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 18.sp,
                      color: const Color(0xFF324B49),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Post Content
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              widget.post.content,
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 14.sp,
                color: const Color(0xFF324B49),
                height: 1.5,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Images (if any)
          if (widget.post.imageUrls != null && widget.post.imageUrls!.isNotEmpty)
            Container(
              height: 200.h,
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: _buildPostImage(widget.post.imageUrls!.first),
              ),
            ),

          // Action Buttons
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                // Like Button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: widget.post.likesCount > 0
                        ? Colors.red.withOpacity(0.08)
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: const Color(0xFFCCD8DF)),
                  ),
                  child: InkWell(
                    onTap: _isLikeLoading
                        ? null
                        : () async {
                            if (widget.onLike != null) {
                              setState(() => _isLikeLoading = true);
                              widget.onLike!();
                              // Prevent rapid repeated likes
                              await Future.delayed(const Duration(seconds: 2));
                              if (mounted) {
                                setState(() => _isLikeLoading = false);
                              }
                            }
                          },
                    borderRadius: BorderRadius.circular(20.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      child: Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: _isLikeLoading
                                ? Colors.grey
                                : widget.post.likesCount > 0
                                    ? Colors.red
                                    : Colors.grey,
                            size: 20.w,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            '${widget.post.likesCount}',
                            style: AppTextStyles.onboardingBody.copyWith(
                              fontSize: 14.sp,
                              color: _isLikeLoading
                                  ? Colors.grey
                                  : widget.post.likesCount > 0
                                      ? Colors.red
                                      : Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 16.w),

                // Comment Button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: const Color(0xFFCCD8DF)),
                  ),
                  child: InkWell(
                    onTap: _toggleCommentInput,
                    borderRadius: BorderRadius.circular(20.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      child: Row(
                        children: [
                          Icon(
                            Icons.comment,
                            color: Colors.grey,
                            size: 20.w,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            '${widget.post.commentsCount}',
                            style: AppTextStyles.onboardingBody.copyWith(
                              fontSize: 14.sp,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),

          // Comment Input (shown when comment button is tapped)
          if (_showCommentInput)
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFFCCD8DF),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // User Avatar for comment
                  UserAvatar(
                    imageUrl: null,
                    size: 32.w,
                    fallbackIcon: Icons.person,
                  ),
                  SizedBox(width: 12.w),
                  // Comment Text Field
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        hintStyle: AppTextStyles.onboardingBody.copyWith(
                          fontSize: 14.sp,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.r),
                          borderSide: BorderSide(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1.w,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.r),
                          borderSide: BorderSide(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1.w,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.r),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 1.w,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                      ),
                      style: AppTextStyles.onboardingBody.copyWith(
                        fontSize: 14.sp,
                        color: const Color(0xFF324B49),
                      ),
                      maxLines: 3,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _submitComment(),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Submit Button
                  IconButton(
                    onPressed: _submitComment,
                    icon: Icon(
                      Icons.send,
                      color: AppColors.primary,
                      size: 24.w,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showEditDialog(BuildContext context) {
    final titleController = TextEditingController(text: widget.post.title);
    final contentController = TextEditingController(text: widget.post.content);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Edit Post', style: AppTextStyles.onboardingBody.copyWith(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF324B49),
        )),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: AppTextStyles.onboardingBody.copyWith(fontSize: 14.sp),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              style: AppTextStyles.onboardingBody.copyWith(fontSize: 14.sp),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: contentController,
              decoration: InputDecoration(
                labelText: 'Content',
                labelStyle: AppTextStyles.onboardingBody.copyWith(fontSize: 14.sp),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              style: AppTextStyles.onboardingBody.copyWith(fontSize: 14.sp),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: AppTextStyles.onboardingBody.copyWith(
              fontSize: 14.sp,
              color: Colors.grey,
            )),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final content = contentController.text.trim();
              if (title.isNotEmpty && content.isNotEmpty) {
                context.read<CommunityBloc>().add(
                  CommunityEvent.editPost(
                    postId: widget.post.id,
                    title: title,
                    content: content,
                  ),
                );
                Navigator.pop(dialogContext);
                CustomSnackbar.showSuccess(context, 'Post updated successfully!');
              } else {
                CustomSnackbar.showError(context, 'Please fill in all fields');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: Text('Save', style: AppTextStyles.onboardingBody.copyWith(
              fontSize: 14.sp,
              color: Colors.white,
            )),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete Post', style: AppTextStyles.onboardingBody.copyWith(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF324B49),
        )),
        content: Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
          style: AppTextStyles.onboardingBody.copyWith(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: AppTextStyles.onboardingBody.copyWith(
              fontSize: 14.sp,
              color: Colors.grey,
            )),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CommunityBloc>().add(
                CommunityEvent.deletePost(widget.post.id),
              );
              Navigator.pop(dialogContext);
              CustomSnackbar.showSuccess(context, 'Post deleted successfully!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: Text('Delete', style: AppTextStyles.onboardingBody.copyWith(
              fontSize: 14.sp,
              color: Colors.white,
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildPostImage(String imageUrl) {
    // Handle base64 data URLs
    if (imageUrl.startsWith('data:image/')) {
      try {
        final base64String = imageUrl.split(',').last;
        return Image.memory(
          const Base64Decoder().convert(base64String),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, size: 50),
          ),
        );
      } catch (e) {
        return Container(
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, size: 50),
        );
      }
    }
    
    // Handle regular URLs
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image, size: 50),
      ),
    );
  }
}
  