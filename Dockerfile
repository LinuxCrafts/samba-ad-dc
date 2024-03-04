# Use Alpine Linux as the base image
FROM alpine:latest

ARG BUILD_DATE
ARG VERSION

LABEL Mantainer = "Harol Hunter <hhuntercu.devops@gmail.com>>"
LABEL org.label-schema.schema-version = "1.0" \
      org.label-schema.build-date = $BUILD_DATE \
      org.label-schema.name = "samba-ad-dc" \
      org.label-schema.description = "Containerized Samba4 AD DC (Alpine Linux)" \
      org.label-schema.vcs-url = "https://github.com/LinuxCrafts/samba-ad-dc/" \
      org.label-schema.vendor = "LinuxCrafts <craftslinux@gmail.com>" \
      org.label-schema.version = $VERSION 
      

# Installing Samba and required packages
RUN apk --no-cache --no-progress --update add samba-dc && \
      mkdir -p /samba/etc/smb.conf.d

# Exposing DNS, KDC, LDAP, LDAPS, SMB, CATALOG, CATALOG over SSL, Random RPC ports
EXPOSE 53 53/udp 88 88/udp 135 389 389/udp 445 464 464/udp 636 3268 3269 50000-55000

# Using persistent volumes to store Samba files
VOLUME [ "/samba", "/bind-dns", "/ntp_signd" ]

HEALTHCHECK --interval=60s --timeout=15s --start-period=60s --retries=3  \
            CMD smbclient -L \\localhost -U % -m SMB3

COPY smb.conf /samba/etc/smb.conf 
COPY smb.conf.d /samba/etc/smb.conf.d
COPY docker-entrypoint /samba-ad-dc

ENTRYPOINT ["/samba-ad-dc"]

