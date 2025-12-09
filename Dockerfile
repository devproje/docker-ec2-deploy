FROM oven/bun:latest AS builder

WORKDIR /src

COPY . .

RUN bun install
RUN bun run build

FROM fedora:43

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=${PORT}
ENV APP_NAME=${APP_NAME}

EXPOSE ${PORT}

USER user

COPY --from=builder /src/dist/server .

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
	CMD node -e "require('http').get('http://localhost:' + (process.env.PORT || 3000) + '/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)}).on('error', () => process.exit(1))"

ENTRYPOINT [ "./server" ]
