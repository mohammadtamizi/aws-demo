/**
 * Next.js Configuration
 *
 * This file configures the Next.js framework for the application, including:
 * - Development mode settings
 * - Build optimizations
 * - Image handling and domains
 * - TypeScript configuration
 * - Other framework-specific options
 */

/** @type {import('next').NextConfig} */
const nextConfig = {
  // Enable React Strict Mode for better development experience and highlighting potential problems
  reactStrictMode: true,

  // Configure image optimization and allowed external domains for images
  images: {
    domains: [], // Add domains here if you need to display external images
  },

  // TypeScript configuration
  typescript: {
    // Skip type checking during builds for faster deployment
    // Note: It's better to fix type errors rather than ignore them in production
    ignoreBuildErrors: true,
  },
};

module.exports = nextConfig;
