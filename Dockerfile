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


COPY --from=builder /src/dist/server .

RUN useradd -u 1000 -r -s /bin/bash user
RUN chown 1000:1000 -R /app

USER user

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
	CMD node -e "require('http').get('http://localhost:' + (process.env.PORT || 3000) + '/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)}).on('error', () => process.exit(1))"

ENTRYPOINT [ "./server" ]