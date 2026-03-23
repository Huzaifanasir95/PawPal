'use client';

import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from 'recharts';
import { timeAgo, truncate } from '@/lib/utils';

interface ChartDataPoint {
  day: string;
  count: number;
}

interface RecentPost {
  id: string;
  content: string;
  category: string | null;
  created_at: string;
}

interface RecentUser {
  id: string;
  display_name: string | null;
  email: string | null;
  created_at: string;
}

interface DashboardChartsProps {
  chartData: ChartDataPoint[];
  recentPosts: RecentPost[];
  recentUsers: RecentUser[];
}

const categoryColors: Record<string, string> = {
  general: 'bg-gray-100 text-gray-600',
  dogs: 'bg-amber-100 text-amber-700',
  cats: 'bg-orange-100 text-orange-700',
  health: 'bg-green-100 text-green-700',
  training: 'bg-blue-100 text-blue-700',
  nutrition: 'bg-purple-100 text-purple-700',
  funny: 'bg-yellow-100 text-yellow-700',
  questions: 'bg-teal-100 text-teal-700',
};

export default function DashboardCharts({
  chartData,
  recentPosts,
  recentUsers,
}: DashboardChartsProps) {
  return (
    <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
      {/* Bar chart — spans 2 cols */}
      <div className="lg:col-span-2 rounded-2xl border border-gray-100 bg-white p-6 shadow-sm">
        <h2 className="mb-1 text-base font-semibold text-gray-900">Posts This Week</h2>
        <p className="mb-4 text-xs text-gray-400">Daily post activity over the last 7 days</p>
        <ResponsiveContainer width="100%" height={220}>
          <BarChart data={chartData} margin={{ top: 0, right: 0, left: -20, bottom: 0 }}>
            <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
            <XAxis
              dataKey="day"
              tick={{ fontSize: 12, fill: '#9ca3af' }}
              axisLine={false}
              tickLine={false}
            />
            <YAxis
              tick={{ fontSize: 12, fill: '#9ca3af' }}
              axisLine={false}
              tickLine={false}
              allowDecimals={false}
            />
            <Tooltip
              contentStyle={{
                borderRadius: '8px',
                border: '1px solid #e5e7eb',
                fontSize: '12px',
              }}
            />
            <Bar dataKey="count" fill="#2C6E69" radius={[4, 4, 0, 0]} name="Posts" />
          </BarChart>
        </ResponsiveContainer>
      </div>

      {/* Recent signups */}
      <div className="rounded-2xl border border-gray-100 bg-white p-6 shadow-sm">
        <h2 className="mb-4 text-base font-semibold text-gray-900">Recent Signups</h2>
        <ul className="space-y-3">
          {recentUsers.length === 0 && (
            <li className="text-sm text-gray-400">No users yet</li>
          )}
          {recentUsers.map((u) => (
            <li key={u.id} className="flex items-center gap-3">
              <div className="flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-full bg-[#B3E0DB] text-[#2C6E69] text-xs font-bold uppercase">
                {(u.display_name || u.email || '?')[0]}
              </div>
              <div className="min-w-0 flex-1">
                <p className="truncate text-sm font-medium text-gray-800">
                  {u.display_name || 'No name'}
                </p>
                <p className="truncate text-xs text-gray-400">{timeAgo(u.created_at)}</p>
              </div>
            </li>
          ))}
        </ul>
      </div>

      {/* Recent posts */}
      <div className="lg:col-span-3 rounded-2xl border border-gray-100 bg-white p-6 shadow-sm">
        <h2 className="mb-4 text-base font-semibold text-gray-900">Recent Posts</h2>
        <ul className="divide-y divide-gray-50">
          {recentPosts.length === 0 && (
            <li className="py-3 text-sm text-gray-400">No posts yet</li>
          )}
          {recentPosts.map((p) => {
            const cat = p.category || 'general';
            const colorClass = categoryColors[cat] ?? categoryColors.general;
            return (
              <li key={p.id} className="flex items-start gap-3 py-3">
                <span
                  className={`mt-0.5 inline-flex flex-shrink-0 items-center rounded-full px-2 py-0.5 text-[10px] font-medium capitalize ${colorClass}`}
                >
                  {cat}
                </span>
                <p className="flex-1 text-sm text-gray-700">
                  {truncate(p.content, 100)}
                </p>
                <span className="flex-shrink-0 text-xs text-gray-400">
                  {timeAgo(p.created_at)}
                </span>
              </li>
            );
          })}
        </ul>
      </div>
    </div>
  );
}
