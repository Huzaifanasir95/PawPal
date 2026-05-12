export const dynamic = 'force-dynamic';

import { createClient } from '@supabase/supabase-js';
import StatCard from '@/components/StatCard';

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
    { count: bookings },
    { count: orders },
    { count: products },
    { count: caregivers },
    { count: appointments },
  ] = await Promise.all([
    supabase.from('users').select('*', { count: 'exact', head: true }),
    supabase.from('posts').select('*', { count: 'exact', head: true }),
    supabase.from('events').select('*', { count: 'exact', head: true }),
    supabase.from('adoption_listings').select('*', { count: 'exact', head: true }),
    supabase.from('lost_found_posts').select('*', { count: 'exact', head: true }),
    supabase.from('vet_profiles').select('*', { count: 'exact', head: true }),
    supabase.from('pets').select('*', { count: 'exact', head: true }),
    supabase.from('chats').select('*', { count: 'exact', head: true }),
    supabase.from('service_bookings').select('*', { count: 'exact', head: true }),
    supabase.from('orders').select('*', { count: 'exact', head: true }),
    supabase.from('products').select('*', { count: 'exact', head: true }),
    supabase.from('caregiver_profiles').select('*', { count: 'exact', head: true }),
    supabase.from('vet_appointments').select('*', { count: 'exact', head: true }),
  ]);

  return {
    users: users ?? 0, posts: posts ?? 0, events: events ?? 0,
    adoptions: adoptions ?? 0, lostFound: lostFound ?? 0, vets: vets ?? 0,
    pets: pets ?? 0, chats: chats ?? 0, bookings: bookings ?? 0,
    orders: orders ?? 0, products: products ?? 0, caregivers: caregivers ?? 0,
    appointments: appointments ?? 0,
  };
}

export default async function DashboardPage() {
  const stats = await getStats();
  const now = new Date();

  return (
    <div className="min-h-screen bg-gray-50/60 px-8 pt-4 pb-8">

      {/* ── Header ── */}
      <div className="mb-6 flex items-center justify-between">
        <div>
          <h1 className="mt-0.5 text-2xl font-black text-gray-900 tracking-tight">Dashboard</h1>
          <p className="mt-1 text-sm text-gray-500">
            {now.toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}
          </p>
        </div>
      </div>

      {/* ── Users & Community ── */}
      <div className="mb-2">
        <p className="mb-3 text-[11px] font-bold uppercase tracking-widest text-gray-400">
          Users &amp; Community
        </p>
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
          <StatCard title="Total Users"        value={stats.users}  icon="Users"         color="teal"   trend={5}  index={0} />
          <StatCard title="Registered Pets"    value={stats.pets}   icon="Dog"           color="teal"              index={1} />
          <StatCard title="Community Posts"    value={stats.posts}  icon="FileText"      color="blue"   trend={12} index={2} />
          <StatCard title="Chat Conversations" value={stats.chats}  icon="MessageSquare" color="blue"              index={3} />
        </div>
      </div>

      {/* ── Services ── */}
      <div className="mb-2 mt-6">
        <p className="mb-3 text-[11px] font-bold uppercase tracking-widest text-gray-400">
          Services
        </p>
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
          <StatCard title="Registered Vets"  value={stats.vets}         icon="Stethoscope"  color="green"  trend={8} index={4} />
          <StatCard title="Vet Appointments" value={stats.appointments} icon="ClipboardList" color="green"           index={5} />
          <StatCard title="Caregivers"       value={stats.caregivers}   icon="Briefcase"    color="purple"           index={6} />
          <StatCard title="Care Bookings"    value={stats.bookings}     icon="Calendar"     color="purple"           index={7} />
        </div>
      </div>

      {/* ── Marketplace ── */}
      <div className="mb-2 mt-6">
        <p className="mb-3 text-[11px] font-bold uppercase tracking-widest text-gray-400">
          Marketplace &amp; Community Hub
        </p>
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
          <StatCard title="Products Listed"   value={stats.products}  icon="Package"     color="orange"        index={8}  />
          <StatCard title="Orders Placed"     value={stats.orders}    icon="ShoppingBag" color="orange" trend={3} index={9}  />
          <StatCard title="Adoption Listings" value={stats.adoptions} icon="Heart"       color="red"           index={10} />
          <StatCard title="Lost &amp; Found"  value={stats.lostFound} icon="Search"      color="red"           index={11} />
        </div>
      </div>

    </div>
  );
}
