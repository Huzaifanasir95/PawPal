'use client';

import { useState, FormEvent, useEffect, useRef } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { Eye, EyeOff, ArrowRight } from 'lucide-react';
import { AnimatedDogLottie, ShibaPasswordPet } from './LottiePet';
import {
  motion,
  AnimatePresence,
  useMotionValue,
  useTransform,
  useSpring,
} from 'framer-motion';

/* ─── Paw SVG ───────────────────────────────────────────────────────────── */
function PawIcon({ className, style }: { className?: string; style?: React.CSSProperties }) {
  return (
    <svg viewBox="0 0 60 60" className={className} style={style} fill="currentColor">
      <ellipse cx="30" cy="38" rx="15" ry="13" />
      <ellipse cx="14" cy="25" rx="6.5" ry="8.5" />
      <ellipse cx="46" cy="25" rx="6.5" ry="8.5" />
      <ellipse cx="22" cy="18" rx="5.5" ry="7" />
      <ellipse cx="38" cy="18" rx="5.5" ry="7" />
    </svg>
  );
}

/* ─── Subtle floating paw particles ────────────────────────────────────── */
function PawParticles() {
  const items = [
    { x: '8%',  y: '12%', size: 14, opacity: 0.07, rotate: -20, delay: 0 },
    { x: '18%', y: '45%', size: 10, opacity: 0.05, rotate: 15,  delay: 0.4 },
    { x: '32%', y: '22%', size: 18, opacity: 0.06, rotate: -8,  delay: 0.8 },
    { x: '55%', y: '60%', size: 12, opacity: 0.05, rotate: 30,  delay: 0.2 },
    { x: '42%', y: '80%', size: 16, opacity: 0.07, rotate: -15, delay: 1.0 },
    { x: '70%', y: '20%', size: 10, opacity: 0.04, rotate: 10,  delay: 0.6 },
    { x: '60%', y: '40%', size: 14, opacity: 0.05, rotate: -25, delay: 1.2 },
  ];
  return (
    <>
      {items.map((p, i) => (
        <motion.div
          key={i}
          className="absolute text-white pointer-events-none"
          style={{ left: p.x, top: p.y }}
          initial={{ opacity: 0, scale: 0, rotate: p.rotate }}
          animate={{ opacity: p.opacity, scale: 1, rotate: p.rotate }}
          transition={{ duration: 0.8, delay: p.delay }}
        >
          <PawIcon style={{ width: p.size, height: p.size }} />
        </motion.div>
      ))}
    </>
  );
}

/* ─── Background network circles ────────────────────────────────────────── */
function BgCircles() {
  return (
    <svg className="absolute inset-0 w-full h-full pointer-events-none" xmlns="http://www.w3.org/2000/svg">
      <circle cx="38%" cy="50%" r="180" fill="none" stroke="rgba(255,255,255,0.04)" strokeWidth="1" />
      <circle cx="38%" cy="50%" r="300" fill="none" stroke="rgba(255,255,255,0.03)" strokeWidth="1" />
      <circle cx="38%" cy="50%" r="420" fill="none" stroke="rgba(255,255,255,0.02)" strokeWidth="1" />
    </svg>
  );
}

/* ─── Main page ─────────────────────────────────────────────────────────── */
export default function LoginPage() {
  const router = useRouter();
  const [password, setPassword] = useState('');
  const [showPw, setShowPw] = useState(false);
  const [pwFocused, setPwFocused] = useState(false);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [shake, setShake] = useState(false);

  useEffect(() => { router.prefetch('/dashboard'); }, [router]);

  const cardRef = useRef<HTMLDivElement>(null);
  const mouseX = useMotionValue(0);
  const mouseY = useMotionValue(0);
  const rotateX = useSpring(useTransform(mouseY, [-200, 200], [6, -6]), { stiffness: 120, damping: 20 });
  const rotateY = useSpring(useTransform(mouseX, [-200, 200], [-6, 6]), { stiffness: 120, damping: 20 });

  function onCardMouseMove(e: React.MouseEvent<HTMLDivElement>) {
    const rect = cardRef.current?.getBoundingClientRect();
    if (!rect) return;
    mouseX.set(e.clientX - rect.left - rect.width / 2);
    mouseY.set(e.clientY - rect.top - rect.height / 2);
  }

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      const res = await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ password }),
      });
      if (res.ok) {
        router.push('/dashboard');
      } else {
        const data = await res.json();
        setError(data.error || 'Invalid credentials');
        setShake(true);
        setTimeout(() => setShake(false), 700);
      }
    } catch {
      setError('Network error — please try again');
      setShake(true);
      setTimeout(() => setShake(false), 700);
    } finally {
      setLoading(false);
    }
  }

  const shibaTyping = pwFocused && password.length > 0;
  const shibaRevealed = showPw;

  return (
    <div
      className="relative min-h-screen overflow-hidden flex"
      style={{ background: 'linear-gradient(135deg, #0a1628 0%, #0d1f3c 45%, #0f2744 100%)' }}
    >
      <Link href="/dashboard" prefetch className="sr-only" aria-hidden tabIndex={-1}>prefetch</Link>

      {/* Shared background */}
      <BgCircles />
      <PawParticles />
      <div className="pointer-events-none absolute inset-0"
        style={{ background: 'radial-gradient(ellipse 60% 80% at 35% 55%, rgba(44,110,105,0.14) 0%, transparent 65%)' }} />

      {/* ════════════════ LEFT PANEL ════════════════ */}
      <div className="relative hidden lg:flex lg:w-[58%] flex-col items-center justify-center">

        {/* Brand */}
        <motion.div
          className="text-center mb-6 z-10"
          initial={{ opacity: 0, y: -24 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.7, ease: 'easeOut' }}
        >
          <h1
            className="text-[96px] font-black leading-none tracking-tight text-white select-none"
            style={{ textShadow: '0 0 80px rgba(79,209,197,0.25)' }}
          >
            Paw<span style={{ color: '#4fd1c5' }}>Pal</span>
          </h1>
          <p className="mt-3 text-sm font-semibold tracking-[0.4em] uppercase select-none"
            style={{ color: 'rgba(255,255,255,0.35)' }}>
            Pet Care Admin Portal
          </p>
        </motion.div>

        {/* Corgi Lottie — big, centered */}
        <motion.div
          className="z-10"
          initial={{ opacity: 0, y: 40 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.9, delay: 0.3, ease: 'easeOut' }}
        >
          <AnimatedDogLottie size={320} />
        </motion.div>

        {/* Decorative paw divider */}
        <motion.div
          className="mt-6 flex items-center gap-3 z-10"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 1.0 }}
        >
          <div className="h-px w-20" style={{ background: 'rgba(255,255,255,0.1)' }} />
          <PawIcon style={{ width: 16, height: 16, color: 'rgba(255,255,255,0.2)' }} />
          <div className="h-px w-20" style={{ background: 'rgba(255,255,255,0.1)' }} />
        </motion.div>

        <motion.p
          className="mt-3 text-xs font-medium"
          style={{ color: 'rgba(255,255,255,0.2)' }}
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 1.2 }}
        >
          Your pet community, managed with care
        </motion.p>
      </div>

      {/* ════════════════ RIGHT FORM PANEL ════════════════ */}
      <div
        className="ml-auto flex w-full lg:w-[42%] items-center justify-center px-8 py-12"
        style={{
          background: 'rgba(255,255,255,0.025)',
          borderLeft: '1px solid rgba(255,255,255,0.06)',
          backdropFilter: 'blur(4px)',
        }}
      >
        <motion.div
          ref={cardRef}
          style={{ rotateX, rotateY, transformPerspective: 1000, width: '100%', maxWidth: 400 }}
          onMouseMove={onCardMouseMove}
          onMouseLeave={() => { mouseX.set(0); mouseY.set(0); }}
        >
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.2, ease: 'easeOut' }}
            className="relative"
          >
            {/* Glow */}
            <div className="absolute -inset-2 rounded-3xl blur-2xl opacity-25 pointer-events-none"
              style={{ background: 'linear-gradient(135deg, #2C6E69, #4fd1c5)' }} />

            {/* Card */}
            <motion.div
              className="relative rounded-3xl bg-white p-8"
              style={{ boxShadow: '0 32px 80px rgba(0,0,0,0.45), 0 4px 20px rgba(0,0,0,0.25)' }}
              animate={shake ? { x: [-10, 10, -8, 8, -5, 5, 0] } : {}}
              transition={shake ? { duration: 0.55 } : {}}
            >
              {/* Mobile logo */}
              <div className="flex items-center gap-3 mb-6 lg:hidden">
                <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-[#2C6E69]">
                  <PawIcon className="w-5 h-5 text-white" />
                </div>
                <span className="text-lg font-black text-gray-900">
                  Paw<span className="text-[#2C6E69]">Pal</span>
                </span>
              </div>

              {/* Header */}
              <div className="mb-5">
                <div className="flex items-center gap-2 mb-3">
                  <div className="flex h-7 w-7 items-center justify-center rounded-lg bg-[#2C6E69]">
                    <PawIcon className="w-3.5 h-3.5 text-white" />
                  </div>
                  <span className="text-[11px] font-bold tracking-widest uppercase text-[#2C6E69]">
                    Secure Access
                  </span>
                </div>
                <h2 className="text-[28px] font-black text-gray-900 leading-tight">Sign In</h2>
                <p className="mt-1.5 text-sm text-gray-400">Enter your admin access key to continue</p>
              </div>

              {/* ── Shiba password pet ── */}
              <div className="flex justify-center mb-2 -mt-1">
                <ShibaPasswordPet typing={shibaTyping} revealed={shibaRevealed} />
              </div>

              <form onSubmit={handleSubmit} className="space-y-4">
                {/* Label + input */}
                <div>
                  <label className="mb-2 block text-[11px] font-bold tracking-widest uppercase text-gray-500">
                    Access Key
                  </label>
                  <div className="relative">
                    <input
                      type={showPw ? 'text' : 'password'}
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      onFocus={() => setPwFocused(true)}
                      onBlur={() => setPwFocused(false)}
                      required
                      autoFocus
                      placeholder="Enter your access key"
                      className="w-full rounded-xl border-2 border-gray-100 bg-gray-50/80 py-3.5 pl-4 pr-12 text-sm text-gray-900 outline-none transition-all duration-200 focus:border-[#2C6E69] focus:bg-white focus:shadow-[0_0_0_4px_rgba(44,110,105,0.1)] placeholder:text-gray-300"
                    />
                    <button
                      type="button"
                      onClick={() => setShowPw(s => !s)}
                      className="absolute right-3.5 top-1/2 -translate-y-1/2 text-gray-300 transition hover:text-[#2C6E69]"
                    >
                      {showPw ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                    </button>
                  </div>
                </div>

                {/* Error */}
                <AnimatePresence>
                  {error && (
                    <motion.div
                      initial={{ opacity: 0, height: 0 }}
                      animate={{ opacity: 1, height: 'auto' }}
                      exit={{ opacity: 0, height: 0 }}
                      className="overflow-hidden"
                    >
                      <div className="flex items-center gap-2.5 rounded-xl border border-red-100 bg-red-50 px-4 py-3">
                        <PawIcon className="w-4 h-4 text-red-400 shrink-0" />
                        <p className="text-sm text-red-600">{error}</p>
                      </div>
                    </motion.div>
                  )}
                </AnimatePresence>

                {/* Button */}
                <motion.button
                  type="submit"
                  disabled={loading || !password}
                  whileHover={password && !loading ? { scale: 1.015, y: -1 } : {}}
                  whileTap={password && !loading ? { scale: 0.985 } : {}}
                  className="group relative w-full overflow-hidden rounded-xl py-3.5 text-sm font-bold text-white disabled:opacity-40 disabled:cursor-not-allowed"
                  style={{
                    background: 'linear-gradient(135deg, #1a4a45 0%, #2C6E69 60%, #3d8f89 100%)',
                    boxShadow: '0 4px 24px rgba(44,110,105,0.4)',
                  }}
                >
                  <motion.span
                    className="pointer-events-none absolute inset-0 skew-x-[-20deg] bg-white/15"
                    animate={{ x: ['-120%', '220%'] }}
                    transition={{ duration: 2.8, repeat: Infinity, ease: 'easeInOut', repeatDelay: 2 }}
                  />
                  <span className="relative flex items-center justify-center gap-2">
                    {loading ? (
                      <>
                        <svg className="animate-spin h-4 w-4" viewBox="0 0 24 24" fill="none">
                          <circle cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="3"
                            strokeDasharray="32" strokeDashoffset="12" strokeLinecap="round" />
                        </svg>
                        Signing in…
                      </>
                    ) : (
                      <>
                        Sign In
                        <ArrowRight className="h-4 w-4 transition-transform group-hover:translate-x-0.5" />
                      </>
                    )}
                  </span>
                </motion.button>
              </form>

              {/* Footer */}
              <p className="mt-6 pt-5 border-t border-gray-50 text-center text-xs text-gray-300">
                © {new Date().getFullYear()} PawPal — Access Restricted
              </p>
            </motion.div>
          </motion.div>
        </motion.div>
      </div>
    </div>
  );
}
