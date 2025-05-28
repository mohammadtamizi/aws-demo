"use client";

import { Button } from "@/components/ui/button";
import { Download } from "lucide-react";

export function DownloadButton({ fileUrl }: { fileUrl: string }) {
  return (
    <a href={fileUrl} download className="inline-block">
      <Button className="bg-gradient-to-r from-[#001f3f] to-[#2774AE] text-white py-6 px-8 rounded-full flex items-center gap-2 apple-button">
        <Download className="h-5 w-5" />
        <span>Download Presentation</span>
      </Button>
    </a>
  );
}
