'use client';

import { useEffect, useRef, useState } from 'react';
import { motion } from 'framer-motion';
import { cn } from '@/lib/utils';
import { TrendingUp, TrendingDown, Users, FileText, Calendar, Heart, Search, Stethoscope, Dog, MessageSquare, Package, ShoppingBag, Briefcase, ClipboardList } from 'lucide-react';

/* All allowed icon keys — resolved inside the client component */
export type StatIconKey =
  | 'Users' | 'FileText' | 'Calendar' | 'Heart' | 'Search'
  | 'Stethoscope' | 'Dog' | 'MessageSquare' | 'Package'
  | 'ShoppingBag' | 'Briefcase' | 'ClipboardList';

const iconMap: Record<StatIconKey, React.ElementType> = {
  Users, FileText, Calendar, Heart, Search,
  Stethoscope, Dog, MessageSquare, Package,
  ShoppingBag, Briefcase, ClipboardList,
};

interface StatCardProps {
  title: string;
  value: number;
  icon: StatIconKey;
  trend?: number;
  color?: 'teal' | 'blue' | 'green' | 'purple' | 'orange' | 'red';
  index?: number;
}

const colorMap = {
  teal:   { bg: 'bg-teal-50',    icon: 'text-teal-600',    bar: 'bg-teal-500',    ring: 'ring-teal-100'    },
  blue:   { bg: 'bg-blue-50',    icon: 'text-blue-600',    bar: 'bg-blue-500',    ring: 'ring-blue-100'    },
  green:  { bg: 'bg-emerald-50', icon: 'text-emerald-600', bar: 'bg-emerald-500', ring: 'ring-emerald-100' },
  purple: { bg: 'bg-violet-50',  icon: 'text-violet-600',  bar: 'bg-violet-500',  ring: 'ring-violet-100'  },
  orange: { bg: 'bg-orange-50',  icon: 'text-orange-600',  bar: 'bg-orange-500',  ring: 'ring-orange-100'  },
  red:    { bg: 'bg-rose-50',    icon: 'text-rose-600',    bar: 'bg-rose-500',    ring: 'ring-rose-100'    },
};

function useCountUp(target: number, duration = 1000, delay = 0) {
  const [count, setCount] = useState(0);
  const raf = useRef<number | null>(null);
  useEffect(() => {
    const timeout = setTimeout(() => {
      const start = performance.now();
      const step = (now: number) => {
        const progress = Math.min((now - start) / duration, 1);
        const eased = 1 - Math.pow(1 - progress, 3);
        setCount(Math.round(eased * target));
        if (progress < 1) raf.current = requestAnimationFrame(step);
      };
      raf.current = requestAnimationFrame(step);
    }, delay);
    return () => {
      clearTimeout(timeout);
      if (raf.current) cancelAnimationFrame(raf.current);
    };
  }, [target, duration, delay]);
  return count;
}

export default function StatCard({ title, value, icon, trend, color = 'teal', index = 0 }: StatCardProps) {
  const c = colorMap[color];
  const Icon = iconMap[icon];
  const displayValue = useCountUp(value, 1000, index * 80);

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ type: 'tween', duration: 0.4, delay: index * 0.06 }}
      whileHover={{ y: -3, transition: { duration: 0.2 } }}
      className="relative overflow-hidden rounded-2xl bg-white border border-gray-100 p-5 shadow-sm cursor-default group"
    >
      <div className="flex items-start justify-between">
        <motion.div
          className={cn('rounded-xl p-2.5 ring-4', c.bg, c.icon, c.ring)}
          whileHover={{ scale: 1.1, rotate: 5 }}
          transition={{ type: 'spring', stiffness: 300 }}
        >
          <Icon className="h-5 w-5" />
        </motion.div>

        {trend !== undefined && (
          <motion.div
            initial={{ opacity: 0, x: 10 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ type: 'tween', delay: index * 0.06 + 0.3 }}
            className={cn(
              'flex items-center gap-1 rounded-full px-2 py-0.5 text-xs font-semibold',
              trend >= 0 ? 'bg-emerald-50 text-emerald-600' : 'bg-rose-50 text-rose-600'
            )}
          >
            {trend >= 0 ? <TrendingUp className="h-3 w-3" /> : <TrendingDown className="h-3 w-3" />}
            {Math.abs(trend)}%
          </motion.div>
        )}
      </div>

      <div className="mt-4">
        <p className="text-3xl font-black text-gray-900 tabular-nums tracking-tight">
          {displayValue.toLocaleString()}
        </p>
        <p className="mt-1 text-sm font-medium text-gray-500">{title}</p>
      </div>

      {/* Bottom accent bar */}
      <motion.div
        className={cn('absolute bottom-0 left-0 h-0.5 rounded-full', c.bar)}
        initial={{ width: 0 }}
        animate={{ width: '100%' }}
        transition={{ type: 'tween', duration: 0.8, delay: index * 0.06 + 0.2 }}
      />
    </motion.div>
  );
}
