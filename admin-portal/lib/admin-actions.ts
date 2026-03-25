'use server';

import { createClient } from '@supabase/supabase-js';

function getAdminClient() {
  return createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!,
    { auth: { persistSession: false } }
  );
}

type Result = { success: true } | { success: false; error: string };

// ─── Users ───────────────────────────────────────────────
export async function deleteUser(userId: string): Promise<Result> {
  try {
    const supabase = getAdminClient();
    const { error } = await supabase.from('users').delete().eq('id', userId);
    if (error) return { success: false, error: error.message };
    return { success: true };
  } catch (e) { return { success: false, error: String(e) }; }
}

// ─── Posts ───────────────────────────────────────────────
export async function deletePost(postId: string): Promise<Result> {
  try {
    const supabase = getAdminClient();
    // Delete comments first (FK)
    await supabase.from('comments').delete().eq('post_id', postId);
    await supabase.from('likes').delete().eq('target_id', postId);
    const { error } = await supabase.from('posts').delete().eq('id', postId);
    if (error) return { success: false, error: error.message };
    return { success: true };
  } catch (e) { return { success: false, error: String(e) }; }
}

export async function deleteComment(commentId: string): Promise<Result> {
  try {
    const supabase = getAdminClient();
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
    const { error } = await supabase.from('vet_profiles').update({ is_verified: isVerified }).eq('id', vetId);
    if (error) return { success: false, error: error.message };
    return { success: true };
  } catch (e) { return { success: false, error: String(e) }; }
}

export async function deleteVet(vetId: string): Promise<Result> {
  try {
    const supabase = getAdminClient();
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
    await supabase.from('health_journals').delete().eq('pet_id', petId);
    await supabase.from('health_records').delete().eq('pet_id', petId);
    const { error } = await supabase.from('pets').delete().eq('id', petId);
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
