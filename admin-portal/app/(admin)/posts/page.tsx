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
    .select('id, content, category, likes_count, comments_count, created_at, user_id')
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

  return (data ?? []).map((p: { id: string; content: string; category: string | null; likes_count: number | null; comments_count: number | null; created_at: string; user_id: string }) => ({
    ...p,
    profiles: userMap[p.user_id] ?? null,
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
