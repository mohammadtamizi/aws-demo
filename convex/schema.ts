import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  // Add your tables here
  visitors: defineTable({
    timestamp: v.number(),
    userAgent: v.string(),
    ipAddress: v.optional(v.string()),
  }),
}); 