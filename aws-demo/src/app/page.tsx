import { QRCodeDisplay } from "@/components/qr-code";
import { DownloadButton } from "@/components/download-button";
import { LinkedInLink } from "@/components/linkedin-link";

export default function Home() {
  // You would replace these with your actual URLs
  const presentationUrl = "/presentation.pdf";
  const linkedInUrl = "https://www.linkedin.com/in/mohammadhassan-tamizi/";

  return (
    <div className="min-h-screen journey-bg text-black">
      {/* Ambient glow effects */}
      <div className="ambient-glow glow-top-right"></div>
      <div className="ambient-glow glow-bottom-left"></div>
      <div className="grid-pattern"></div>
      
      <div className="content-container flex flex-col items-center justify-center py-20 px-4">
        {/* Hero Section */}
        <section className="text-center mb-16 max-w-3xl">
          <h1 className="text-5xl md:text-6xl font-semibold mb-4 tracking-tight bg-gradient-to-r from-[#001f3f] to-[#6ea8d3] inline-block text-transparent bg-clip-text gradient-animate">
            From Localhost to AWS
          </h1>
          <p className="text-xl md:text-2xl max-w-2xl mx-auto bg-gradient-to-r from-[#2a5298] to-[#84c7f7] inline-block text-transparent bg-clip-text font-medium">
            Deploying a Containerized Website with Terraform
          </p>
        </section>

        {/* Main Content Container */}
        <div className="glass-card p-8 w-full max-w-4xl mx-auto mb-16">
          {/* QR Code Section */}
          <section className="mb-12 float-animation float-delay-1">
            <QRCodeDisplay />
          </section>

          {/* Download Button */}
          <section className="mb-12 flex justify-center float-animation float-delay-2">
            <DownloadButton fileUrl={presentationUrl} />
          </section>

          {/* LinkedIn Connection */}
          <section className="mb-8 flex justify-center float-animation float-delay-3">
            <LinkedInLink profileUrl={linkedInUrl} />
          </section>

          {/* Thank You Message */}
          <section className="text-center">
            <p className="text-xl italic text-gray-700">
              Thank you for your interest in this presentation.
            </p>
          </section>
        </div>
      </div>

      {/* Footer */}
      <footer className="fixed bottom-0 left-0 right-0 py-4 bg-white/80 backdrop-blur-sm border-t border-gray-100 z-10">
        <p className="text-center text-xs text-gray-400">
          © {new Date().getFullYear()} • Designed with inspiration from Apple.com
        </p>
      </footer>
    </div>
  );
}
