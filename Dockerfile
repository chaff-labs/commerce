# 1. Install dependencies / Build App
FROM dockerhub.chafflabs.com/arm64v8/node AS builder
# Set working directory
WORKDIR /app
RUN apk add --no-cache libc6-compat
COPY . .
RUN yarn install
# Start production build | A simple 'pnpm build' works too
RUN yarn build

# 3. Production image, copy all the files and run next
FROM dockerhub.chafflabs.com/arm64v8/node AS runner
RUN apk add --no-cache libc6-compat

WORKDIR /app
ENV NEXT_TELEMETRY_DISABLED 1
ENV NODE_ENV=production

# Set Permission - Don't run app as root
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy Folders to root
COPY --from=builder /app/public public
COPY --from=builder --chown=nextjs:nodejs /app/.next/ ./.next/

# WORKAROUND FOR: https://github.com/vercel/next.js/discussions/39432 | Part 2 of workaround, otherwise server.js will abort with Error: 'next/dist/server/next-server.js'
RUN rm -rf ./node_modules
COPY --from=builder /app/node_modules ./node_modules

# END WORKAROUND

COPY --from=builder /app/store-config.js ./store-config.js
COPY --from=builder /app/store.config.json ./store.config.json
COPY --from=builder /app/next.config.js ./next.config.js
COPY --from=builder /app/package.json ./package.json

USER nextjs

EXPOSE 8000

# 4. Start App
CMD yarn start
