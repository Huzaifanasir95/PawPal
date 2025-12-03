import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/community_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/utils/image_service.dart';
import '../widgets/comment_widget.dart';
import '../widgets/post_card.dart'; // For FirestoreImage widget
import '../bloc/community_bloc.dart';
import '../bloc/community_event.dart';
import '../../data/models/post.dart';
import '../../data/models/comment.dart';
import '../../data/repositories/community_repository.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;

  const PostDetailPage({
    super.key,
    required this.post,
  });

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load comments for this post
    context.read<CommunityBloc>().add(
      CommunityEvent.loadComments(widget.post.id),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment() {
    final content = _commentController.text.trim();
    if (content.isNotEmpty) {
      context.read<CommunityBloc>().add(
        CommunityEvent.addComment(
          postId: widget.post.id,
          content: content,
        ),
      );
      _commentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.primary,
            size: 24.w,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Post Details',
          style: AppTextStyles.onboardingBody.copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF324B49),
          ),
        ),
      ),
      body: Column(
        children: [
          // Post Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post Card (without comment input)
                  _buildPostContent(),
                  SizedBox(height: 24.h),

                  // Comments Section
                  Text(
                    'Comments',
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF324B49),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Comments List
                  BlocBuilder<CommunityBloc, CommunityState>(
                    builder: (context, state) {
                      return state.when(
                        initial: () => const Center(child: CircularProgressIndicator()),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        loaded: (posts, comments, sortBy, descending, selectedPostId) {
                          if (comments.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 32.h),
                                child: Text(
                                  'No comments yet. Be the first to comment!',
                                  style: AppTextStyles.onboardingBody.copyWith(
                                    fontSize: 14.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            );
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final comment = comments[index];
                              return CommentWidget(
                                comment: comment,
                                onReply: (content) {
                                  context.read<CommunityBloc>().add(
                                    CommunityEvent.addComment(
                                      postId: widget.post.id,
                                      content: content,
                                      parentCommentId: comment.id,
                                    ),
                                  );
                                },
                                onLikeComment: (commentId) {
                                  context.read<CommunityBloc>().add(
                                    CommunityEvent.likeComment(commentId),
                                  );
                                },
                              );
                            },
                          );
                        },
                        error: (message) => Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 32.h),
                            child: Text(
                              'Error loading comments: $message',
                              style: AppTextStyles.onboardingBody.copyWith(
                                fontSize: 14.sp,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

          // Comment Input at Bottom
          _buildCommentInput(),
        ],
      ),
           )
       )
       ]
     ) );
  }

  Widget _buildPostContent() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info and timestamp
          Row(
            children: [
              // User Avatar
              CircleAvatar(
                radius: 20.r,
                backgroundColor: AppColors.primary,
                child: Text(
                  widget.post.userName?.isNotEmpty == true
                      ? widget.post.userName![0].toUpperCase()
                      : 'U',
                  style: AppTextStyles.onboardingBody.copyWith(
                    color: AppColors.surface,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
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
            ],
          ),

          SizedBox(height: 16.h),

          // Post Title
          Text(
            widget.post.title,
            style: AppTextStyles.onboardingBody.copyWith(
              fontSize: 20.sp,
              color: const Color(0xFF324B49),
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 12.h),

          // Post Content
          Text(
            widget.post.content,
            style: AppTextStyles.onboardingBody.copyWith(
              fontSize: 16.sp,
              color: const Color(0xFF324B49),
              height: 1.5,
            ),
          ),

          // Images (if any)
          if (widget.post.imageUrls != null && widget.post.imageUrls!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: Container(
                height: 250.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: FirestoreImage(
                    imageId: widget.post.imageUrls!.first,
                    height: 250.h,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

          SizedBox(height: 16.h),

          // Action Buttons (likes and comments count)
          Row(
            children: [
              // Like Button
              Row(
                children: [
                  Icon(
                    Icons.favorite,
                    color: widget.post.likesCount > 0 ? Colors.red : Colors.grey,
                    size: 20.w,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    '${widget.post.likesCount}',
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 14.sp,
                      color: widget.post.likesCount > 0 ? Colors.red : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              SizedBox(width: 24.w),

              // Comment Button
              Row(
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.primary.withOpacity(0.1),
            width: 1.w,
          ),
        ),
      ),
      child: Row(
        children: [
          // User Avatar for comment
          CircleAvatar(
            radius: 16.r,
            backgroundColor: AppColors.primary,
            child: Text(
              'U', // TODO: Use current user initial
              style: AppTextStyles.onboardingBody.copyWith(
                color: AppColors.surface,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
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
}