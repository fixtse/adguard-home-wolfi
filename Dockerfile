FROM cgr.dev/chainguard/wolfi-base AS builder

RUN apk --no-cache --update add curl && \
    rm -rf /var/cache/apk/* && mkdir -p /opt/AdGuardHome

RUN curl -s -S -L https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh -o install.sh && \  
    sed -i ':a;N;$!ba;s/\n[^\n]*\n[^\n]*\n[^\n]*\n[^\n]*\n[^\n]*\n[^\n]*$//' install.sh && \
    sh install.sh -v -c release  
    
FROM cgr.dev/chainguard/static:latest

COPY --from=builder /opt/AdGuardHome /opt/AdGuardHome

EXPOSE 53/tcp 53/udp 67/tcp 67/udp 68/tcp 68/udp 80/tcp 443/tcp 443/udp 784/udp 853/tcp 853/udp 3000/tcp 8853/udp 5443/tcp 5443/udp

VOLUME ["/opt/AdGuardHome/conf", "/opt/AdGuardHome/work"]

USER root

ENTRYPOINT ["/opt/AdGuardHome/AdGuardHome"]
CMD ["-h", "0.0.0.0", "-c", "/opt/AdGuardHome/conf/AdGuardHome.yaml", "-w", "/opt/AdGuardHome/work"]