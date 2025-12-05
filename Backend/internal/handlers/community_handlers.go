package handlers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"

	"pawpal-backend/internal/models"
	"pawpal-backend/internal/repositories"
)

// CommunityHandlers handles community endpoints
type CommunityHandlers struct {
	communityRepo *repositories.CommunityRepository
	userRepo      *repositories.UserRepository
}

// NewCommunityHandlers creates new CommunityHandlers
func NewCommunityHandlers(communityRepo *repositories.CommunityRepository, userRepo *repositories.UserRepository) *CommunityHandlers {
	return &CommunityHandlers{
		communityRepo: communityRepo,
		userRepo:      userRepo,
	}
}

// Post Endpoints

// CreatePost handles creating a new post
func (h *CommunityHandlers) CreatePost(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	
	var req models.CreatePostRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.PostResponse{
			Success: false,
			Message: "Invalid request: " + err.Error(),
		})
		return
	}

	// Get user info for the post
	user, err := h.userRepo.GetByID(c.Request.Context(), parseUUID(userID))
	if err != nil || user == nil {
		c.JSON(http.StatusInternalServerError, models.PostResponse{
			Success: false,
			Message: "Failed to get user info",
		})
		return
	}

	var userName string
	if user.DisplayName != nil {
		userName = *user.DisplayName
	} else {
		userName = "Anonymous User"
	}

	post := &models.Post{
		UserID:     parseUUID(userID),
		Title:      req.Title,
		Content:    req.Content,
		UserName:   &userName,
		UserAvatar: user.AvatarURL,
		ImageURLs:  req.ImageURLs,
	}

	if err := h.communityRepo.CreatePost(c.Request.Context(), post); err != nil {
		c.JSON(http.StatusInternalServerError, models.PostResponse{
			Success: false,
			Message: "Failed to create post: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, models.PostResponse{
		Success: true,
		Message: "Post created successfully",
		Post:    post,
	})
}

// GetPosts handles getting all posts with pagination
func (h *CommunityHandlers) GetPosts(c *gin.Context) {
	sortBy := c.DefaultQuery("sortBy", "created_at")
	descendingStr := c.DefaultQuery("descending", "true")
	limitStr := c.DefaultQuery("limit", "20")
	offsetStr := c.DefaultQuery("offset", "0")

	descending := descendingStr == "true"
	limit, _ := strconv.Atoi(limitStr)
	offset, _ := strconv.Atoi(offsetStr)

	if limit <= 0 || limit > 100 {
		limit = 20
	}

	posts, err := h.communityRepo.GetAllPosts(c.Request.Context(), sortBy, descending, limit, offset)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.PostsResponse{
			Success: false,
			Message: "Failed to get posts: " + err.Error(),
		})
		return
	}

	if posts == nil {
		posts = []models.Post{}
	}

	c.JSON(http.StatusOK, models.PostsResponse{
		Success: true,
		Posts:   posts,
		Count:   len(posts),
	})
}

// GetPost handles getting a specific post
func (h *CommunityHandlers) GetPost(c *gin.Context) {
	postID := c.Param("id")
	
	post, err := h.communityRepo.GetPostByID(c.Request.Context(), parseUUID(postID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.PostResponse{
			Success: false,
			Message: "Failed to get post: " + err.Error(),
		})
		return
	}

	if post == nil {
		c.JSON(http.StatusNotFound, models.PostResponse{
			Success: false,
			Message: "Post not found",
		})
		return
	}

	c.JSON(http.StatusOK, models.PostResponse{
		Success: true,
		Post:    post,
	})
}

// GetUserPosts handles getting posts by a specific user
func (h *CommunityHandlers) GetUserPosts(c *gin.Context) {
	targetUserID := c.Param("userId")
	
	posts, err := h.communityRepo.GetPostsByUserID(c.Request.Context(), parseUUID(targetUserID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.PostsResponse{
			Success: false,
			Message: "Failed to get user posts: " + err.Error(),
		})
		return
	}

	if posts == nil {
		posts = []models.Post{}
	}

	c.JSON(http.StatusOK, models.PostsResponse{
		Success: true,
		Posts:   posts,
		Count:   len(posts),
	})
}

// GetMyPosts handles getting posts by the current user
func (h *CommunityHandlers) GetMyPosts(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	
	posts, err := h.communityRepo.GetPostsByUserID(c.Request.Context(), parseUUID(userID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.PostsResponse{
			Success: false,
			Message: "Failed to get posts: " + err.Error(),
		})
		return
	}

	if posts == nil {
		posts = []models.Post{}
	}

	c.JSON(http.StatusOK, models.PostsResponse{
		Success: true,
		Posts:   posts,
		Count:   len(posts),
	})
}

// UpdatePost handles updating a post
func (h *CommunityHandlers) UpdatePost(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	postID := c.Param("id")
	
	var req models.UpdatePostRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.PostResponse{
			Success: false,
			Message: "Invalid request: " + err.Error(),
		})
		return
	}

	// Get existing post
	post, err := h.communityRepo.GetPostByID(c.Request.Context(), parseUUID(postID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.PostResponse{
			Success: false,
			Message: "Failed to get post: " + err.Error(),
		})
		return
	}

	if post == nil {
		c.JSON(http.StatusNotFound, models.PostResponse{
			Success: false,
			Message: "Post not found",
		})
		return
	}

	// Check ownership
	if post.UserID.String() != userID {
		c.JSON(http.StatusForbidden, models.PostResponse{
			Success: false,
			Message: "Not authorized to update this post",
		})
		return
	}

	// Update fields
	if req.Title != nil {
		post.Title = *req.Title
	}
	if req.Content != nil {
		post.Content = *req.Content
	}

	if err := h.communityRepo.UpdatePost(c.Request.Context(), post); err != nil {
		c.JSON(http.StatusInternalServerError, models.PostResponse{
			Success: false,
			Message: "Failed to update post: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, models.PostResponse{
		Success: true,
		Message: "Post updated successfully",
		Post:    post,
	})
}

// DeletePost handles deleting a post
func (h *CommunityHandlers) DeletePost(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	postID := c.Param("id")
	
	// Get existing post
	post, err := h.communityRepo.GetPostByID(c.Request.Context(), parseUUID(postID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.GenericResponse{
			Success: false,
			Message: "Failed to get post: " + err.Error(),
		})
		return
	}

	if post == nil {
		c.JSON(http.StatusNotFound, models.GenericResponse{
			Success: false,
			Message: "Post not found",
		})
		return
	}

	// Check ownership
	if post.UserID.String() != userID {
		c.JSON(http.StatusForbidden, models.GenericResponse{
			Success: false,
			Message: "Not authorized to delete this post",
		})
		return
	}

	if err := h.communityRepo.DeletePost(c.Request.Context(), parseUUID(postID)); err != nil {
		c.JSON(http.StatusInternalServerError, models.GenericResponse{
			Success: false,
			Message: "Failed to delete post: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, models.GenericResponse{
		Success: true,
		Message: "Post deleted successfully",
	})
}

// Comment Endpoints

// CreateComment handles creating a new comment
func (h *CommunityHandlers) CreateComment(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	
	var req models.CreateCommentRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.CommentResponse{
			Success: false,
			Message: "Invalid request: " + err.Error(),
		})
		return
	}

	// Verify post exists
	post, err := h.communityRepo.GetPostByID(c.Request.Context(), req.PostID)
	if err != nil || post == nil {
		c.JSON(http.StatusNotFound, models.CommentResponse{
			Success: false,
			Message: "Post not found",
		})
		return
	}

	// Get user info for the comment
	user, err := h.userRepo.GetByID(c.Request.Context(), parseUUID(userID))
	if err != nil || user == nil {
		c.JSON(http.StatusInternalServerError, models.CommentResponse{
			Success: false,
			Message: "Failed to get user info",
		})
		return
	}

	var userName string
	if user.DisplayName != nil {
		userName = *user.DisplayName
	} else {
		userName = "Anonymous User"
	}

	comment := &models.Comment{
		PostID:          req.PostID,
		UserID:          parseUUID(userID),
		ParentCommentID: req.ParentCommentID,
		Content:         req.Content,
		UserName:        &userName,
		UserAvatar:      user.AvatarURL,
	}

	if err := h.communityRepo.CreateComment(c.Request.Context(), comment); err != nil {
		c.JSON(http.StatusInternalServerError, models.CommentResponse{
			Success: false,
			Message: "Failed to create comment: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, models.CommentResponse{
		Success: true,
		Message: "Comment created successfully",
		Comment: comment,
	})
}

// GetComments handles getting comments for a post
func (h *CommunityHandlers) GetComments(c *gin.Context) {
	postID := c.Param("postId")
	
	comments, err := h.communityRepo.GetCommentsByPostID(c.Request.Context(), parseUUID(postID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.CommentsResponse{
			Success: false,
			Message: "Failed to get comments: " + err.Error(),
		})
		return
	}

	if comments == nil {
		comments = []models.Comment{}
	}

	c.JSON(http.StatusOK, models.CommentsResponse{
		Success:  true,
		Comments: comments,
		Count:    len(comments),
	})
}

// DeleteComment handles deleting a comment
func (h *CommunityHandlers) DeleteComment(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	commentID := c.Param("id")
	
	// Get existing comment
	comment, err := h.communityRepo.GetCommentByID(c.Request.Context(), parseUUID(commentID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.GenericResponse{
			Success: false,
			Message: "Failed to get comment: " + err.Error(),
		})
		return
	}

	if comment == nil {
		c.JSON(http.StatusNotFound, models.GenericResponse{
			Success: false,
			Message: "Comment not found",
		})
		return
	}

	// Check ownership
	if comment.UserID.String() != userID {
		c.JSON(http.StatusForbidden, models.GenericResponse{
			Success: false,
			Message: "Not authorized to delete this comment",
		})
		return
	}

	if err := h.communityRepo.DeleteComment(c.Request.Context(), parseUUID(commentID), comment.PostID); err != nil {
		c.JSON(http.StatusInternalServerError, models.GenericResponse{
			Success: false,
			Message: "Failed to delete comment: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, models.GenericResponse{
		Success: true,
		Message: "Comment deleted successfully",
	})
}

// Like Endpoints

// TogglePostLike handles toggling a like on a post
func (h *CommunityHandlers) TogglePostLike(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	postID := c.Param("id")
	
	// Verify post exists
	post, err := h.communityRepo.GetPostByID(c.Request.Context(), parseUUID(postID))
	if err != nil || post == nil {
		c.JSON(http.StatusNotFound, models.LikeResponse{
			Success: false,
			Message: "Post not found",
		})
		return
	}

	liked, err := h.communityRepo.ToggleLike(c.Request.Context(), parseUUID(userID), parseUUID(postID), "post")
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.LikeResponse{
			Success: false,
			Message: "Failed to toggle like: " + err.Error(),
		})
		return
	}

	message := "Post unliked"
	if liked {
		message = "Post liked"
	}

	c.JSON(http.StatusOK, models.LikeResponse{
		Success: true,
		Message: message,
		Liked:   liked,
	})
}

// ToggleCommentLike handles toggling a like on a comment
func (h *CommunityHandlers) ToggleCommentLike(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	commentID := c.Param("id")
	
	// Verify comment exists
	comment, err := h.communityRepo.GetCommentByID(c.Request.Context(), parseUUID(commentID))
	if err != nil || comment == nil {
		c.JSON(http.StatusNotFound, models.LikeResponse{
			Success: false,
			Message: "Comment not found",
		})
		return
	}

	liked, err := h.communityRepo.ToggleLike(c.Request.Context(), parseUUID(userID), parseUUID(commentID), "comment")
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.LikeResponse{
			Success: false,
			Message: "Failed to toggle like: " + err.Error(),
		})
		return
	}

	message := "Comment unliked"
	if liked {
		message = "Comment liked"
	}

	c.JSON(http.StatusOK, models.LikeResponse{
		Success: true,
		Message: message,
		Liked:   liked,
	})
}

// HasUserLikedPost handles checking if user liked a post
func (h *CommunityHandlers) HasUserLikedPost(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	postID := c.Param("id")
	
	liked, err := h.communityRepo.HasUserLiked(c.Request.Context(), parseUUID(userID), parseUUID(postID), "post")
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.LikeResponse{
			Success: false,
			Message: "Failed to check like status: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, models.LikeResponse{
		Success: true,
		Liked:   liked,
	})
}
