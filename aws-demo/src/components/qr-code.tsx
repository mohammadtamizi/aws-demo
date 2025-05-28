"use client";

import { Card, CardContent } from "@/components/ui/card";
import { QRCodeSVG } from "qrcode.react";
import { useEffect, useState } from "react";

export function QRCodeDisplay() {
  const [url, setUrl] = useState("");

  useEffect(() => {
    // Set the URL after component mounts to avoid hydration issues
    setUrl(window.location.href);
  }, []);

  return (
    <div className="flex flex-col items-center gap-2">
      <div className="rounded-xl p-[2px] bg-gradient-to-r from-[#001f3f] to-[#6ea8d3]">
        <Card className="w-fit bg-white">
          <CardContent className="p-6">
            <QRCodeSVG value={url} size={200} />
          </CardContent>
        </Card>
      </div>
      <p className="text-sm text-gray-500">Scan to access this page</p>
    </div>
  );
} 