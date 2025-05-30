FROM node:20-alpine AS base

# Install dependencies only when needed
FROM base AS deps
WORKDIR /app

# Install additional packages needed for building
RUN apk add --no-cache libc6-compat

# Copy package.json files - fix the path to match your project structure
COPY aws-demo/package.json aws-demo/package-lock.json* ./

# Install dependencies
RUN npm ci

# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
# Copy the entire project directory
COPY aws-demo/ .

# Disable Next.js telemetry during build
ENV NEXT_TELEMETRY_DISABLED=1

# Set up environment variables for build time using ARG
# These need to be passed during build with --build-arg
ARG NEXT_PUBLIC_CONVEX_URL

# Build the application
RUN npm run build

# Production image, copy all the files and run next
FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# Create a non-root user and group
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Copy the built application
COPY --from=builder /app/public ./public

# Set up runtime environment variables
# These will be replaced with actual values at container runtime
ENV NEXT_PUBLIC_CONVEX_URL=$NEXT_PUBLIC_CONVEX_URL

# Use the standalone output directory created by Next.js
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# Switch to the non-root user
USER nextjs

# Expose the port the app will run on
EXPOSE 3000

# Start the application
CMD ["node", "server.js"] 