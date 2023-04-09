FROM dockerhub.chafflabs.com/arm64v8/node AS deps
# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine to understand why libc6-compat might be needed.
RUN apk add --no-cache libc6-compat
RUN apk update
# 1. Set working directory
WORKDIR /app
# Install pnpm & turbo / bump turbo version to 1.6.3
RUN npm install -g turbo@1.7.0
COPY . .
COPY .git ./git
RUN corepack enable
RUN pnpm dlx turbo prune --scope=next-commerce --docker


# 2. Install dependencies / Build App
FROM dockerhub.chafflabs.com/arm64v8/node AS builder
# Set working directory
WORKDIR /app
RUN apk add --no-cache libc6-compat
# Install pnpm & turbo AGAIN
RUN npm install -g turbo@1.7.0
# set your APP_NAME -> look for your APP_NAME in /site/package.json
ENV APP_NAME=next-commerce
# Copy required files to run 'pnpm install' from the /out/ folder which is generated with the 'turbo prune' command
COPY .gitignore .gitignore
COPY --from=deps /app/.npmrc .
COPY --from=deps /app/out/json/ .
COPY --from=deps /app/out/pnpm-lock.yaml ./pnpm-lock.yaml
COPY --from=deps /app/out/pnpm-workspace.yaml ./pnpm-workspace.yaml
RUN corepack enable
RUN pnpm install 
# Copy Files from 'out/full' & turbo.json | WARNING: add '**/node_modules' to your .dockerignore, otherwise you will get the Error: cannot copy to non-directory
COPY --from=deps /app/out/full/ .
COPY turbo.json turbo.json
# Start production build | A simple 'pnpm build' works too
RUN pnpm build
# WORKAROUND FOR: https://github.com/vercel/next.js/discussions/39432 | Part 1 of workaround, otherwise server.js will abort with Error: 'next/dist/server/next-server.js'
RUN pnpm install --prod  --shamefully-hoist  && \
    cp -Lr ./node_modules ./node_modules_temp && \
    rm -rf ./node_modules_temp/.cache && \
    rm -rf ./node_modules_temp/.pnpm
# END WORKAROUND

# 3. Production image, copy all the files and run next
FROM dockerhub.chafflabs.com/arm64v8/node AS runner
RUN apk add --no-cache libc6-compat

WORKDIR /app
ENV NEXT_TELEMETRY_DISABLED 1
ENV NODE_ENV=production
# set your APP_NAME | APP_NAME here refers to the actual folder. In vercel/commerce the folder is 'site'
ENV APP_NAME=site

# Set Permission - Don't run app as root
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy Folders to root
COPY --from=builder /app/$APP_NAME/public public
COPY --from=builder --chown=nextjs:nodejs /app/$APP_NAME/.next/ ./.next/

# WORKAROUND FOR: https://github.com/vercel/next.js/discussions/39432 | Part 2 of workaround, otherwise server.js will abort with Error: 'next/dist/server/next-server.js'
RUN rm -rf ./node_modules
COPY --from=builder /app/node_modules_temp ./node_modules

# END WORKAROUND

COPY --from=builder /app/site/prod-next.config.js ./next.config.js
COPY --from=builder /app/site/package.json ./package.json

USER nextjs

EXPOSE 3000

# 4. Start App
CMD npm start