/**
 * Custom Next.js App Component
 *
 * This is the top-level component that wraps all pages in the application
 * It's responsible for:
 * - Applying global styles
 * - Wrapping the application with provider components
 * - Persisting layout between page changes
 */
import type { AppProps } from 'next/app';
import '@/app/styles/globals.css';
import { Providers } from '@/app/providers';

/**
 * App Component
 *
 * @param {AppProps} props - Standard Next.js app props containing Component and pageProps
 * @returns {JSX.Element} The rendered application with providers
 */
export default function App({ Component, pageProps }: AppProps) {
  return (
    <Providers>
      {/* Renders the current page component with its props */}
      <Component {...pageProps} />
    </Providers>
  );
}
