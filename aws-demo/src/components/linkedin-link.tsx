"use client";

import { Button } from "@/components/ui/button";
import { LinkedInIcon } from "@/components/icons/linkedin-icon";

export function LinkedInLink({ profileUrl }: { profileUrl: string }) {
  return (
    <div className="flex flex-col items-center gap-2">
      <a 
        href={profileUrl} 
        target="_blank" 
        rel="noopener noreferrer"
        className="inline-block"
      >
        <div className="rounded-full p-[2px] bg-gradient-to-r from-[#001f3f] to-[#2774AE]">
          <Button variant="outline" className="rounded-full h-14 w-14 flex items-center justify-center apple-button bg-white border-0 hover:bg-white/90">
            <LinkedInIcon className="h-8 w-8 text-[#0077B5]" />
          </Button>
        </div>
      </a>
      <span className="text-sm text-gray-500">Connect on LinkedIn</span>
    </div>
  );
} 