import { NextRequest, NextResponse } from 'next/server';
import { cookies } from 'next/headers';

const SESSION_COOKIE = 'pawpal_admin_session';
const SESSION_MAX_AGE = 60 * 60 * 8; // 8 hours

export async function POST(req: NextRequest) {
  try {
    const { password } = await req.json();

    const adminSecret = process.env.ADMIN_SECRET;
    if (!adminSecret) {
      return NextResponse.json(
        { error: 'Server misconfiguration: ADMIN_SECRET not set' },
        { status: 500 }
      );
    }

    if (!password || password !== adminSecret) {
      // Constant-time comparison would be ideal, but for simplicity:
      return NextResponse.json({ error: 'Invalid credentials' }, { status: 401 });
    }

    const cookieStore = await cookies();
    cookieStore.set(SESSION_COOKIE, '1', {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      maxAge: SESSION_MAX_AGE,
      path: '/',
    });

    return NextResponse.json({ ok: true });
  } catch {
    return NextResponse.json({ error: 'Bad request' }, { status: 400 });
  }
}
