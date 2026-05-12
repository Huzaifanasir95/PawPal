'use client';

import { motion } from 'framer-motion';
import { timeAgo, truncate } from '@/lib/utils';
import { Tag } from 'lucide-react';

interface ChartDataPoint { day: string; count: number }
interface RecentPost { id: string; content: string; category: string | null; created_at: string }
interface DashboardChartsProps {
  chartData: ChartDataPoint[];
  recentPosts: RecentPost[];
}

const categoryColors: Record<string, { bg: string; text: string; dot: string }> = {
  general:   { bg: 'bg-slate-100',   text: 'text-slate-600',   dot: 'bg-slate-400'   },
  dogs:      { bg: 'bg-amber-100',   text: 'text-amber-700',   dot: 'bg-amber-500'   },
  cats:      { bg: 'bg-orange-100',  text: 'text-orange-700',  dot: 'bg-orange-500'  },
  health:    { bg: 'bg-emerald-100', text: 'text-emerald-700', dot: 'bg-emerald-500' },
  training:  { bg: 'bg-blue-100',    text: 'text-blue-700',    dot: 'bg-blue-500'    },
  nutrition: { bg: 'bg-violet-100',  text: 'text-violet-700',  dot: 'bg-violet-500'  },
  funny:     { bg: 'bg-yellow-100',  text: 'text-yellow-700',  dot: 'bg-yellow-500'  },
  questions: { bg: 'bg-teal-100',    text: 'text-teal-700',    dot: 'bg-teal-500'    },
};

function cardAnim(i: number) {
  return {
    initial: { opacity: 0, y: 24 },
    animate: { opacity: 1, y: 0 },
    transition: { type: 'tween' as const, duration: 0.45, delay: i * 0.08 },
  };
}

export default function DashboardCharts({ chartData, recentPosts }: DashboardChartsProps) {
  const maxCount = Math.max(...chartData.map((d) => d.count), 1);

  return (
    <div className="space-y-6">
      {/* ── Row: Mini bar sparklines + Recent Posts ── */}
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">

        {/* Day-by-day mini bars */}
        <motion.div
          {...cardAnim(0)}
          className="rounded-2xl bg-white border border-gray-100 p-6 shadow-sm"
        >
          <h2 className="text-base font-bold text-gray-900 mb-1">Daily Breakdown</h2>
          <p className="text-xs text-gray-400 mb-5">Posts per day this week</p>
          <div className="space-y-2.5">
            {chartData.map((d, i) => (
              <div key={d.day} className="flex items-center gap-3">
                <span className="w-7 text-xs font-medium text-gray-400">{d.day}</span>
                <div className="flex-1 h-5 rounded-full bg-gray-50 overflow-hidden">
                  <motion.div
                    className="h-full rounded-full bg-gradient-to-r from-teal-500 to-teal-400"
                    initial={{ width: 0 }}
                    animate={{ width: `${(d.count / maxCount) * 100}%` }}
                    transition={{ duration: 0.7, delay: 0.4 + i * 0.07, ease: 'easeOut' }}
                  />
                </div>
                <span className="w-5 text-right text-xs font-bold text-gray-700">{d.count}</span>
              </div>
            ))}
          </div>
        </motion.div>

        {/* Recent posts */}
        <motion.div
          {...cardAnim(1)}
          className="lg:col-span-2 rounded-2xl bg-white border border-gray-100 p-6 shadow-sm"
        >
          <div className="flex items-center justify-between mb-5">
            <h2 className="text-base font-bold text-gray-900">Recent Posts</h2>
            <div className="flex items-center gap-1.5 rounded-full bg-violet-50 px-3 py-1 text-xs font-semibold text-violet-700">
              <Tag className="h-3 w-3" />
              Latest
            </div>
          </div>
          <ul className="divide-y divide-gray-50">
            {recentPosts.length === 0 && (
              <li className="py-6 text-sm text-gray-400 text-center">No posts yet</li>
            )}
            {recentPosts.map((p, i) => {
              const cat = p.category || 'general';
              const c = categoryColors[cat] ?? categoryColors.general;
              return (
                <motion.li
                  key={p.id}
                  initial={{ opacity: 0, y: 8 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.35 + i * 0.07 }}
                  className="flex items-start gap-3 py-3 group"
                >
                  <span className={`mt-0.5 inline-flex flex-shrink-0 items-center gap-1.5 rounded-full px-2.5 py-1 text-[10px] font-bold capitalize ${c.bg} ${c.text}`}>
                    <span className={`h-1.5 w-1.5 rounded-full ${c.dot}`} />
                    {cat}
                  </span>
                  <p className="flex-1 text-sm text-gray-600 group-hover:text-gray-900 transition-colors leading-relaxed">
                    {truncate(p.content, 90)}
                  </p>
                  <span className="flex-shrink-0 text-[11px] text-gray-400 whitespace-nowrap mt-0.5">
                    {timeAgo(p.created_at)}
                  </span>
                </motion.li>
              );
            })}
          </ul>
        </motion.div>
      </div>
    </div>
  );
}
