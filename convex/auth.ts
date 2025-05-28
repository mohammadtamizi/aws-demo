import { v } from "convex/values";
import { mutation } from "./_generated/server";

export const clerk = mutation({
  args: {
    type: v.string(),
    data: v.any(),
  },
  handler: async (ctx, args) => {
    // Here we would typically handle user data synchronization
    // For now, we're just logging the event type
    console.log(`Received Clerk event: ${args.type}`);
  },
});
