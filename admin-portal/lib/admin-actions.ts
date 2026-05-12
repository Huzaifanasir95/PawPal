'use server';

import { createClient } from '@supabase/supabase-js';

function getAdminClient() {
  return createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!,
    {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
      db: { schema: 'public' },
    }
  );
}

type Result = { success: true } | { success: false; error: string };

// ─── Users ───────────────────────────────────────────────
export async function deleteUser(userId: string): Promise<Result> {
  try {
    const supabase = getAdminClient();

    // 1. Delete messages in chats where user is owner or vet
    const { data: userChats } = await supabase
      .from('chats')
      .select('id')
      .or(`pet_owner_id.eq.${userId},vet_id.eq.${userId}`);
    const chatIds = (userChats ?? []).map((c: { id: string }) => c.id);
    if (chatIds.length > 0) {
      await supabase.from('messages').delete().in('chat_id', chatIds);
      await supabase.from('chats').delete().in('id', chatIds);
    }
    // Also delete messages sent by this user in other chats
    await supabase.from('messages').delete().eq('sender_id', userId);

    // 2. Delete booking-related data
    const { data: userBookings } = await supabase
      .from('service_bookings')
      .select('id')
      .or(`pet_owner_id.eq.${userId}`);
    const bookingIds = (userBookings ?? []).map((b: { id: string }) => b.id);
    if (bookingIds.length > 0) {
      await supabase.from('booking_payments').delete().in('booking_id', bookingIds);
      await supabase.from('booking_tracking').delete().in('booking_id', bookingIds);
      await supabase.from('booking_completion_reports').delete().in('booking_id', bookingIds);
      await supabase.from('service_reviews').delete().in('booking_id', bookingIds);
      await supabase.from('service_incidents').delete().in('booking_id', bookingIds);
      await supabase.from('service_bookings').delete().in('id', bookingIds);
    }

    // 3. Delete vet appointments
    await supabase.from('vet_appointments').delete().or(`pet_owner_id.eq.${userId},vet_user_id.eq.${userId}`);

    // 4. Delete marketplace data
    const { data: userOrders } = await supabase.from('orders').select('id').eq('buyer_id', userId);
    const orderIds = (userOrders ?? []).map((o: { id: string }) => o.id);
    if (orderIds.length > 0) {
      await supabase.from('order_items').delete().in('order_id', orderIds);
      await supabase.from('orders').delete().in('id', orderIds);
    }
    const { data: userProducts } = await supabase.from('products').select('id').eq('seller_id', userId);
    const productIds = (userProducts ?? []).map((p: { id: string }) => p.id);
    if (productIds.length > 0) {
      await supabase.from('product_reviews').delete().in('product_id', productIds);
      await supabase.from('cart_items').delete().in('product_id', productIds);
      await supabase.from('order_items').delete().in('product_id', productIds);
      await supabase.from('products').delete().in('id', productIds);
    }
    await supabase.from('cart_items').delete().eq('user_id', userId);
    await supabase.from('product_reviews').delete().eq('user_id', userId);

    // 5. Delete pets and their health data
    const { data: userPets } = await supabase.from('pets').select('id').eq('owner_id', userId);
    const petIds = (userPets ?? []).map((p: { id: string }) => p.id);
    if (petIds.length > 0) {
      await supabase.from('health_journals').delete().in('pet_id', petIds);
      await supabase.from('health_records').delete().in('pet_id', petIds);
      await supabase.from('adoption_listings').delete().in('pet_id', petIds);
      await supabase.from('pets').delete().in('id', petIds);
    }

    // 6. Delete posts, comments, likes
    const { data: userPosts } = await supabase.from('posts').select('id').eq('user_id', userId);
    const postIds = (userPosts ?? []).map((p: { id: string }) => p.id);
    if (postIds.length > 0) {
      await supabase.from('comments').delete().in('post_id', postIds);
      await supabase.from('likes').delete().in('target_id', postIds);
      await supabase.from('posts').delete().in('id', postIds);
    }
    await supabase.from('comments').delete().eq('user_id', userId);
    await supabase.from('likes').delete().eq('user_id', userId);

    // 7. Delete social/community data
    await supabase.from('event_rsvps').delete().eq('user_id', userId);
    await supabase.from('events').delete().eq('organizer_id', userId);
    await supabase.from('adoption_listings').delete().eq('user_id', userId);
    await supabase.from('lost_found_posts').delete().eq('user_id', userId);

    // 8. Delete profile data
    await supabase.from('vet_reviews').delete().or(`vet_id.eq.${userId},user_id.eq.${userId}`);
    await supabase.from('vet_profiles').delete().eq('user_id', userId);
    const { data: cgProfile } = await supabase
      .from('caregiver_profiles')
      .select('id')
      .eq('user_id', userId)
      .single();
    if (cgProfile) {
      await supabase.from('caregiver_availability').delete().eq('caregiver_id', cgProfile.id);
      await supabase.from('caregiver_blocked_dates').delete().eq('caregiver_id', cgProfile.id);
      await supabase.from('caregiver_gallery').delete().eq('caregiver_id', cgProfile.id);
      await supabase.from('caregiver_services').delete().eq('caregiver_id', cgProfile.id);
      await supabase.from('caregiver_profiles').delete().eq('id', cgProfile.id);
    }

    // 9. Delete auth data
    await supabase.from('user_roles').delete().eq('user_id', userId);
    await supabase.from('refresh_tokens').delete().eq('user_id', userId);
    await supabase.from('password_reset_tokens').delete().eq('user_id', userId);

    // 10. Finally delete the user
    const { error } = await supabase.from('users').delete().eq('id', userId);
    if (error) return { success: false, error: error.message };
    return { success: true };
  } catch (e) { return { success: false, error: String(e) }; }
}

// ─── Posts ───────────────────────────────────────────────
export async function deletePost(postId: string): Promise<Result> {
  try {
    const supabase = getAdminClient();
    // Fetch all comments for this post
    const { data: postComments } = await supabase
      .from('comments')
      .select('id')
      .eq('post_id', postId);
    const commentIds = (postComments ?? []).map((c: { id: string }) => c.id);
    if (commentIds.length > 0) {
      // Delete likes on all comments
      await supabase.from('likes').delete().in('target_id', commentIds);
      // Delete child comments first (replies), then top-level (self-referencing FK)
      await supabase.from('comments').delete().eq('post_id', postId).not('parent_comment_id', 'is', null);
      await supabase.from('comments').delete().eq('post_id', postId);
    }
    // Delete likes on the post itself
    await supabase.from('likes').delete().eq('target_id', postId).eq('target_type', 'post');
    const { error } = await supabase.from('posts').delete().eq('id', postId);
    if (error) return { success: false, error: error.message };
    return { success: true };
  } catch (e) { return { success: false, error: String(e) }; }
}

export async function deleteComment(commentId: string): Promise<Result> {
  try {
    const supabase = getAdminClient();
    // Delete any replies to this comment first
    const { data: replies } = await supabase
      .from('comments')
      .select('id')
      .eq('parent_comment_id', commentId);
    const replyIds = (replies ?? []).map((r: { id: string }) => r.id);
    if (replyIds.length > 0) {
      await supabase.from('likes').delete().in('target_id', replyIds);
      await supabase.from('comments').delete().in('id', replyIds);
    }
    await supabase.from('likes').delete().eq('target_id', commentId);
    const { error } = await supabase.from('comments').delete().eq('id', commentId);
    if (error) return { success: false, error: error.message };
    return { success: true };
  } catch (e) { return { success: false, error: String(e) }; }
}

// ─── Events ──────────────────────────────────────────────
export async function deleteEvent(eventId: string): Promise<Result> {
  try {
    const supabase = getAdminClient();
    await supabase.from('event_rsvps').delete().eq('event_id', eventId);
    const { error } = await supabase.from('events').delete().eq('id', eventId);
    if (error) return { success: false, error: error.message };
    return { success: true };
  } catch (e) { return { success: false, error: String(e) }; }
}

export async function updateEventStatus(eventId: string, status: string): Promise<Result> {
  try {
    const supabase = getAdminClient();
    const { error } = await supabase.from('events').update({ status }).eq('id', eventId);
    if (error) return { success: false, error: error.message };
    return { success: true };
  } catch (e) { return { success: false, error: String(e) }; }
}

// ─── Vets ────────────────────────────────────────────────
export async function updateVetVerification(vetId: string, isVerified: boolean): Promise<Result> {
  try {
    const supabase = getAdminClient();
    const { error } = await supabase
      .from('vet_profiles')
      .update({ is_verified: isVerified, updated_at: new Date().toISOString() })
      .eq('id', vetId);
    if (error) return { success: false, error: error.message };
    return { success: true };
  } catch (e) { return { success: false, error: String(e) }; }
}

export async function deleteVet(vetId: string): Promise<Result> {
  try {
    const supabase = getAdminClient();

    // Fetch vet profile to get user_id
    const { data: vetProfile } = await supabase
      .from('vet_profiles')
      .select('id, user_id')
      .eq('id', vetId)
      .maybeSingle();
    if (!vetProfile) return { success: false, error: 'Vet profile not found' };

    const userId = vetProfile.user_id;

    // 1. Delete vet appointments and nullify any chat appointment_id FKs
    const { data: appts } = await supabase
      .from('vet_appointments')
      .select('id')
      .eq('vet_user_id', userId);
    const apptIds = (appts ?? []).map((a: { id: string }) => a.id);
    if (apptIds.length > 0) {
      await supabase.from('chats').update({ appointment_id: null }).in('appointment_id', apptIds);
      await supabase.from('vet_appointments').delete().in('id', apptIds);
    }

    // 2. Delete chats where this vet is a participant, plus their messages
    const { data: vetChats } = await supabase
      .from('chats')
      .select('id')
      .eq('vet_id', userId);
    const chatIds = (vetChats ?? []).map((c: { id: string }) => c.id);
    if (chatIds.length > 0) {
      await supabase.from('messages').delete().in('chat_id', chatIds);
      await supabase.from('chats').delete().in('id', chatIds);
    }

    // 3. Delete service bookings where this vet was the provider
    const { data: vetBookings } = await supabase
      .from('service_bookings')
      .select('id')
      .eq('caregiver_id', userId);
    const bookingIds = (vetBookings ?? []).map((b: { id: string }) => b.id);
    if (bookingIds.length > 0) {
      await supabase.from('booking_payments').delete().in('booking_id', bookingIds);
      await supabase.from('booking_tracking').delete().in('booking_id', bookingIds);
      await supabase.from('booking_completion_reports').delete().in('booking_id', bookingIds);
      await supabase.from('service_reviews').delete().in('booking_id', bookingIds);
      await supabase.from('service_incidents').delete().in('booking_id', bookingIds);
      await supabase.from('service_bookings').delete().in('id', bookingIds);
    }

    // 4. Delete vet reviews
    await supabase.from('vet_reviews').delete().eq('vet_id', userId);

    // 5. Finally delete the vet profile
    const { error } = await supabase.from('vet_profiles').delete().eq('id', vetId);
    if (error) return { success: false, error: error.message };
    return { success: true };
  } catch (e) { return { success: false, error: String(e) }; }
}

// ─── Adoptions ───────────────────────────────────────────
export async function updateAdoptionStatus(id: string, status: string): Promise<Result> {
  try {
    const supabase = getAdminClient();
    const { error } = await supabase.from('adoption_listings').update({ status }).eq('id', id);
    if (error) return { success: false, error: error.message };
    return { success: true };
  } catch (e) { return { success: false, error: String(e) }; }
}

export async function deleteAdoption(id: string): Promise<Result> {
  try {
    const supabase = getAdminClient();
    const { error } = await supabase.from('adoption_listings').delete().eq('id', id);
    if (error) return { success: false, error: error.message };
    return { success: true };
  } catch (e) { return { success: false, error: String(e) }; }
}

// ─── Lost & Found ────────────────────────────────────────
export async function updateLostFoundStatus(id: string, status: string): Promise<Result> {
  try {
    const supabase = getAdminClient();
    const { error } = await supabase.from('lost_found_posts').update({ status }).eq('id', id);
    if (error) return { success: false, error: error.message };
    return { success: true };
  } catch (e) { return { success: false, error: String(e) }; }
}

export async function deleteLostFound(id: string): Promise<Result> {
  try {
    const supabase = getAdminClient();
    const { error } = await supabase.from('lost_found_posts').delete().eq('id', id);
    if (error) return { success: false, error: error.message };
    return { success: true };
  } catch (e) { return { success: false, error: String(e) }; }
}

// ─── Pets ────────────────────────────────────────────────
export async function deletePet(petId: string): Promise<Result> {
  try {
    const supabase = getAdminClient();

    // Health data
    await supabase.from('health_journals').delete().eq('pet_id', petId);
    await supabase.from('health_records').delete().eq('pet_id', petId);

    // Adoption listings referencing this pet
    await supabase.from('adoption_listings').delete().eq('pet_id', petId);

    // Vet appointments for this pet (messages/chats linked via appointment_id — delete messages first)
    const { data: petAppts } = await supabase
      .from('vet_appointments')
      .select('id')
      .eq('pet_id', petId);
    const apptIds = (petAppts ?? []).map((a: { id: string }) => a.id);
    if (apptIds.length > 0) {
      // Nullify appointment_id on chats so FK doesn't block (chats may still exist for other reasons)
      await supabase.from('chats').update({ appointment_id: null }).in('appointment_id', apptIds);
      await supabase.from('vet_appointments').delete().in('id', apptIds);
    }

    // Chats linked directly to this pet
    const { data: petChats } = await supabase
      .from('chats')
      .select('id')
      .eq('pet_id', petId);
    const chatIds = (petChats ?? []).map((c: { id: string }) => c.id);
    if (chatIds.length > 0) {
      await supabase.from('messages').delete().in('chat_id', chatIds);
      await supabase.from('chats').delete().in('id', chatIds);
    }

    // Finally delete the pet
    const { error } = await supabase.from('pets').delete().eq('id', petId);
    if (error) return { success: false, error: error.message };
    return { success: true };
  } catch (e) { return { success: false, error: String(e) }; }
}

// ─── Bookings ────────────────────────────────────────────
export async function updateBookingStatus(bookingId: string, status: string): Promise<Result> {
  try {
    const supabase = getAdminClient();
    const { error } = await supabase.from('service_bookings').update({ status }).eq('id', bookingId);
    if (error) return { success: false, error: error.message };
    return { success: true };
  } catch (e) { return { success: false, error: String(e) }; }
}

export async function deleteBooking(bookingId: string): Promise<Result> {
  try {
    const supabase = getAdminClient();
    await supabase.from('booking_payments').delete().eq('booking_id', bookingId);
    await supabase.from('booking_tracking').delete().eq('booking_id', bookingId);
    await supabase.from('service_incidents').delete().eq('booking_id', bookingId);
    const { error } = await supabase.from('service_bookings').delete().eq('id', bookingId);
    if (error) return { success: false, error: error.message };
    return { success: true };
  } catch (e) { return { success: false, error: String(e) }; }
}

// ─── Marketplace ─────────────────────────────────────────
export async function updateProductStatus(productId: string, isActive: boolean): Promise<Result> {
  try {
    const supabase = getAdminClient();
    const { error } = await supabase.from('products').update({ is_active: isActive }).eq('id', productId);
    if (error) return { success: false, error: error.message };
    return { success: true };
  } catch (e) { return { success: false, error: String(e) }; }
}

export async function deleteProduct(productId: string): Promise<Result> {
  try {
    const supabase = getAdminClient();
    await supabase.from('product_reviews').delete().eq('product_id', productId);
    await supabase.from('cart_items').delete().eq('product_id', productId);
    const { error } = await supabase.from('products').delete().eq('id', productId);
    if (error) return { success: false, error: error.message };
    return { success: true };
  } catch (e) { return { success: false, error: String(e) }; }
}

export async function updateOrderStatus(orderId: string, status: string): Promise<Result> {
  try {
    const supabase = getAdminClient();
    const { error } = await supabase.from('orders').update({ status }).eq('id', orderId);
    if (error) return { success: false, error: error.message };
    return { success: true };
  } catch (e) { return { success: false, error: String(e) }; }
}

export async function deleteOrder(orderId: string): Promise<Result> {
  try {
    const supabase = getAdminClient();
    await supabase.from('order_items').delete().eq('order_id', orderId);
    const { error } = await supabase.from('orders').delete().eq('id', orderId);
    if (error) return { success: false, error: error.message };
    return { success: true };
  } catch (e) { return { success: false, error: String(e) }; }
}

// ─── Caregivers ──────────────────────────────────────────
export async function updateCaregiverVerification(caregiverId: string, isVerified: boolean): Promise<Result> {
  try {
    const supabase = getAdminClient();
    const { error } = await supabase
      .from('caregiver_profiles')
      .update({ is_verified: isVerified, verification_date: isVerified ? new Date().toISOString() : null })
      .eq('id', caregiverId);
    if (error) return { success: false, error: error.message };
    return { success: true };
  } catch (e) { return { success: false, error: String(e) }; }
}

export async function deleteCaregiver(caregiverId: string): Promise<Result> {
  try {
    const supabase = getAdminClient();
    const { error } = await supabase.from('caregiver_profiles').delete().eq('id', caregiverId);
    if (error) return { success: false, error: error.message };
    return { success: true };
  } catch (e) { return { success: false, error: String(e) }; }
}

// ─── Vet Appointments ────────────────────────────────────
export async function updateVetAppointmentStatus(appointmentId: string, status: string): Promise<Result> {
  try {
    const supabase = getAdminClient();
    const { error } = await supabase.from('vet_appointments').update({ status }).eq('id', appointmentId);
    if (error) return { success: false, error: error.message };
    return { success: true };
  } catch (e) { return { success: false, error: String(e) }; }
}

export async function deleteVetAppointment(appointmentId: string): Promise<Result> {
  try {
    const supabase = getAdminClient();
    const { error } = await supabase.from('vet_appointments').delete().eq('id', appointmentId);
    if (error) return { success: false, error: error.message };
    return { success: true };
  } catch (e) { return { success: false, error: String(e) }; }
}

// ─── Chats ───────────────────────────────────────────────
export async function deleteChat(chatId: string): Promise<Result> {
  try {
    const supabase = getAdminClient();
    await supabase.from('messages').delete().eq('chat_id', chatId);
    const { error } = await supabase.from('chats').delete().eq('id', chatId);
    if (error) return { success: false, error: error.message };
    return { success: true };
  } catch (e) { return { success: false, error: String(e) }; }
}

export async function deleteMessage(messageId: string): Promise<Result> {
  try {
    const supabase = getAdminClient();
    const { error } = await supabase.from('messages').delete().eq('id', messageId);
    if (error) return { success: false, error: error.message };
    return { success: true };
  } catch (e) { return { success: false, error: String(e) }; }
}
