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
    .select('id, display_name, email, created_at, updated_at')
    .order('created_at', { ascending: false })
    .limit(100);

  if (error) throw error;
  return data ?? [];
}

export default async function UsersPage() {
  const users = await getUsers();

  return (
    <div className="p-8">
      <div className="mb-6 flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Users</h1>
          <p className="mt-1 text-sm text-gray-500">
            {users.length} registered users
          </p>
        </div>
        <div className="flex items-center gap-2 rounded-xl bg-teal-50 px-4 py-2">
          <Users className="h-4 w-4 text-teal-600" />
          <span className="text-sm font-semibold text-teal-700">{users.length}</span>
        </div>
      </div>

      <UsersClient users={users} />
    </div>
  );
}
