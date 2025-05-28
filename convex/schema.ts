/**
 * Convex Database Schema Definition
 *
 * This file defines the data schema for the Convex database.
 * It specifies the tables, fields, and data types used in the application.
 *
 * The schema is currently empty after removing the TodoList functionality,
 * but is ready to be expanded with new tables as needed.
 *
 * Convex automatically enforces this schema for all database operations.
 */
import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

/**
 * Application Schema
 *
 * Define your database tables and their fields here.
 * Example:
 *
 * users: defineTable({
 *   name: v.string(),
 *   email: v.string(),
 *   role: v.string(),
 *   createdAt: v.number(),
 * })
 */
export default defineSchema({
  // Schema is now empty after removing todos
});
