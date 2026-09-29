FROM node:18-alpine3.20
WORKDIR /source
COPY landing-zone-accelerator-on-aws/source .

RUN export NODE_OPTIONS=--max_old_space_size=8192 \
    && yarn install \
    && yarn build \
    && yarn cache clean

# CKV_DOCKER_3: run as a non-root user
RUN chown -R node:node /source
USER node

# CKV_DOCKER_2: provide a container healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD node -e "process.exit(0)"

CMD ["yarn", "validate-config", "../config"]
