import { createClient } from '@supabase/supabase-js';
import ChatsClient from './ChatsClient';

export const dynamic = 'force-dynamic';

async function getChats() {
  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { auth: { persistSession: false } }
  );

  const { data: chats, error } = await supabase
    .from('chats')
    .select('id, pet_owner_id, vet_id, pet_id, last_message, last_message_at, unread_count_owner, unread_count_vet, created_at, updated_at')
    .order('updated_at', { ascending: false })
    .limit(200);

  if (error) throw error;

  // Collect all user IDs
  const userIds = Array.from(
    new Set(
      (chats ?? []).flatMap((c: { pet_owner_id: string; vet_id: string }) => [c.pet_owner_id, c.vet_id])
    )
  );
  const { data: users } = await supabase
    .from('users')
    .select('id, display_name, email, avatar_url')
    .in('id', userIds);
  const userMap = Object.fromEntries(
    (users ?? []).map((u: { id: string; display_name: string | null; email: string | null; avatar_url: string | null }) => [
      u.id,
      { name: u.display_name, email: u.email, avatar: u.avatar_url },
    ])
  );

  // Fetch messages for all chats
  const chatIds = (chats ?? []).map((c: { id: string }) => c.id);
  const { data: messages } = await supabase
    .from('messages')
    .select('id, chat_id, sender_id, content, is_read, created_at')
    .in('chat_id', chatIds)
    .order('created_at', { ascending: true })
    .limit(5000);

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const messagesByChat: Record<string, any[]> = {};
  for (const m of messages ?? []) {
    if (!messagesByChat[m.chat_id]) messagesByChat[m.chat_id] = [];
    messagesByChat[m.chat_id].push({
      ...m,
      sender: userMap[m.sender_id] ?? null,
    });
  }

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  return (chats ?? []).map((c: any) => ({
    ...c,
    owner: userMap[c.pet_owner_id] ?? null,
    vet: userMap[c.vet_id] ?? null,
    messages: messagesByChat[c.id] ?? [],
    message_count: (messagesByChat[c.id] ?? []).length,
  }));
}

export default async function ChatsPage() {
  const chats = await getChats();
  return <ChatsClient chats={chats} />;
}
