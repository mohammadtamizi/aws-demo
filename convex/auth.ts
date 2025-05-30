import { v } from "convex/values";
import { mutation } from "./_generated/server";

// Simple mutation that doesn't require authentication
export const noAuth = mutation({
  args: {},
  handler: async (ctx) => {
    // Any user can call this function
    return { success: true };
  },
}); 