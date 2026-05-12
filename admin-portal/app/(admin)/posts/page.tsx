import { createClient } from '@supabase/supabase-js';
import PostsClient from './PostsClient';

export const dynamic = 'force-dynamic';

async function getPosts() {
  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { auth: { persistSession: false } }
  );

  const { data, error } = await supabase
    .from('posts')
    .select('id, title, content, category, likes_count, comments_count, image_urls, created_at, updated_at, user_id, user_name, user_avatar')
    .order('created_at', { ascending: false })
    .limit(200);

  if (error) throw error;

  // Enrich with live user data (user_name on posts can be stale)
  const userIds = Array.from(new Set((data ?? []).map((p: { user_id: string }) => p.user_id)));
  const { data: users } = await supabase
    .from('users')
    .select('id, display_name, email, avatar_url')
    .in('id', userIds);
  const userMap: Record<string, { display_name: string | null; email: string | null; avatar_url: string | null }> = Object.fromEntries(
    (users ?? []).map((u: { id: string; display_name: string | null; email: string | null; avatar_url: string | null }) => [
      u.id,
      { display_name: u.display_name, email: u.email, avatar_url: u.avatar_url },
    ])
  );

  // Fetch all comments for these posts (including parent_comment_id for threading awareness)
  const postIds = (data ?? []).map((p: { id: string }) => p.id);
  const { data: comments } = await supabase
    .from('comments')
    .select('id, post_id, user_id, parent_comment_id, content, likes_count, created_at, user_name')
    .in('post_id', postIds)
    .order('created_at', { ascending: true });

  // Collect any comment author IDs not already in userMap
  const commentUserIds = Array.from(new Set((comments ?? []).map((c: { user_id: string }) => c.user_id)));
  const missingUserIds = commentUserIds.filter((id) => !userMap[id]);
  if (missingUserIds.length > 0) {
    const { data: moreUsers } = await supabase
      .from('users')
      .select('id, display_name, email, avatar_url')
      .in('id', missingUserIds);
    (moreUsers ?? []).forEach((u: { id: string; display_name: string | null; email: string | null; avatar_url: string | null }) => {
      userMap[u.id] = { display_name: u.display_name, email: u.email, avatar_url: u.avatar_url };
    });
  }

  const commentsByPost: Record<string, Array<{
    id: string;
    content: string;
    likes_count: number;
    created_at: string;
    author: string;
    author_email: string | null;
    is_reply: boolean;
  }>> = {};

  (comments ?? []).forEach((c: {
    id: string; post_id: string; user_id: string; parent_comment_id: string | null;
    content: string; likes_count: number | null; created_at: string; user_name: string | null;
  }) => {
    if (!commentsByPost[c.post_id]) commentsByPost[c.post_id] = [];
    const u = userMap[c.user_id];
    commentsByPost[c.post_id].push({
      id: c.id,
      content: c.content,
      likes_count: c.likes_count ?? 0,
      created_at: c.created_at,
      author: u?.display_name || c.user_name || u?.email || 'Unknown',
      author_email: u?.email ?? null,
      is_reply: !!c.parent_comment_id,
    });
  });

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  return (data ?? []).map((p: any) => ({
    ...p,
    author: userMap[p.user_id] ?? null,
    comments: commentsByPost[p.id] ?? [],
  }));
}

export default async function PostsPage() {
  const posts = await getPosts();

  return (
    <div className="p-8">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Posts</h1>
        <p className="mt-1 text-sm text-gray-500">
          {posts.length} total posts — moderate community content
        </p>
      </div>
      <PostsClient posts={posts} />
    </div>
  );
}
