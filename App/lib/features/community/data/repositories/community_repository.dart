import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../models/like.dart';

@injectable
class CommunityRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get _postsCollection => _firestore.collection('posts');
  CollectionReference get _commentsCollection => _firestore.collection('comments');
  CollectionReference get _likesCollection => _firestore.collection('likes');

  // Get current user
  User? get currentUser => _auth.currentUser;

  // POSTS OPERATIONS

  // Create a new post
  Future<Post> createPost({
    required String title,
    required String content,
    List<String>? imageUrls,
  }) async {
    if (currentUser == null) throw Exception('User not authenticated');

    final postId = _postsCollection.doc().id;
    final now = DateTime.now();

    // Fetch user display name from Firestore if not available
    String? displayName = currentUser!.displayName;
    if (displayName == null || displayName.isEmpty) {
      try {
        final userDoc = await _firestore.collection('users').doc(currentUser!.uid).get();
        if (userDoc.exists) {
          displayName = userDoc.data()?['displayName'] as String?;
        }
      } catch (e) {
        print('Error fetching user display name: $e');
      }
    }

    final post = Post(
      id: postId,
      userId: currentUser!.uid,
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
      userName: displayName ?? 'Anonymous User',
      userAvatar: currentUser!.photoURL,
      imageUrls: imageUrls,
      likesCount: 0,
      commentsCount: 0,
    );

    await _postsCollection.doc(postId).set(post.toJson());
    return post;
  }

  // Get posts stream with real-time updates
  Stream<List<Post>> getPostsStream({
    String sortBy = 'createdAt', // 'createdAt' or 'likesCount'
    bool descending = true,
  }) {
    Query query = _postsCollection;

    // Sort by specified field
    query = query.orderBy(sortBy, descending: descending);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Post.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Get posts by user
  Stream<List<Post>> getPostsByUser(String userId) {
    return _postsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Post.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Update post
  Future<void> updatePost(String postId, Map<String, dynamic> updates) async {
    await _postsCollection.doc(postId).update({
      ...updates,
      'updatedAt': Timestamp.now(),
    });
  }

  // Edit post (update title and/or content)
  Future<void> editPost({
    required String postId,
    String? title,
    String? content,
  }) async {
    if (currentUser == null) throw Exception('User not authenticated');

    final postDoc = await _postsCollection.doc(postId).get();
    if (!postDoc.exists) throw Exception('Post not found');

    final postData = postDoc.data() as Map<String, dynamic>;
    if (postData['userId'] != currentUser!.uid) {
      throw Exception('Not authorized to edit this post');
    }

    final updates = <String, dynamic>{};
    if (title != null) updates['title'] = title;
    if (content != null) updates['content'] = content;
    updates['updatedAt'] = Timestamp.now();

    await _postsCollection.doc(postId).update(updates);
  }

  // Delete post
  Future<void> deletePost(String postId) async {
    if (currentUser == null) throw Exception('User not authenticated');

    final postDoc = await _postsCollection.doc(postId).get();
    if (!postDoc.exists) throw Exception('Post not found');

    final postData = postDoc.data() as Map<String, dynamic>;
    if (postData['userId'] != currentUser!.uid) {
      throw Exception('Not authorized to delete this post');
    }

    // Delete all comments for this post
    final comments = await _commentsCollection
        .where('postId', isEqualTo: postId)
        .get();

    for (final comment in comments.docs) {
      await deleteComment(comment.id);
    }

    // Delete all likes for this post
    await _likesCollection
        .where('targetId', isEqualTo: postId)
        .where('targetType', isEqualTo: 'post')
        .get()
        .then((snapshot) {
      for (final doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    // Delete the post
    await _postsCollection.doc(postId).delete();
  }

  // LIKES OPERATIONS

  // Toggle like on post
  Future<bool> toggleLike(String postId) async {
    if (currentUser == null) throw Exception('User not authenticated');

    final likeId = '${currentUser!.uid}_$postId';
    final likeRef = _likesCollection.doc(likeId);

    final existingLike = await likeRef.get();

    if (existingLike.exists) {
      // Unlike
      await likeRef.delete();
      await _updatePostLikesCount(postId, -1);
      return false; // Not liked
    } else {
      // Like
      final like = Like(
        id: likeId,
        userId: currentUser!.uid,
        targetId: postId,
        targetType: 'post',
        createdAt: DateTime.now(),
      );
      await likeRef.set(like.toJson());
      await _updatePostLikesCount(postId, 1);
      return true; // Liked
    }
  }

  // Check if user liked a post
  Future<bool> hasUserLikedPost(String postId) async {
    if (currentUser == null) return false;

    final likeId = '${currentUser!.uid}_$postId';
    final likeDoc = await _likesCollection.doc(likeId).get();
    return likeDoc.exists;
  }

  // Update post likes count
  Future<void> _updatePostLikesCount(String postId, int change) async {
    final postRef = _postsCollection.doc(postId);
    await _firestore.runTransaction((transaction) async {
      final postDoc = await transaction.get(postRef);
      if (!postDoc.exists) return;

      final data = postDoc.data() as Map<String, dynamic>?;
      final currentLikes = data?['likesCount'] ?? 0;
      transaction.update(postRef, {'likesCount': currentLikes + change});
    });
  }

  // COMMENTS OPERATIONS

  // Add comment to post
  Future<Comment> addComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) async {
    if (currentUser == null) throw Exception('User not authenticated');

    final commentId = _commentsCollection.doc().id;
    final now = DateTime.now();

    // Fetch user display name from Firestore if not available
    String? displayName = currentUser!.displayName;
    if (displayName == null || displayName.isEmpty) {
      try {
        final userDoc = await _firestore.collection('users').doc(currentUser!.uid).get();
        if (userDoc.exists) {
          displayName = userDoc.data()?['displayName'] as String?;
        }
      } catch (e) {
        print('Error fetching user display name: $e');
      }
    }

    final comment = Comment(
      id: commentId,
      postId: postId,
      userId: currentUser!.uid,
      content: content,
      createdAt: now,
      userName: displayName ?? 'Anonymous User',
      userAvatar: currentUser!.photoURL,
      parentCommentId: parentCommentId,
      likesCount: 0,
      likedBy: [],
    );

    await _commentsCollection.doc(commentId).set(comment.toJson());

    // Update post comments count
    await _updatePostCommentsCount(postId, 1);

    return comment;
  }

  // Get comments for a post
  Stream<List<Comment>> getCommentsForPost(String postId) {
    return _commentsCollection
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .asyncMap((snapshot) async {
      final allComments = snapshot.docs.map((doc) {
        return Comment.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      // Build comment tree with nested replies
      return await _buildCommentTree(allComments);
    });
  }

  // Build comment tree with nested replies
  Future<List<Comment>> _buildCommentTree(List<Comment> allComments) async {
    final commentMap = <String, Comment>{};
    final rootComments = <Comment>[];

    // First pass: create map of all comments
    for (final comment in allComments) {
      commentMap[comment.id] = comment;
    }

    // Second pass: build the tree
    for (final comment in allComments) {
      if (comment.parentCommentId == null) {
        // Root comment - store reference to be updated later
        rootComments.add(comment);
      } else {
        // Reply - add to parent's replies
        final parent = commentMap[comment.parentCommentId];
        if (parent != null) {
          final currentReplies = parent.replies ?? [];
          final updatedParent = parent.copyWith(
            replies: [...currentReplies, comment],
          );
          commentMap[comment.parentCommentId!] = updatedParent;
          print('Added reply ${comment.id} to parent ${parent.id}, total replies: ${updatedParent.replies?.length}');
        } else {
          print('Parent comment ${comment.parentCommentId} not found for reply ${comment.id}');
        }
      }
    }

    // Update root comments with their updated versions from the map
    for (int i = 0; i < rootComments.length; i++) {
      final updatedComment = commentMap[rootComments[i].id];
      if (updatedComment != null) {
        rootComments[i] = updatedComment;
      }
    }

    print('Built comment tree with ${rootComments.length} root comments');
    for (final root in rootComments) {
      print('Root comment ${root.id} has ${root.replies?.length ?? 0} replies');
    }

    // Return only root comments (which now contain their nested replies)
    return rootComments;
  }

  // Get nested comments (replies)
  Future<List<Comment>> getNestedComments(String parentCommentId) async {
    final snapshot = await _commentsCollection
        .where('parentCommentId', isEqualTo: parentCommentId)
        .orderBy('createdAt', descending: false)
        .get();

    return snapshot.docs.map((doc) {
      return Comment.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  // Update comment
  Future<void> updateComment(String commentId, String newContent) async {
    await _commentsCollection.doc(commentId).update({
      'content': newContent,
      'updatedAt': Timestamp.now(),
    });
  }

  // Edit comment (with authorization check)
  Future<void> editComment({
    required String commentId,
    required String content,
  }) async {
    if (currentUser == null) throw Exception('User not authenticated');

    final commentDoc = await _commentsCollection.doc(commentId).get();
    if (!commentDoc.exists) throw Exception('Comment not found');

    final commentData = commentDoc.data() as Map<String, dynamic>;
    if (commentData['userId'] != currentUser!.uid) {
      throw Exception('Not authorized to edit this comment');
    }

    await _commentsCollection.doc(commentId).update({
      'content': content,
      'updatedAt': Timestamp.now(),
    });
  }

  // Delete comment and its replies
  Future<void> deleteComment(String commentId) async {
    if (currentUser == null) throw Exception('User not authenticated');

    final commentDoc = await _commentsCollection.doc(commentId).get();
    if (!commentDoc.exists) throw Exception('Comment not found');

    final commentData = commentDoc.data() as Map<String, dynamic>;
    if (commentData['userId'] != currentUser!.uid) {
      throw Exception('Not authorized to delete this comment');
    }

    // Delete nested replies
    final replies = await _commentsCollection
        .where('parentCommentId', isEqualTo: commentId)
        .get();

    for (final reply in replies.docs) {
      // Skip authorization check for nested deletes
      await _forceDeleteComment(reply.id);
    }

    // Delete likes for this comment
    await _likesCollection
        .where('targetId', isEqualTo: commentId)
        .where('targetType', isEqualTo: 'comment')
        .get()
        .then((snapshot) {
      for (final doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    // Get comment to update post count
    final comment = Comment.fromJson(commentData);
    await _updatePostCommentsCount(comment.postId, -1);

    // Delete the comment
    await _commentsCollection.doc(commentId).delete();
  }

  // Force delete comment without authorization (for cascading deletes)
  Future<void> _forceDeleteComment(String commentId) async {
    // Delete nested replies
    final replies = await _commentsCollection
        .where('parentCommentId', isEqualTo: commentId)
        .get();

    for (final reply in replies.docs) {
      await _forceDeleteComment(reply.id);
    }

    // Delete likes for this comment
    await _likesCollection
        .where('targetId', isEqualTo: commentId)
        .where('targetType', isEqualTo: 'comment')
        .get()
        .then((snapshot) {
      for (final doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    // Get comment to update post count
    final commentDoc = await _commentsCollection.doc(commentId).get();
    if (commentDoc.exists) {
      final comment = Comment.fromJson(commentDoc.data() as Map<String, dynamic>);
      await _updatePostCommentsCount(comment.postId, -1);
    }

    // Delete the comment
    await _commentsCollection.doc(commentId).delete();
  }

  // Update post comments count
  Future<void> _updatePostCommentsCount(String postId, int change) async {
    final postRef = _postsCollection.doc(postId);
    await _firestore.runTransaction((transaction) async {
      final postDoc = await transaction.get(postRef);
      if (!postDoc.exists) return;

      final data = postDoc.data() as Map<String, dynamic>?;
      final currentComments = data?['commentsCount'] ?? 0;
      transaction.update(postRef, {'commentsCount': currentComments + change});
    });
  }

  // Toggle like on comment
  Future<bool> toggleCommentLike(String commentId) async {
    if (currentUser == null) throw Exception('User not authenticated');

    final likeId = '${currentUser!.uid}_${commentId}_comment';
    final likeRef = _likesCollection.doc(likeId);

    final existingLike = await likeRef.get();

    if (existingLike.exists) {
      // Unlike
      await likeRef.delete();
      await _updateCommentLikesCount(commentId, -1, currentUser!.uid, false);
      return false;
    } else {
      // Like
      final like = Like(
        id: likeId,
        userId: currentUser!.uid,
        targetId: commentId,
        targetType: 'comment',
        createdAt: DateTime.now(),
      );
      await likeRef.set(like.toJson());
      await _updateCommentLikesCount(commentId, 1, currentUser!.uid, true);
      return true;
    }
  }

  // Update comment likes count
  Future<void> _updateCommentLikesCount(
    String commentId,
    int change,
    String userId,
    bool isAdding,
  ) async {
    final commentRef = _commentsCollection.doc(commentId);
    await _firestore.runTransaction((transaction) async {
      final commentDoc = await transaction.get(commentRef);
      if (!commentDoc.exists) return;

      final data = commentDoc.data() as Map<String, dynamic>;
      final currentLikes = data['likesCount'] ?? 0;
      final likedBy = List<String>.from(data['likedBy'] ?? []);

      if (isAdding) {
        likedBy.add(userId);
      } else {
        likedBy.remove(userId);
      }

      transaction.update(commentRef, {
        'likesCount': currentLikes + change,
        'likedBy': likedBy,
      });
    });
  }

  // Check if user liked a comment
  Future<bool> hasUserLikedComment(String commentId) async {
    if (currentUser == null) return false;

    final likeId = '${currentUser!.uid}_${commentId}_comment';
    final likeDoc = await _likesCollection.doc(likeId).get();
    return likeDoc.exists;
  }

  // Get user display name from Firestore users collection
  Future<String?> getUserDisplayName(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        return userData?['displayName'] as String?;
      }
      return null;
    } catch (e) {
      print('Error fetching user display name: $e');
      return null;
    }
  }
}