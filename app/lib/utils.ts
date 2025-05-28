/**
 * Utility Functions
 *
 * This file contains utility functions used throughout the application.
 * It provides helper functions for common tasks like CSS class merging.
 */
import { type ClassValue, clsx } from "clsx"
import { twMerge } from "tailwind-merge"

/**
 * Conditional Class Names Utility
 *
 * A helper function that combines multiple class names or conditional class names
 * and merges them with Tailwind CSS classes efficiently.
 *
 * This function leverages:
 * - clsx: For conditional class name concatenation
 * - tailwind-merge: To properly merge Tailwind CSS classes without conflicts
 *
 * @param {...ClassValue[]} inputs - Class names, objects, or arrays to be merged
 * @returns {string} A string of merged class names optimized for Tailwind CSS
 *
 * @example
 * // Basic usage
 * cn('text-red-500', 'bg-blue-500')
 *
 * @example
 * // With conditionals
 * cn('base-class', isActive && 'active-class', {'conditional-class': isTrue})
 */
export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
