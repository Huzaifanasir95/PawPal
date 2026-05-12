'use client';

import { useEffect, useRef, useState } from 'react';
import { DotLottieReact } from '@lottiefiles/dotlottie-react';
import type { DotLottie } from '@lottiefiles/dotlottie-web';

/* ── Corgi on the left panel ─────────────────────────────────────────────── */
export function AnimatedDogLottie({ size = 200 }: { size?: number }) {
  return (
    <div style={{ width: size, height: size }}>
      <DotLottieReact
        src="https://lottie.host/c6aa0f69-82e1-4e03-9435-0e095b8fa36d/FEXfqCfumS.lottie"
        loop
        autoplay
        style={{ width: '100%', height: '100%' }}
      />
    </div>
  );
}

/* ── Shiba that reacts to password input ────────────────────────────────── */
interface ShibaPasswordProps {
  typing: boolean;   // focused + has content
  revealed: boolean; // eye icon toggled on
}

export function ShibaPasswordPet({ typing, revealed }: ShibaPasswordProps) {
  const dlRef = useRef<DotLottie | null>(null);
  const [ready, setReady] = useState(false);

  function onRef(dl: DotLottie | null) {
    dlRef.current = dl;
    if (dl) {
      dl.addEventListener('ready', () => setReady(true));
    }
  }

  useEffect(() => {
    const dl = dlRef.current;
    if (!dl || !ready) return;

    if (typing && !revealed) {
      // typing with password hidden → shiba hides (play in reverse: peek → behind wall)
      dl.setMode('reverse');
      dl.play();
    } else {
      // idle OR password revealed → shiba peeks out (play forward: behind wall → peek)
      dl.setMode('forward');
      dl.play();
    }
  }, [typing, revealed, ready]);

  return (
    <div style={{ width: 150, height: 150 }}>
      <DotLottieReact
        dotLottieRefCallback={onRef}
        src="https://lottie.host/892734ca-91c7-4abb-9dea-d836a5cdd09f/KolbEWxhbb.lottie"
        loop={false}
        autoplay={false}
        style={{ width: '100%', height: '100%' }}
      />
    </div>
  );
}
