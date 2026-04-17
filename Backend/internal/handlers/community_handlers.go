package handlers

import (
	"net/http"
	"regexp"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"

	"pawpal-backend/internal/models"
	"pawpal-backend/internal/repositories"

	"github.com/google/uuid"
)

// CommunityHandlers handles community endpoints
type CommunityHandlers struct {
	communityRepo *repositories.CommunityRepository
	userRepo      repositories.UserRepository
}

var (
	hashtagValuePattern = regexp.MustCompile(`^[A-Za-z0-9_]{2,40}$`)
	nonSlugCharsPattern = regexp.MustCompile(`[^a-z0-9]+`)
)

// NewCommunityHandlers creates new CommunityHandlers
func NewCommunityHandlers(communityRepo *repositories.CommunityRepository, userRepo repositories.UserRepository) *CommunityHandlers {
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

	// Default category if not provided
	category := req.Category
	if category == "" {
		category = "general"
	}

	post := &models.Post{
		UserID:     parseUUID(userID),
		Title:      req.Title,
		Content:    req.Content,
		Category:   category,
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
	category := c.DefaultQuery("category", "") // Empty means all categories

	descending := descendingStr == "true"
	limit, _ := strconv.Atoi(limitStr)
	offset, _ := strconv.Atoi(offsetStr)

	if limit <= 0 || limit > 100 {
		limit = 20
	}

	posts, err := h.communityRepo.GetAllPosts(c.Request.Context(), sortBy, descending, limit, offset, category)
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

// UpdateComment handles updating a comment
func (h *CommunityHandlers) UpdateComment(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	commentID := c.Param("id")

	var req struct {
		Content string `json:"content" binding:"required,min=1"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.CommentResponse{
			Success: false,
			Message: "Invalid request: " + err.Error(),
		})
		return
	}

	req.Content = strings.TrimSpace(req.Content)
	if req.Content == "" {
		c.JSON(http.StatusBadRequest, models.CommentResponse{
			Success: false,
			Message: "Comment content is required",
		})
		return
	}

	comment, err := h.communityRepo.GetCommentByID(c.Request.Context(), parseUUID(commentID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.CommentResponse{
			Success: false,
			Message: "Failed to get comment: " + err.Error(),
		})
		return
	}
	if comment == nil {
		c.JSON(http.StatusNotFound, models.CommentResponse{
			Success: false,
			Message: "Comment not found",
		})
		return
	}

	if comment.UserID.String() != userID {
		c.JSON(http.StatusForbidden, models.CommentResponse{
			Success: false,
			Message: "Not authorized to update this comment",
		})
		return
	}

	if err := h.communityRepo.UpdateComment(c.Request.Context(), parseUUID(commentID), req.Content); err != nil {
		c.JSON(http.StatusInternalServerError, models.CommentResponse{
			Success: false,
			Message: "Failed to update comment: " + err.Error(),
		})
		return
	}

	comment.Content = req.Content
	c.JSON(http.StatusOK, models.CommentResponse{
		Success: true,
		Message: "Comment updated successfully",
		Comment: comment,
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

// GetTrendingPosts returns posts ranked by recent engagement.
func (h *CommunityHandlers) GetTrendingPosts(c *gin.Context) {
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	offset, _ := strconv.Atoi(c.DefaultQuery("offset", "0"))

	posts, err := h.communityRepo.GetTrendingPosts(c.Request.Context(), limit, offset)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.PostsResponse{
			Success: false,
			Message: "Failed to fetch trending posts: " + err.Error(),
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

// GetTrendingHashtags returns top hashtags extracted from posts.
func (h *CommunityHandlers) GetTrendingHashtags(c *gin.Context) {
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "12"))

	hashtags, err := h.communityRepo.GetTrendingHashtags(c.Request.Context(), limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.GenericResponse{
			Success: false,
			Message: "Failed to fetch trending hashtags: " + err.Error(),
		})
		return
	}

	if hashtags == nil {
		hashtags = []models.TrendingHashtag{}
	}

	c.JSON(http.StatusOK, models.GenericResponse{
		Success: true,
		Data:    hashtags,
	})
}

// GetPostsByHashtag returns posts containing a given hashtag.
func (h *CommunityHandlers) GetPostsByHashtag(c *gin.Context) {
	rawTag := strings.TrimSpace(c.Param("tag"))
	cleanTag := strings.TrimPrefix(rawTag, "#")

	if !hashtagValuePattern.MatchString(cleanTag) {
		c.JSON(http.StatusBadRequest, models.PostsResponse{
			Success: false,
			Message: "Invalid hashtag format",
		})
		return
	}

	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	offset, _ := strconv.Atoi(c.DefaultQuery("offset", "0"))

	posts, err := h.communityRepo.GetPostsByHashtag(c.Request.Context(), cleanTag, limit, offset)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.PostsResponse{
			Success: false,
			Message: "Failed to fetch hashtag posts: " + err.Error(),
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

// CreateGroup creates a new community group.
func (h *CommunityHandlers) CreateGroup(c *gin.Context) {
	userID := c.MustGet("userID").(string)

	var req models.CreateCommunityGroupRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.GenericResponse{
			Success: false,
			Message: "Invalid request: " + err.Error(),
		})
		return
	}

	req.Name = strings.TrimSpace(req.Name)
	req.Description = sanitizeOptionalText(req.Description)
	req.Icon = sanitizeOptionalText(req.Icon)

	if req.Name == "" {
		c.JSON(http.StatusBadRequest, models.GenericResponse{
			Success: false,
			Message: "Group name is required",
		})
		return
	}

	slug := buildGroupSlug(req.Name)
	if slug == "" {
		c.JSON(http.StatusBadRequest, models.GenericResponse{
			Success: false,
			Message: "Invalid group name",
		})
		return
	}

	group := &models.CommunityGroup{
		OwnerID:     parseUUID(userID),
		Name:        req.Name,
		Slug:        slug,
		Description: req.Description,
		Icon:        req.Icon,
		IsPrivate:   req.IsPrivate,
	}

	err := h.communityRepo.CreateGroup(c.Request.Context(), group)
	if err != nil && strings.Contains(strings.ToLower(err.Error()), "duplicate") {
		randomSuffix := strings.ReplaceAll(uuid.New().String()[:6], "-", "")
		group.Slug = slug + "-" + randomSuffix
		err = h.communityRepo.CreateGroup(c.Request.Context(), group)
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.GenericResponse{
			Success: false,
			Message: "Failed to create group: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, models.GenericResponse{
		Success: true,
		Message: "Group created successfully",
		Data:    group,
	})
}

// ListGroups returns discoverable community groups.
func (h *CommunityHandlers) ListGroups(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	search := strings.TrimSpace(c.Query("q"))
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	if page < 1 {
		page = 1
	}
	offset := (page - 1) * limit

	groups, total, err := h.communityRepo.ListGroups(c.Request.Context(), parseUUID(userID), search, limit, offset)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.GenericResponse{
			Success: false,
			Message: "Failed to fetch groups: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"groups":  groups,
		"pagination": gin.H{
			"page":  page,
			"limit": limit,
			"total": total,
		},
	})
}

// GetMyGroups returns groups where current user is a member.
func (h *CommunityHandlers) GetMyGroups(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

	if page < 1 {
		page = 1
	}
	offset := (page - 1) * limit

	groups, total, err := h.communityRepo.GetMyGroups(c.Request.Context(), parseUUID(userID), limit, offset)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.GenericResponse{
			Success: false,
			Message: "Failed to fetch user groups: " + err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"groups":  groups,
		"pagination": gin.H{
			"page":  page,
			"limit": limit,
			"total": total,
		},
	})
}

// JoinGroup adds current user to group members.
func (h *CommunityHandlers) JoinGroup(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	groupID := parseUUID(c.Param("id"))
	if groupID == uuid.Nil {
		c.JSON(http.StatusBadRequest, models.GenericResponse{Success: false, Message: "Invalid group ID"})
		return
	}

	joined, err := h.communityRepo.JoinGroup(c.Request.Context(), groupID, parseUUID(userID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.GenericResponse{Success: false, Message: "Failed to join group: " + err.Error()})
		return
	}

	if !joined {
		c.JSON(http.StatusOK, models.GenericResponse{Success: true, Message: "Already a member"})
		return
	}

	c.JSON(http.StatusOK, models.GenericResponse{Success: true, Message: "Joined group successfully"})
}

// LeaveGroup removes current user from group members.
func (h *CommunityHandlers) LeaveGroup(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	groupID := parseUUID(c.Param("id"))
	if groupID == uuid.Nil {
		c.JSON(http.StatusBadRequest, models.GenericResponse{Success: false, Message: "Invalid group ID"})
		return
	}

	left, err := h.communityRepo.LeaveGroup(c.Request.Context(), groupID, parseUUID(userID))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.GenericResponse{Success: false, Message: err.Error()})
		return
	}

	if !left {
		c.JSON(http.StatusOK, models.GenericResponse{Success: true, Message: "Not a member of this group"})
		return
	}

	c.JSON(http.StatusOK, models.GenericResponse{Success: true, Message: "Left group successfully"})
}

// AddPostToGroup links one of user's posts to a community group.
func (h *CommunityHandlers) AddPostToGroup(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	groupID := parseUUID(c.Param("id"))
	if groupID == uuid.Nil {
		c.JSON(http.StatusBadRequest, models.GenericResponse{Success: false, Message: "Invalid group ID"})
		return
	}

	var req models.AddPostToGroupRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.GenericResponse{Success: false, Message: "Invalid request: " + err.Error()})
		return
	}

	err := h.communityRepo.AddPostToGroup(c.Request.Context(), groupID, req.PostID, parseUUID(userID))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.GenericResponse{Success: false, Message: err.Error()})
		return
	}

	c.JSON(http.StatusOK, models.GenericResponse{Success: true, Message: "Post added to group"})
}

// GetGroupPosts lists posts for a specific group.
func (h *CommunityHandlers) GetGroupPosts(c *gin.Context) {
	groupID := parseUUID(c.Param("id"))
	if groupID == uuid.Nil {
		c.JSON(http.StatusBadRequest, models.PostsResponse{Success: false, Message: "Invalid group ID"})
		return
	}

	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	offset, _ := strconv.Atoi(c.DefaultQuery("offset", "0"))

	posts, total, err := h.communityRepo.GetGroupPosts(c.Request.Context(), groupID, limit, offset)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.PostsResponse{Success: false, Message: "Failed to fetch group posts: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"posts":   posts,
		"count":   len(posts),
		"total":   total,
	})
}

func buildGroupSlug(name string) string {
	slug := strings.ToLower(strings.TrimSpace(name))
	slug = nonSlugCharsPattern.ReplaceAllString(slug, "-")
	slug = strings.Trim(slug, "-")
	if slug == "" {
		return ""
	}
	if len(slug) > 80 {
		slug = slug[:80]
		slug = strings.Trim(slug, "-")
	}
	return slug
}
