# Use Debian/GNU Linux Bookworm as the base image
FROM debian:stable-slim

ARG BUILD_DATE
ARG VERSION

LABEL Mantainer = "Harol Hunter <hhuntercu.devops@gmail.com>>"
LABEL org.label-schema.schema-version = "1.0" \
      org.label-schema.build-date = $BUILD_DATE \
      org.label-schema.name = "samba-ad-dc" \
      org.label-schema.description = "Containerized Samba4 AD DC (Debian/GNU Linux)" \
      org.label-schema.vcs-url = "https://github.com/LinuxCrafts/samba-ad-dc/" \
      org.label-schema.vendor = "LinuxCrafts <craftslinux@gmail.com>" \
      org.label-schema.version = $VERSION 

# Installing Samba and required packages
#RUN apk --no-cache --no-progress --update add samba-dc krb5 && \
RUN export DEBIAN_FRONTEND=noninteractive && \
      apt-get update && \
      apt-get install -y samba smbclient winbind krb5-config && \
      mkdir -p /samba/log && \
      mkdir -p /samba/lock && \
      mkdir -p /samba/state && \
      mkdir -p /samba/cache && \
      mkdir -p /samba/private/tls && \
      mkdir /bind-dns && \
      mkdir -m 700 /users && \
      mkdir -m 750 /ntp_signd && \
      rm -rf /var/cache/apt/archives/* 
      # export -n DEBIAN_FRONTEND

# Exposing DNS, KDC, LDAP, LDAPS, SMB, CATALOG, CATALOG over SSL, Random RPC ports
EXPOSE 53 53/udp 88 88/udp 135 389 389/udp 445 464 464/udp 636 3268 3269 55000-55500

# Using persistent volumes to store Samba files
VOLUME "/samba" "/bind-dns" "/ntp_signd" "/users"

HEALTHCHECK --interval=60s --timeout=15s --start-period=60s --retries=3  \
            CMD smbclient -L \\localhost -U % -m SMB3

COPY smb.conf /samba/etc/smb.conf 
COPY smb.conf.d /samba/etc/smb.conf.d
# COPY admx.xz /tmp/admx.xz
COPY docker-entrypoint /samba-ad-dc 


ENTRYPOINT ["/samba-ad-dc"]

