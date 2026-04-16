package handlers

import (
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"

	"pawpal-backend/internal/models"
	"pawpal-backend/internal/repositories"
)

type CommunityHubHandlers struct {
	repo     *repositories.CommunityHubRepository
	userRepo repositories.UserRepository
}

func NewCommunityHubHandlers(repo *repositories.CommunityHubRepository, userRepo repositories.UserRepository) *CommunityHubHandlers {
	return &CommunityHubHandlers{repo: repo, userRepo: userRepo}
}

// helper to grab limit/offset query params with defaults
func paginationParams(c *gin.Context) (int, int) {
	limit := 20
	offset := 0
	if v := c.Query("limit"); v != "" {
		if n, err := strconv.Atoi(v); err == nil && n > 0 && n <= 100 {
			limit = n
		}
	}
	if v := c.Query("offset"); v != "" {
		if n, err := strconv.Atoi(v); err == nil && n >= 0 {
			offset = n
		}
	}
	return limit, offset
}

// helper to load user info for new records
func (h *CommunityHubHandlers) userInfo(c *gin.Context) (string, *string, *string) {
	userID := c.MustGet("userID").(string)
	user, err := h.userRepo.GetByID(c.Request.Context(), parseUUID(userID))
	if err != nil || user == nil {
		return userID, nil, nil
	}
	var name string
	if user.DisplayName != nil {
		name = *user.DisplayName
	} else {
		name = "Anonymous User"
	}
	return userID, &name, user.AvatarURL
}

// ─── Lost & Found ────────────────────────────────────────────────

func (h *CommunityHubHandlers) CreateLostFound(c *gin.Context) {
	userID, userName, userAvatar := h.userInfo(c)

	var req models.CreateLostFoundRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Invalid request: " + err.Error()})
		return
	}

	lf := &models.LostFoundPost{
		UserID:           parseUUID(userID),
		Type:             req.Type,
		PetName:          req.PetName,
		PetType:          req.PetType,
		Breed:            req.Breed,
		Color:            req.Color,
		Description:      req.Description,
		ImageURLs:        req.ImageURLs,
		LastSeenLocation: req.LastSeenLocation,
		LastSeenLat:      req.LastSeenLat,
		LastSeenLng:      req.LastSeenLng,
		Urgency:          stringOrDefault(req.Urgency, "medium"),
		ContactPhone:     req.ContactPhone,
		ContactEmail:     req.ContactEmail,
		Status:           "active",
		UserName:         userName,
		UserAvatar:       userAvatar,
	}

	if err := h.repo.CreateLostFound(c.Request.Context(), lf); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Failed to create post: " + err.Error()})
		return
	}
	c.JSON(http.StatusCreated, gin.H{"success": true, "message": "Post created", "post": lf})
}

func (h *CommunityHubHandlers) GetLostFoundPosts(c *gin.Context) {
	postType := c.Query("type")
	status := c.DefaultQuery("status", "active")
	limit, offset := paginationParams(c)

	posts, total, err := h.repo.GetLostFoundPosts(c.Request.Context(), postType, status, limit, offset)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "posts": posts, "total": total})
}

func (h *CommunityHubHandlers) GetLostFoundByID(c *gin.Context) {
	id := parseUUID(c.Param("id"))
	post, err := h.repo.GetLostFoundByID(c.Request.Context(), id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": err.Error()})
		return
	}
	if post == nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "message": "Post not found"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "post": post})
}

func (h *CommunityHubHandlers) GetMyLostFoundPosts(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	posts, err := h.repo.GetMyLostFoundPosts(c.Request.Context(), parseUUID(userID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "posts": posts})
}

func (h *CommunityHubHandlers) UpdateLostFound(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	id := parseUUID(c.Param("id"))

	var req models.UpdateLostFoundRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Invalid request: " + err.Error()})
		return
	}

	if err := h.repo.UpdateLostFound(c.Request.Context(), id, parseUUID(userID), &req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "Post updated"})
}

func (h *CommunityHubHandlers) DeleteLostFound(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	id := parseUUID(c.Param("id"))

	if err := h.repo.DeleteLostFound(c.Request.Context(), id, parseUUID(userID)); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "Post deleted"})
}

// ─── Adoption Listings ───────────────────────────────────────────

func (h *CommunityHubHandlers) CreateAdoption(c *gin.Context) {
	userID, userName, userAvatar := h.userInfo(c)

	var req models.CreateAdoptionRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Invalid request: " + err.Error()})
		return
	}

	listing := &models.AdoptionListing{
		UserID:       parseUUID(userID),
		PetID:        &req.PetID,
		PetName:      req.PetName,
		PetType:      req.PetType,
		Breed:        req.Breed,
		Age:          req.Age,
		Gender:       req.Gender,
		Size:         req.Size,
		Color:        req.Color,
		Description:  req.Description,
		MedicalInfo:  req.MedicalInfo,
		IsVaccinated: req.IsVaccinated,
		IsNeutered:   req.IsNeutered,
		IsTrained:    req.IsTrained,
		GoodWithKids: req.GoodWithKids,
		GoodWithPets: req.GoodWithPets,
		ImageURLs:    req.ImageURLs,
		Location:     req.Location,
		ContactPhone: req.ContactPhone,
		ContactEmail: req.ContactEmail,
		AdoptionFee:  req.AdoptionFee,
		Status:       "available",
		UserName:     userName,
		UserAvatar:   userAvatar,
	}

	if err := h.repo.CreateAdoption(c.Request.Context(), listing); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Failed to create listing: " + err.Error()})
		return
	}
	c.JSON(http.StatusCreated, gin.H{"success": true, "message": "Listing created", "listing": listing})
}

func (h *CommunityHubHandlers) GetAdoptionListings(c *gin.Context) {
	petType := c.Query("petType")
	status := c.DefaultQuery("status", "available")
	limit, offset := paginationParams(c)

	listings, total, err := h.repo.GetAdoptionListings(c.Request.Context(), petType, status, limit, offset)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "listings": listings, "total": total})
}

func (h *CommunityHubHandlers) GetAdoptionByID(c *gin.Context) {
	id := parseUUID(c.Param("id"))
	listing, err := h.repo.GetAdoptionByID(c.Request.Context(), id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": err.Error()})
		return
	}
	if listing == nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "message": "Listing not found"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "listing": listing})
}

func (h *CommunityHubHandlers) GetMyAdoptionListings(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	listings, err := h.repo.GetMyAdoptionListings(c.Request.Context(), parseUUID(userID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "listings": listings})
}

func (h *CommunityHubHandlers) UpdateAdoption(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	id := parseUUID(c.Param("id"))

	var req models.UpdateAdoptionRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Invalid request: " + err.Error()})
		return
	}

	if err := h.repo.UpdateAdoption(c.Request.Context(), id, parseUUID(userID), &req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "Listing updated"})
}

func (h *CommunityHubHandlers) DeleteAdoption(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	id := parseUUID(c.Param("id"))

	if err := h.repo.DeleteAdoption(c.Request.Context(), id, parseUUID(userID)); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "Listing deleted"})
}

// ─── Events ──────────────────────────────────────────────────────

func (h *CommunityHubHandlers) CreateEvent(c *gin.Context) {
	userID, userName, userAvatar := h.userInfo(c)

	var req models.CreateEventRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Invalid request: " + err.Error()})
		return
	}

	startDate, err := parseDate(req.StartDate)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Invalid start date format, use RFC3339"})
		return
	}

	event := &models.Event{
		OrganizerID:     parseUUID(userID),
		Title:           req.Title,
		Description:     req.Description,
		EventType:       req.EventType,
		ImageURL:        req.ImageURL,
		Location:        req.Location,
		LocationLat:     req.LocationLat,
		LocationLng:     req.LocationLng,
		StartDate:       startDate,
		MaxAttendees:    req.MaxAttendees,
		IsPetFriendly:   req.IsPetFriendly,
		PetTypesAllowed: req.PetTypesAllowed,
		Status:          "upcoming",
		OrganizerName:   userName,
		OrganizerAvatar: userAvatar,
	}

	if req.EndDate != nil {
		endDate, err := parseDate(*req.EndDate)
		if err == nil {
			event.EndDate = &endDate
		}
	}

	if err := h.repo.CreateEvent(c.Request.Context(), event); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Failed to create event: " + err.Error()})
		return
	}
	c.JSON(http.StatusCreated, gin.H{"success": true, "message": "Event created", "event": event})
}

func (h *CommunityHubHandlers) GetEvents(c *gin.Context) {
	eventType := c.Query("eventType")
	status := c.DefaultQuery("status", "upcoming")
	limit, offset := paginationParams(c)

	events, total, err := h.repo.GetEvents(c.Request.Context(), eventType, status, limit, offset)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "events": events, "total": total})
}

func (h *CommunityHubHandlers) GetEventByID(c *gin.Context) {
	id := parseUUID(c.Param("id"))
	event, err := h.repo.GetEventByID(c.Request.Context(), id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": err.Error()})
		return
	}
	if event == nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "message": "Event not found"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "event": event})
}

func (h *CommunityHubHandlers) GetMyEvents(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	events, err := h.repo.GetMyEvents(c.Request.Context(), parseUUID(userID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "events": events})
}

func (h *CommunityHubHandlers) UpdateEvent(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	id := parseUUID(c.Param("id"))

	var req models.UpdateEventRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Invalid request: " + err.Error()})
		return
	}

	if err := h.repo.UpdateEvent(c.Request.Context(), id, parseUUID(userID), &req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "Event updated"})
}

func (h *CommunityHubHandlers) DeleteEvent(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	id := parseUUID(c.Param("id"))

	if err := h.repo.DeleteEvent(c.Request.Context(), id, parseUUID(userID)); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "Event deleted"})
}

// ─── RSVPs ───────────────────────────────────────────────────────

func (h *CommunityHubHandlers) RSVPEvent(c *gin.Context) {
	userID, userName, userAvatar := h.userInfo(c)
	eventID := parseUUID(c.Param("id"))

	var req models.RSVPRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Invalid request: " + err.Error()})
		return
	}

	// Get event to check max attendees
	event, err := h.repo.GetEventByID(c.Request.Context(), eventID)
	if err != nil || event == nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "message": "Event not found"})
		return
	}

	rsvp := &models.EventRSVP{
		EventID:    eventID,
		UserID:     parseUUID(userID),
		Status:     req.Status,
		UserName:   userName,
		UserAvatar: userAvatar,
	}

	if err := h.repo.RSVPEvent(c.Request.Context(), rsvp, event.MaxAttendees); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Failed to RSVP: " + err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "RSVP recorded", "rsvp": rsvp})
}

func (h *CommunityHubHandlers) CancelRSVP(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	eventID := parseUUID(c.Param("id"))

	if err := h.repo.CancelRSVP(c.Request.Context(), eventID, parseUUID(userID)); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "RSVP cancelled"})
}

func (h *CommunityHubHandlers) GetEventRSVPs(c *gin.Context) {
	eventID := parseUUID(c.Param("id"))
	rsvps, err := h.repo.GetEventRSVPs(c.Request.Context(), eventID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "rsvps": rsvps})
}

func (h *CommunityHubHandlers) GetMyRSVP(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	eventID := parseUUID(c.Param("id"))

	rsvp, err := h.repo.GetUserRSVP(c.Request.Context(), eventID, parseUUID(userID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "rsvp": rsvp})
}

// ─── Helpers ─────────────────────────────────────────────────────

func stringOrDefault(s, def string) string {
	if s == "" {
		return def
	}
	return s
}

func boolOrDefault(b *bool, def bool) bool {
	if b == nil {
		return def
	}
	return *b
}

func floatOrDefault(f *float64, def float64) float64 {
	if f == nil {
		return def
	}
	return *f
}

func parseDate(s string) (time.Time, error) {
	return time.Parse(time.RFC3339, s)
}
