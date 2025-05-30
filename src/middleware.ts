import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

// This middleware doesn't do anything special since we removed Clerk
export function middleware(request: NextRequest) {
  return NextResponse.next();
}

// Only use this middleware on specific routes if needed
export const config = {
  matcher: ["/((?!.+\\.[\\w]+$|_next).*)", "/", "/(api|trpc)(.*)"],
}; 