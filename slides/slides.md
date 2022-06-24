---
title: Captive Camel - pwnme@tprc.bmo.dev
author: "William Little (cPanel) ~ bmo.dev"
date: 2022-06-24
extensions:
  - terminal
  - qrcode
---

# pwnme@tprc.bmo.dev

---

# What is a Captive Shell?

* Captive Portal
    - ATM, WIFI landing page

---

# What is a Captive Shell?

* Captive Portal
    - ATM, WIFI landing page
* Menu Shell
    - Point-of-Sales systems

---

# What is a Captive Shell?

* Captive Portal
    - ATM, WIFI landing page
* Menu Shell
    - Point-of-Sales systems
* Captive Shell
    - SSH Bastion or Jump Box

---

# What is a Captive Shell?

* Captive Portal
    - ATM, WIFI landing page
* Menu Shell
    - Point-of-Sales systems
* Captive Shell
    - SSH Bastion or Jump Box
* Jailed Shell
    - Chroot

---

# Alternatives

* rbash
* Apparmor (Debian)
* SELinux (CentOS/RHEL)
* GRSEC

---

# Captive Camel Config

```yaml
---
help: 1 # allow help
exit: 1 # allow exit
commands:
  - match: sudo
    match_type: prefix

  - match: date
    match_type: exact

  - match: whoami
    match_type: exact

  - match: ls
    match_type: exact
    exec: ls -lah

  - match: top
    match_type: prefix
```

---

# Captive Camel Demo

```terminal20
./captive-camel.fatpack.pl
```

---

```qrcode-ex
columns:
    - data: "https://bmo.dev/"
      caption: "https://bmo.dev/"
    - data: "https://github.com/bmodotdev/captive-camel"
      caption: "https://github.com/bmodotdev/captive-camel"
```
