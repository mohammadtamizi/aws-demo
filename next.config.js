/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  images: {
    domains: ['images.clerk.dev'],
  },
  typescript: {
    ignoreBuildErrors: true,
  },
};

module.exports = nextConfig; 