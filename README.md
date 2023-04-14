# README

*danectl* - DNSSEC DANE implementation manager

# INTRODUCTION

*Danectl* is a DNSSEC DANE implementation manager. It uses *certbot* to create
and manage pairs of keys for use with a TLSA 3 1 1 current + next workflow.
It generates TLSA records for your TLS services for you to publish in the DNS,
checks that they are correctly published, and performs key rollovers.

*Danectl* can also generate and check SSHFP records for the local *SSH* server.

*Danectl* can also generate and check an OPENPGPKEY record for a *GnuPG* key.

*Danectl* can also generate and check an SMIMEA record for an S/MIME certificate.

# DESCRIPTION

*Danectl* lets you create a pair of *certbot* certificate lineages to be
used with DANE-aware TLS clients. They are referred to as the "original" and
the "duplicate", or as the "current" and the "next".

        danectl new example.org www.example.org mail.example.org
        danectl dup example.org www.example.org mail.example.org

The current and next will repeatedly swap places between the original and
the duplicate certificate lineages as the key rolls over from one to the
other (with a new "next" key being created after each rollover).

If you already have a *certbot* certificate lineage that you want to use with
DANE, then instead of creating both certificate lineages, you can adopt the
existing one for DANE use, and then just create the duplicate.

        danectl adopt example.org
        danectl dup example.org www.example.org mail.example.org

After that, *certbot* automatically renews both certificates every few months,
but the underlying keys won't change, and the TLSA records (see below) can
remain stable.

You then configure *danectl* with the set of port/protocol/host combinations
that you need TLSA records for.

        danectl add-tlsa example.org _443._tcp _443._tcp.www
        danectl add-tlsa example.org _25._tcp.mail
        danectl add-tlsa example.org _465._tcp.mail _587._tcp.mail
        danectl add-tlsa example.org _110._tcp.mail _143._tcp.mail
        danectl add-tlsa example.org _993._tcp.mail _995._tcp.mail
        danectl del-tlsa example.org _110._tcp.mail _143._tcp.mail

*Danectl* can then output the TLSA records, in *BIND9* zonefile format, and
you need to publish them in the DNS (somehow).

        danectl tlsa-current example.org
        danectl tlsa-next example.org

*Danectl* can then check that the TLSA records have been published in the DNS.

        danectl tlsa-check example.org

You also need to configure *danectl* with the list of TLS services that need
to be reloaded when the key rolls over.

        danectl add-reload example.org apache2 postfix dovecot
        danectl del-reload example.org postfix

This is needed even when *certbot* is configured to do it with deploy hooks,
because those hooks are only run when a certificate is renewed. Service
reloads also need to happen when there's a DANE key rollover, and that
doesn't necessarily happen at the same time as automatic *certbot*
certificate renewals.

You then need to configure your TLS services to use the "current"
certificate in /etc/letsencrypt/current, and then reload them. This is like
following instructions for using a certbot certificate, but replacing
"/etc/letsencrypt/live" with "/etc/letsencrypt/current".

        Left as an exercise for the reader

Periodically, you can perform key rollovers on a schedule that suits you
(e.g., annually). An emergency key rollover is exactly the same.

        danectl rollover example.org

At any time, you can show the status (which certificate lineages are
current, which are next, which new TLSA records are not yet published in the
DNS, and which old TLSA records have not yet been removed from the DNS).

        danectl status

In addition to TLSA records, you can also generate SSHFP, OPENPGPKEY, and
SMIMEA records, and check that they are published in the DNS.

        danectl sshfp example.org
        danectl sshfp-check example.org
        danectl openpgpkey user@example.org
        danectl openpgpkey-check user@example.org
        danectl smimea smimecert.pem
        danectl smimea-check smimecert.pem

# INSTALL

To install `danectl`:

        tar xzf danectl-0.8.2.tar.gz
        cd danectl-0.8.2
        make install

This will install:

        /usr/local/bin/danectl
        /usr/local/bin/danectl-zonefile
        /usr/local/bin/danectl-nsupdate
        /usr/local/share/man/man1/danectl.1
        /usr/local/share/man/man1/danectl-zonefile.1
        /usr/local/share/man/man1/danectl-nsupdate.1

To install under `/usr` instead:

        make PREFIX=/usr install

To uninstall `danectl`:

        make uninstall

# REQUIREMENTS

`Danectl` is written in Bourne shell, and should work on any platform
that has the following prerequisites.

In all cases, `danectl` requires `/bin/sh` and `host` (or `drill`).

On systems like *Solaris*, `/usr/xpg4/bin/sh` is used instead of `/bin/sh`.

For TLSA usage, `danectl` also requires `ls`, `sed`, `grep`, `readlink`, `certbot`,
`openssl`, `sha256sum`, and root privileges (for `certbot`).

For SSHFP usage, `danectl` also requires `sed`, `perl` and `ssh-keygen`.

For OPENPGPKEY usage, `danectl` also requires `perl` and `gpg`.

For SMIMEA usage, `danectl` also requires `perl` and `openssl`.

For non-ASCII domain names, `danectl` also requires *GNU* `idn2`.

The `danectl-zonefile` output adapter requires `perl`.

The `danectl-nsupdate` output adapter requires `perl`.

For reloading affected services on key rollover, any system with
`systemctl`, `service`, `rcctl`, or service scripts in
`/etc/init.d`, `/etc/rc.d`, or `/usr/local/etc/rc.d` should work
(e.g., `Linux`, `FreeBSD`, `NetBSD`, `OpenBSD`, `Solaris`).

--------------------------------------------------------------------------------

    URL: https://raf.org/danectl
    GIT: https://github.com/raforg/danectl
    GIT: https://codeberg.org/raforg/danectl
    Date: 20230414
    Author: raf <raf@raf.org>

