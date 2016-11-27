FROM aarch64/alpine:edge
MAINTAINER uulaoba

# Install system utils & Gogs runtime dependencies
RUN apk --no-cache --no-progress add ca-certificates bash git linux-pam s6 curl openssh socat tzdata sqlite

RUN curl -L#o /usr/sbin/gosu \
  https://github.com/tianon/gosu/releases/download/1.10/gosu-arm64 && \
  chmod +x /usr/sbin/gosu

ENV GOGS_CUSTOM /data/gogs

COPY docker /app/gogs/docker/
# Configure LibC Name Service
COPY docker/nsswitch.conf /etc/nsswitch.conf

RUN adduser -H -D -g 'Gogs Git User' git -h /data/git -s /bin/bash && \
  passwd -u git && \
  echo "export GOGS_CUSTOM=${GOGS_CUSTOM}" >> /etc/profile

RUN curl -#Lo gogs.zip https://dl.gogs.io/gogs_latest_linux_arm.zip
RUN unzip gogs.zip -d /app && rm gogs.zip 

# Configure Docker Container
VOLUME ["/data"]
EXPOSE 22 3000
ENTRYPOINT ["/app/gogs/docker/start.sh"]
CMD ["/bin/s6-svscan", "/app/gogs/docker/s6/"]
