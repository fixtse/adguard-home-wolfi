

# AdGuard Home Distroless Docker Image

This is a super lightweight and secure Docker image for AdGuard Home, built on top of the [Wolfi distroless static base](https://images.chainguard.dev/directory/image/static/versions). It's designed to keep things [minimal and safe](https://edu.chainguard.dev/chainguard/chainguard-images/overview/#why-minimal-container-images).

## What's Cool About It

- **Wolfi Distroless Base**: This means maximum security and a tiny size. Wolfi is known for its minimal attack surface and handling CVEs (Common Vulnerabilities and Exposures) really well.
- **Port Exposure**: Opens up ports for DNS, DHCP, and HTTP/HTTPS.
- **Persistent Storage**: Volumes for config and working data are exposed so your settings stick around.

## Not so Cool

- **Runs as Root User**: While AdGuard can run as a [non-root user](https://adguard-dns.io/kb/adguard-home/getting-started/#running-without-superuser), there are some scenarios where it encounters false negatives while running permition checks inside a docker container, there is an active [PR-4728](https://github.com/AdguardTeam/AdGuardHome/pull/4728) to fix this, but it hasn't been merged yet. So until then, this is the best we can get.

## Ports

- DNS: ```53:53/tcp 53:53/udp```

- DHCP Server: ```67:67/udp 68:68/tcp 68:68/udp```

- Admin Panel:```80:80/tcp 3000:3000/tcp```

- HTTPS/DNS-over-HTTPS: ```443:443/tcp 443:443/udp ```

- DNS-over-TLS⁠: ```853:853/tcp```

- DNS-over-QUIC⁠: ```784:784/udp 853:853/udp 8853:8853/udp```

- DNSCrypt⁠ server: ```5443:5443/tcp 5443:5443/udp```

## How to Use It

You can grab this image from the Docker registry and run it with the following setup:

```
docker run --name AdGuardHome\
    --restart unless-stopped\
    -v ./AdGuardHome/work:/opt/adguardhome/work\
    -v ./AdGuardHome/conf:/opt/adguardhome/conf\
    -p 53:53/tcp -p 53:53/udp\
    -p 67:67/udp -p 68:68/udp\
    -p 80:80/tcp -p 443:443/tcp -p 443:443/udp -p 3000:3000/tcp\
    -p 853:853/tcp\
    -p 784:784/udp -p 853:853/udp -p 8853:8853/udp\
    -p 5443:5443/tcp -p 5443:5443/udp\
    -d fixtse/adguard-home-wolfi:latest
```

### Docker Compose Example

```yaml
services:
  adguard_home:
    container_name: AdGuardHome
    image: fixtse/adguard-home-wolfi:latest
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "67:67/udp"
      - "68:68/udp"
      - "80:80/tcp"
      - "443:443/tcp"
      - "443:443/udp"
      - "3000:3000/tcp"
      - "853:853/tcp"
      - "784:784/udp"
      - "853:853/udp"
      - "8853:8853/udp"
      - "5443:5443/tcp"
      - "5443:5443/udp"
    volumes:
      - ./AdGuardHome/conf:/opt/AdGuardHome/conf
      - ./AdGuardHome/work:/opt/AdGuardHome/work
    restart: unless-stopped
```

### Update It

```yaml
docker compose pull
docker compose up -d
```

### resolved

If you try to run AdGuardHome on a system where the ```resolved``` daemon is started (like Ubuntu), docker will fail to bind on port 53, because ```resolved``` daemon is listening on ```127.0.0.53:53```. Here's how you can disable ```DNSStubListener``` on your machine:

1. Deactivate ```DNSStubListener``` and update the DNS server address. Create a new file, ```/etc/systemd/resolved.conf.d/adguardhome.conf``` (creating the ```/etc/systemd/resolved.conf.d``` directory if needed) and add the following content to it: 
    ```yaml
    [Resolve]
    DNS=127.0.0.1
    DNSStubListener=no
    ```

    Specifying ```127.0.0.1``` as the DNS server address is necessary because otherwise the nameserver will be ```127.0.0.53``` which doesn't work without ```DNSStubListener```.

1. Activate a new ```resolv.conf``` file:

    ```yaml
    mv /etc/resolv.conf /etc/resolv.conf.backup
    ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
    ```

1. Stop ```DNSStubListener```:

    ```yaml
    systemctl reload-or-restart systemd-resolved
    ```




And that's it! You're all set to run AdGuard Home with a secure, distroless Docker image. Enjoy! 🚀

---
