import { NextRequest, NextResponse } from 'next/server';
import { cookies } from 'next/headers';

const SESSION_COOKIE = 'pawpal_admin_session';

export async function POST(req: NextRequest) {
  const cookieStore = await cookies();
  cookieStore.delete(SESSION_COOKIE);
  const origin = req.nextUrl.origin;
  // Use 303 See Other so the browser always follows with GET, not POST
  return NextResponse.redirect(new URL('/login', origin), { status: 303 });
}
