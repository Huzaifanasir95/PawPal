import {
  Users,
  FileText,
  Calendar,
  Heart,
  Search,
  Stethoscope,
  Dog,
  MessageSquare,
} from 'lucide-react';

export const dynamic = 'force-dynamic';
import { createClient } from '@supabase/supabase-js';
import StatCard from '@/components/StatCard';
import DashboardCharts from './DashboardCharts';

async function getStats() {
  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { auth: { persistSession: false } }
  );

  const [
    { count: users },
    { count: posts },
    { count: events },
    { count: adoptions },
    { count: lostFound },
    { count: vets },
    { count: pets },
    { count: chats },
    { data: recentPosts },
    { data: recentUsers },
  ] = await Promise.all([
    supabase.from('users').select('*', { count: 'exact', head: true }),
    supabase.from('posts').select('*', { count: 'exact', head: true }),
    supabase.from('events').select('*', { count: 'exact', head: true }),
    supabase.from('adoption_listings').select('*', { count: 'exact', head: true }),
    supabase.from('lost_found_posts').select('*', { count: 'exact', head: true }),
    supabase.from('vet_profiles').select('*', { count: 'exact', head: true }),
    supabase.from('pets').select('*', { count: 'exact', head: true }),
    supabase.from('chats').select('*', { count: 'exact', head: true }),
    supabase
      .from('posts')
      .select('id, content, category, created_at')
      .order('created_at', { ascending: false })
      .limit(5),
    supabase
      .from('users')
      .select('id, display_name, email, created_at')
      .order('created_at', { ascending: false })
      .limit(5),
  ]);

  // Posts per day for last 7 days
  const { data: postsByDay } = await supabase
    .from('posts')
    .select('created_at')
    .gte('created_at', new Date(Date.now() - 7 * 86400000).toISOString());

  const dayCounts: Record<string, number> = {};
  for (let i = 6; i >= 0; i--) {
    const d = new Date(Date.now() - i * 86400000);
    const key = d.toLocaleDateString('en-US', { weekday: 'short' });
    dayCounts[key] = 0;
  }
  (postsByDay || []).forEach((p) => {
    const key = new Date(p.created_at).toLocaleDateString('en-US', { weekday: 'short' });
    if (key in dayCounts) dayCounts[key]++;
  });
  const chartData = Object.entries(dayCounts).map(([day, count]) => ({ day, count }));

  return {
    users: users ?? 0,
    posts: posts ?? 0,
    events: events ?? 0,
    adoptions: adoptions ?? 0,
    lostFound: lostFound ?? 0,
    vets: vets ?? 0,
    pets: pets ?? 0,
    chats: chats ?? 0,
    recentPosts: recentPosts ?? [],
    recentUsers: recentUsers ?? [],
    chartData,
  };
}

export default async function DashboardPage() {
  const stats = await getStats();

  return (
    <div className="p-8">
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
        <p className="mt-1 text-sm text-gray-500">
          Welcome back &mdash; here&apos;s what&apos;s happening with PawPal today.
        </p>
      </div>

      {/* Stats Grid */}
      <div className="mb-8 grid grid-cols-1 gap-5 sm:grid-cols-2 xl:grid-cols-3">
        <StatCard
          title="Total Users"
          value={stats.users.toLocaleString()}
          icon={Users}
          color="teal"
          trend={5}
        />
        <StatCard
          title="Community Posts"
          value={stats.posts.toLocaleString()}
          icon={FileText}
          color="blue"
          trend={12}
        />
        <StatCard
          title="Events"
          value={stats.events.toLocaleString()}
          icon={Calendar}
          color="purple"
        />
        <StatCard
          title="Adoption Listings"
          value={stats.adoptions.toLocaleString()}
          icon={Heart}
          color="orange"
          trend={3}
        />
        <StatCard
          title="Lost & Found"
          value={stats.lostFound.toLocaleString()}
          icon={Search}
          color="red"
        />
        <StatCard
          title="Registered Vets"
          value={stats.vets.toLocaleString()}
          icon={Stethoscope}
          color="green"
          trend={8}
        />
        <StatCard
          title="Registered Pets"
          value={stats.pets.toLocaleString()}
          icon={Dog}
          color="teal"
        />
        <StatCard
          title="Chat Conversations"
          value={stats.chats.toLocaleString()}
          icon={MessageSquare}
          color="blue"
        />
      </div>

      {/* Charts + Recent Activity */}
      <DashboardCharts
        chartData={stats.chartData}
        recentPosts={stats.recentPosts}
        recentUsers={stats.recentUsers}
      />
    </div>
  );
}
