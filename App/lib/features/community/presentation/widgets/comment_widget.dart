import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/services/api_client.dart';
import '../../data/models/comment.dart';
import '../bloc/community_bloc.dart';
import '../bloc/community_event.dart';

class CommentWidget extends StatefulWidget {
  final Comment comment;
  final Function(String content)? onReply;
  final Function(String commentId)? onLikeComment;
  final int depth;

  const CommentWidget({
    super.key,
    required this.comment,
    this.onReply,
    this.onLikeComment,
    this.depth = 0,
  });

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  bool _showReplyInput = false;
  final TextEditingController _replyController = TextEditingController();
  bool _isLikeLoading = false;

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _toggleReplyInput() {
    setState(() {
      _showReplyInput = !_showReplyInput;
      if (!_showReplyInput) {
        _replyController.clear();
      }
    });
  }

  void _submitReply() {
    final content = _replyController.text.trim();
    if (content.isNotEmpty && widget.onReply != null) {
      widget.onReply!(content);
      _replyController.clear();
      setState(() {
        _showReplyInput = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxDepth = 3; // Limit nesting depth for better UX
    final shouldIndent = widget.depth < maxDepth;

    print('Building CommentWidget for comment ${widget.comment.id}, depth: ${widget.depth}, replies: ${widget.comment.replies?.length ?? 0}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Comment
        Container(
          margin: EdgeInsets.only(
            left: shouldIndent ? widget.depth * 32.w : 0,
            bottom: 8.h,
          ),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.1),
              width: 1.w,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Comment Header
              Row(
                children: [
                  // User Avatar
                  CircleAvatar(
                    radius: 14.r,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      widget.comment.userName?.isNotEmpty == true
                          ? widget.comment.userName![0].toUpperCase()
                          : 'U',
                      style: AppTextStyles.onboardingBody.copyWith(
                        color: AppColors.surface,
                        fontWeight: FontWeight.w600,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // User name and timestamp
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.comment.userName ?? 'Anonymous User',
                          style: AppTextStyles.onboardingBody.copyWith(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF324B49),
                          ),
                        ),
                        Text(
                          _formatTimestamp(widget.comment.createdAt),
                          style: AppTextStyles.onboardingBody.copyWith(
                            fontSize: 10.sp,
                            color: const Color(0xFFA1A1A1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Three-dot menu for comment owner
                  if (ApiClient.instance.userId == widget.comment.userId)
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, size: 16.sp, color: const Color(0xFF324B49)),
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
                              Icon(Icons.edit, size: 18.sp, color: const Color(0xFF324B49)),
                              SizedBox(width: 8.w),
                              Text('Edit', style: AppTextStyles.onboardingBody.copyWith(fontSize: 12.sp)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18.sp, color: Colors.red),
                              SizedBox(width: 8.w),
                              Text('Delete', style: AppTextStyles.onboardingBody.copyWith(fontSize: 12.sp, color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              SizedBox(height: 8.h),

              // Comment Content
              Text(
                widget.comment.content,
                style: AppTextStyles.onboardingBody.copyWith(
                  fontSize: 14.sp,
                  color: const Color(0xFF324B49),
                  height: 1.4,
                ),
              ),

              SizedBox(height: 8.h),

              // Action Buttons
              Row(
                children: [
                  // Like Button
                  InkWell(
                    onTap: _isLikeLoading ? null : () async {
                      if (widget.onLikeComment != null) {
                        setState(() => _isLikeLoading = true);
                        widget.onLikeComment!(widget.comment.id);
                        // Reset loading state after a longer delay to prevent spam
                        await Future.delayed(const Duration(seconds: 2));
                        if (mounted) {
                          setState(() => _isLikeLoading = false);
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(12.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      child: Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: _isLikeLoading 
                              ? Colors.grey 
                              : widget.comment.likesCount > 0 ? Colors.red : Colors.grey,
                            size: 14.w,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${widget.comment.likesCount}',
                            style: AppTextStyles.onboardingBody.copyWith(
                              fontSize: 12.sp,
                              color: widget.comment.likesCount > 0 ? Colors.red : Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(width: 16.w),

                  // Reply Button
                  if (widget.depth < maxDepth)
                    InkWell(
                      onTap: _toggleReplyInput,
                      borderRadius: BorderRadius.circular(12.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        child: Text(
                          'Reply',
                          style: AppTextStyles.onboardingBody.copyWith(
                            fontSize: 12.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // Reply Input (shown when reply button is tapped)
              if (_showReplyInput)
                Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: Row(
                    children: [
                      // User Avatar for reply
                      CircleAvatar(
                        radius: 12.r,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          'U', // TODO: Use current user initial
                          style: AppTextStyles.onboardingBody.copyWith(
                            color: AppColors.surface,
                            fontWeight: FontWeight.w600,
                            fontSize: 8.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // Reply Text Field
                      Expanded(
                        child: TextField(
                          controller: _replyController,
                          decoration: InputDecoration(
                            hintText: 'Write a reply...',
                            hintStyle: AppTextStyles.onboardingBody.copyWith(
                              fontSize: 12.sp,
                              color: Colors.grey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.r),
                              borderSide: BorderSide(
                                color: AppColors.primary.withOpacity(0.3),
                                width: 1.w,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.r),
                              borderSide: BorderSide(
                                color: AppColors.primary.withOpacity(0.3),
                                width: 1.w,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.r),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 1.w,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 8.h,
                            ),
                          ),
                          style: AppTextStyles.onboardingBody.copyWith(
                            fontSize: 12.sp,
                            color: const Color(0xFF324B49),
                          ),
                          maxLines: 2,
                          minLines: 1,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _submitReply(),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // Submit Button
                      IconButton(
                        onPressed: _submitReply,
                        icon: Icon(
                          Icons.send,
                          color: AppColors.primary,
                          size: 18.w,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // Nested Replies (if any)
        if (widget.comment.replies != null && widget.comment.replies!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(left: shouldIndent ? 32.w : 0),
            child: Column(
              children: widget.comment.replies!.map((reply) {
                return CommentWidget(
                  comment: reply,
                  onReply: widget.onReply != null
                      ? (content) => widget.onReply!(content)
                      : null,
                  onLikeComment: widget.onLikeComment,
                  depth: widget.depth + 1,
                );
              }).toList(),
            ),
          ),
      ],
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
    final contentController = TextEditingController(text: widget.comment.content);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Edit Comment', style: AppTextStyles.onboardingBody.copyWith(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF324B49),
        )),
        content: TextField(
          controller: contentController,
          decoration: InputDecoration(
            labelText: 'Comment',
            labelStyle: AppTextStyles.onboardingBody.copyWith(fontSize: 12.sp),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
          style: AppTextStyles.onboardingBody.copyWith(fontSize: 14.sp),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: AppTextStyles.onboardingBody.copyWith(
              fontSize: 12.sp,
              color: Colors.grey,
            )),
          ),
          ElevatedButton(
            onPressed: () {
              final content = contentController.text.trim();
              if (content.isNotEmpty) {
                context.read<CommunityBloc>().add(
                  CommunityEvent.editComment(
                    commentId: widget.comment.id,
                    content: content,
                  ),
                );
                Navigator.pop(dialogContext);
                CustomSnackbar.showSuccess(context, 'Comment updated successfully!');
              } else {
                CustomSnackbar.showError(context, 'Comment cannot be empty');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: Text('Save', style: AppTextStyles.onboardingBody.copyWith(
              fontSize: 12.sp,
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
        title: Text('Delete Comment', style: AppTextStyles.onboardingBody.copyWith(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF324B49),
        )),
        content: Text(
          'Are you sure you want to delete this comment? This action cannot be undone.',
          style: AppTextStyles.onboardingBody.copyWith(fontSize: 12.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: AppTextStyles.onboardingBody.copyWith(
              fontSize: 12.sp,
              color: Colors.grey,
            )),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CommunityBloc>().add(
                CommunityEvent.deleteComment(widget.comment.id),
              );
              Navigator.pop(dialogContext);
              CustomSnackbar.showSuccess(context, 'Comment deleted successfully!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: Text('Delete', style: AppTextStyles.onboardingBody.copyWith(
              fontSize: 12.sp,
              color: Colors.white,
            )),
          ),
        ],
      ),
    );
  }
}
