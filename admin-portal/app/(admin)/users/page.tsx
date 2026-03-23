import { createClient } from '@supabase/supabase-js';
import { Users } from 'lucide-react';

export const dynamic = 'force-dynamic';
import UsersClient from './UsersClient';

async function getUsers() {
  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { auth: { persistSession: false } }
  );

  const { data, error } = await supabase
    .from('users')
    .select('id, display_name, email, account_type, user_role, avatar_url, is_active, created_at, updated_at')
    .order('created_at', { ascending: false })
    .limit(500);

  if (error) throw error;

  const userIds = (data ?? []).map((u: { id: string }) => u.id);
  const [{ data: pets }, { data: posts }] = await Promise.all([
    supabase.from('pets').select('owner_id').in('owner_id', userIds),
    supabase.from('posts').select('user_id').in('user_id', userIds),
  ]);
  const petCounts: Record<string, number> = {};
  (pets ?? []).forEach((p: { owner_id: string }) => { petCounts[p.owner_id] = (petCounts[p.owner_id] || 0) + 1; });
  const postCounts: Record<string, number> = {};
  (posts ?? []).forEach((p: { user_id: string }) => { postCounts[p.user_id] = (postCounts[p.user_id] || 0) + 1; });

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  return (data ?? []).map((u: any) => ({
    ...u,
    pets_count: petCounts[u.id] || 0,
    posts_count: postCounts[u.id] || 0,
  }));
}

export default async function UsersPage() {
  const users = await getUsers();
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const vets = users.filter((u: any) => u.user_role === 'vet').length;

  return (
    <div className="p-8">
      <div className="mb-6 flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Users</h1>
          <p className="mt-1 text-sm text-gray-500">
            {users.length} registered users
          </p>
        </div>
        <div className="flex items-center gap-3">
          <div className="flex items-center gap-2 rounded-xl bg-teal-50 px-4 py-2">
            <Users className="h-4 w-4 text-teal-600" />
            <span className="text-sm font-semibold text-teal-700">{users.length}</span>
          </div>
          <div className="rounded-xl bg-purple-50 px-4 py-2 text-sm">
            <span className="font-semibold text-purple-700">{vets}</span>
            <span className="ml-1 text-purple-600">vets</span>
          </div>
        </div>
      </div>

      <UsersClient users={users} />
    </div>
  );
}
