FROM debian:bookworm-slim as sdmrelay
# Install SDM CLI
WORKDIR /usr/local/bin
RUN apt-get update && \
  apt-get install -y curl jq zip ca-certificates && \
  curl -fsSLo sdm.zip $(curl https://app.strongdm.com/releases/upgrade\?os\=linux\&arch\=$(uname -m | sed -e 's:x86_64:amd64:' -e 's:aarch64:arm64:')\&software\=sdm-cli\&version\=productionexample | jq ".url" -r) && \
  unzip sdm.zip && \
  rm sdm.zip && \
  chmod g+rx sdm && \
  apt-get remove -y --purge curl zip jq
# Setup non-root user
ENV HOME=/home/sdmuser \
  SDM_HOME=/home/sdmuser \
  SDM_DOCKERIZED=true
RUN useradd --create-home --home-dir $HOME --uid 1000 --gid 0 sdmuser && \
  chmod g=u $HOME
WORKDIR $HOME
COPY docker-entrypoint.sh README.md LICENSE /
RUN chmod a+x /docker-entrypoint.sh
USER 1000:0
ENTRYPOINT ["/docker-entrypoint.sh"]
