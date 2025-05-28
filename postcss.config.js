/**
 * PostCSS Configuration
 *
 * This file configures PostCSS plugins used in the build process:
 * - @tailwindcss/postcss: Processes Tailwind CSS directives
 * - autoprefixer: Automatically adds vendor prefixes to CSS properties
 *
 * PostCSS transforms CSS with JavaScript plugins to make styles
 * more compatible across browsers and optimize performance.
 */

module.exports = {
  plugins: {
    // Process Tailwind CSS directives and generate utility classes
    '@tailwindcss/postcss': {},

    // Add vendor prefixes to CSS properties for better browser compatibility
    autoprefixer: {},
  },
}
