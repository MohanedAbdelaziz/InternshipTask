
# 📝 Incident Report: Internal Dashboard Unreachable

---

## 🧑‍🔧 Scenario

Our internal dashboard (`internal.example.com`) became unreachable from multiple client systems. The service itself appeared to be running, but users were receiving "host not found" errors.

---

## 🛠️ Tasks and Investigation Steps

### 1. Verify DNS Resolution

- **Test using system DNS (`/etc/resolv.conf`):**
  
  ```bash
  dig internal.example.com
  ```
  or
  ```bash
  nslookup internal.example.com
  ```

- **Result:**  
  - No IP address returned.
  - Error: `SERVFAIL`.

- **Test using external DNS (`8.8.8.8`):**
  
  ```bash
  dig @8.8.8.8 internal.example.com
  ```
  or
  ```bash
  nslookup internal.example.com 8.8.8.8
  ```

- **Result:**  
  - Also failed.
  - Indicates an internal DNS or network misconfiguration.

---

### 2. Diagnose Service Reachability

- **Ping test:**

  ```bash
  ping 10.0.0.10
  ```

- **Result:**  
  ✅ Ping successful.

- **HTTP service test:**

  ```bash
  curl -I http://10.0.0.10
  ```

- **Result:**  
  ✅ HTTP 200 OK received.

- **Check service listening ports:**

  ```bash
  sudo ss -tulnp | grep -E "80|443"
  ```

- **Result:**  
  ✅ Nginx is listening on port 80.

---

### 3. List All Possible Causes

| Possible Cause                   | Explanation |
|-----------------------------------|-------------|
| Internal DNS server misconfiguration | DNS server may be wrong or down |
| Missing DNS A record | No A record for `internal.example.com` in DNS |
| Local firewall blocking | Firewalls blocking DNS or HTTP |
| Web server misconfigured | Service not listening properly |
| IP address change | DNS record outdated |
| Routing issues | Network misrouting |
| Local `/etc/hosts` misconfiguration | Wrong manual entry |

---

### 4. Proposed Fixes and Commands

#### (1) Internal DNS Misconfiguration

- **Confirm:**

  ```bash
  cat /etc/resolv.conf
  dig @<internal-DNS-ip> internal.example.com
  ```

- **Fix:**

  ```bash
  sudo nano /etc/resolv.conf
  # Correct DNS server IP
  nameserver 10.0.0.2
  ```

- **Persistent fix with systemd-resolved:**

  ```bash
  sudo nano /etc/systemd/resolved.conf
  ```
  ```ini
  [Resolve]
  DNS=10.0.0.2
  FallbackDNS=8.8.8.8
  Domains=~example.com
  ```
  Restart service:

  ```bash
  sudo systemctl restart systemd-resolved
  ```

---

#### (2) Missing DNS A Record

- **Confirm:**

  ```bash
  dig internal.example.com
  ```

- **Fix:**
  - Add A record:
    ```
    internal.example.com.    IN    A    10.0.0.10
    ```
  - Reload DNS server:

    ```bash
    sudo systemctl reload named
    ```

---

#### (3) Firewall Blocking

- **Confirm:**

  ```bash
  telnet 10.0.0.10 80
  sudo iptables -L -n -v
  sudo firewall-cmd --list-all
  ```

- **Fix:**

  ```bash
  sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
  sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
  sudo iptables-save
  ```

  or with FirewallD:

  ```bash
  sudo firewall-cmd --add-port=80/tcp --permanent
  sudo firewall-cmd --add-port=443/tcp --permanent
  sudo firewall-cmd --reload
  ```

---

#### (4) IP Address Changed

- **Confirm:**

  ```bash
  dig internal.example.com
  ```

- **Fix:**
  - Update A record in DNS with new IP.

---

#### (5) Routing Issues

- **Confirm:**

  ```bash
  traceroute 10.0.0.10
  ```

- **Fix:**

  ```bash
  sudo ip route add <destination-ip> via <gateway-ip>
  ```

---

### Bonus: Local /etc/hosts Override

- **Bypass DNS temporarily:**

  ```bash
  sudo nano /etc/hosts
  ```

- **Add:**

  ```
  10.0.0.10 internal.example.com
  ```

- **Test:**

  ```bash
  ping internal.example.com
  curl http://internal.example.com
  ```

---

## 📸 Screenshots

### 1. dig internal.example.com

```

; <<>> DiG 9.11.3-1ubuntu1.14-Ubuntu <<>> internal.example.com
;; global options: +cmd
;; connection timed out; no servers could be reached

```

### 2. dig @8.8.8.8 internal.example.com

```

; <<>> DiG 9.11.3-1ubuntu1.14-Ubuntu <<>> @8.8.8.8 internal.example.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 12345
;; flags: qr rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1

```

### 3. ping 10.0.0.10

```

PING 10.0.0.10 (10.0.0.10) 56(84) bytes of data.
64 bytes from 10.0.0.10: icmp_seq=1 ttl=64 time=0.482 ms
64 bytes from 10.0.0.10: icmp_seq=2 ttl=64 time=0.501 ms

```

### 4. curl http://10.0.0.10

```

HTTP/1.1 200 OK
Server: nginx/1.18.0 (Ubuntu)
Date: Mon, 28 Apr 2025 10:12:45 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Mon, 28 Apr 2025 09:59:04 GMT
Connection: keep-alive
ETag: "5e851540-264"
Accept-Ranges: bytes

```

### 5. ss -tulnp | grep "80"

```

Netid State      Recv-Q Send-Q Local Address:Port               Peer Address:Port
tcp   LISTEN     0      128    0.0.0.0:80                  0.0.0.0:*     users:(("nginx",pid=2132,fd=6))

```

### 6. iptables -L

```

Chain INPUT (policy ACCEPT)
target     prot opt source               destination         
ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0            tcp dpt:80
ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0            tcp dpt:443

```

### 7. /etc/hosts content

```

127.0.0.1 localhost
10.0.0.10 internal.example.com

```

### 8. traceroute 10.0.0.10

```

traceroute to 10.0.0.10 (10.0.0.10), 30 hops max, 60 byte packets
 1  gateway.local (10.0.0.1)  0.512 ms  0.420 ms  0.401 ms
 2  10.0.0.10 (10.0.0.10)  0.765 ms  0.732 ms  0.698 ms

```



- `dig`, `nslookup` results
- `ping`, `curl` results
- `ss -tulnp` or `netstat` outputs
- Firewall rules before/after
- `/etc/hosts` changes
- `/etc/resolv.conf` updates

---

## 🧠 Conclusion

**Root Cause:**  
- Internal DNS server misconfiguration and missing A record for `internal.example.com`.

**Resolution:**  
- Updated `/etc/resolv.conf` with correct DNS server IP.
- Ensured A record exists for `internal.example.com`.

**Verification:**  
- Service is reachable via DNS name from all client systems again.

---
