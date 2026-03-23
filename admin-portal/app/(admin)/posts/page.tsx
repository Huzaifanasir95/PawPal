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
    .select('id, content, category, likes_count, comments_count, image_urls, created_at, user_id')
    .order('created_at', { ascending: false })
    .limit(200);

  if (error) throw error;

  // Enrich with user data
  const userIds = Array.from(new Set((data ?? []).map((p: { user_id: string }) => p.user_id)));
  const { data: users } = await supabase
    .from('users')
    .select('id, display_name, email')
    .in('id', userIds);
  const userMap = Object.fromEntries((users ?? []).map((u: { id: string; display_name: string | null; email: string | null }) => [u.id, { full_name: u.display_name, email: u.email }]));

  // Fetch comments for all posts
  const postIds = (data ?? []).map((p: { id: string }) => p.id);
  const { data: comments } = await supabase
    .from('comments')
    .select('id, post_id, user_id, content, likes_count, created_at')
    .in('post_id', postIds)
    .order('created_at', { ascending: true });

  // Enrich comment authors
  const commentUserIds = Array.from(new Set((comments ?? []).map((c: { user_id: string }) => c.user_id)));
  const missingUserIds = commentUserIds.filter((id) => !userMap[id]);
  if (missingUserIds.length > 0) {
    const { data: moreUsers } = await supabase
      .from('users')
      .select('id, display_name, email')
      .in('id', missingUserIds);
    (moreUsers ?? []).forEach((u: { id: string; display_name: string | null; email: string | null }) => {
      userMap[u.id] = { full_name: u.display_name, email: u.email };
    });
  }

  const commentsByPost: Record<string, Array<{ id: string; content: string; likes_count: number; created_at: string; author: string }>> = {};
  (comments ?? []).forEach((c: { id: string; post_id: string; user_id: string; content: string; likes_count: number | null; created_at: string }) => {
    if (!commentsByPost[c.post_id]) commentsByPost[c.post_id] = [];
    const author = userMap[c.user_id];
    commentsByPost[c.post_id].push({
      id: c.id,
      content: c.content,
      likes_count: c.likes_count ?? 0,
      created_at: c.created_at,
      author: author?.full_name || author?.email || 'Unknown',
    });
  });

  return (data ?? []).map((p: { id: string; content: string; category: string | null; likes_count: number | null; comments_count: number | null; image_urls: string[] | null; created_at: string; user_id: string }) => ({
    ...p,
    profiles: userMap[p.user_id] ?? null,
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
