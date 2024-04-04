FROM node:21-alpine3.18 as deps

RUN npm install -g pnpm && \
  apk add --no-cache shadow

# Host user data
ARG UID=1000
ARG GID=1000

# Match host user to avoid volumes permission issues
RUN usermod  --uid ${UID} node && \
  groupmod --gid ${GID} node

USER node

WORKDIR /opt/apps/app

COPY --chown=node:node package.json pnpm-lock.* ./

RUN pnpm install

# BUILDER
FROM deps as cli

USER node

WORKDIR /opt/apps/app

COPY --from=deps --chown=node:node /opt/apps/app/node_modules ./node_modules

COPY --chown=node:node . .

# RUNNER
FROM cli as runner

USER node

WORKDIR /opt/apps/app

COPY --chown=node:node --from=cli /opt/apps/app ./

CMD pnpm run dev
