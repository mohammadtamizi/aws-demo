"use client";

import { ConvexProvider, ConvexReactClient } from "convex/react";
import { ReactNode } from "react";
import React from "react";

// Use optional chaining and provide a fallback to prevent errors if the env var is missing
const convexUrl = process.env.NEXT_PUBLIC_CONVEX_URL || "";

// Initialize client only if URL is available
const convex = new ConvexReactClient(convexUrl);

export function ConvexClientProvider({
  children
}: {
  children: ReactNode;
}) {
  return (
    <ConvexProvider client={convex}>
        {children}
    </ConvexProvider>
  );
} 