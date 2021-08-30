# README

*danectl* - DNSSEC DANE implementation manager

# INTRODUCTION

*Danectl* is a DNSSEC DANE implementation manager. It uses *certbot* to create
and manage pairs of keys for use with a TLSA 3 1 1 current + next workflow.
It generates TLSA records for your TLS services for you to publish to the DNS,
checks that they are correctly published, and performs key rollovers.

# DESCRIPTION

Danectl lets you create a pair of certbot certificate lineages to be used
with DANE. They are referred to as the "original" and the "duplicate", or
as the "current" and the "next". The current and next will repeatedly swap
places between the original and the duplicate as the key rolls over from
one to the other (with a new "next" key created after each rollover).

    danectl new example.org www.example.org mail.example.org
    danectl dup example.org www.example.org mail.example.org

If you already have a certbot certificate lineage that you want to use with
DANE, then instead of creating both certificate lineages, you can adopt the
existing one for DANE use, and then just create the duplicate.

    danectl adopt example.org
    danectl dup example.org www.example.org mail.example.org

You then configure danectl with the set of port/protocol/host combinations
that you need TLSA records for.

    danectl add-tlsa example.org _443._tcp _443._tcp.www
    danectl add-tlsa example.org _25._tcp.mail _465._tcp.mail _587._tcp.mail
    danectl add-tlsa example.org _110._tcp.mail _143._tcp.mail
    danectl add-tlsa example.org _993._tcp.mail _995._tcp.mail
    danectl del-tlsa example.org _110._tcp.mail _143._tcp.mail

Danectl can then print out the TLSA records, in zonefile format, and you
need to publish them to the DNS (somehow).

    danectl tlsa-current example.org
    danectl tlsa-next example.org

Danectl can then check that the TLSA records have been published to the DNS.

    danectl tlsa-check example.org

You also need to configure danectl with the list of services that need to be
reloaded when the key rolls over.

    danectl add-reload example.org apache2 postfix dovecot
    danectl del-reload example.org postfix

This is needed even when certbot is configured to do it with deploy hooks,
because those hooks are only run when a certificate is renewed. Service
reloads also need to happen when there's a DANE key rollover, and that
doesn't happen at the same time as automatic certbot certificate renewals.

You then need to configure your services to use the "current" certificate in
/etc/letsencrypt/current, and then reload them.

    Left as an exercise for the reader

After that, certbot automatically renews certificates every three months,
but the underlying keypair doesn't change, and the TLSA records can remain
stable.

Periodically, you can perform key rollovers on a schedule that suits you
(e.g. annually). An emergency key rollover is exactly the same.

    danectl rollover example.org

At any time, you can show the status (which certificate lineages are current
and which are next, and which TLSA records are not yet published).

    danectl status

# INSTALL

To install danectl:

    tar xzf danectl-0.3.1.tar.gz
    cd danectl-0.3.1
    make install

This will install:

    /usr/local/bin/danectl
    /usr/local/share/man/man1/danectl.1

# REQUIREMENTS

Danectl requires /bin/sh, grep, cut, sed, host, readlink, certbot, openssl,
sha256sum.

--------------------------------------------------------------------------------

    URL: https://raf.org/danectl
    GIT: https://github.com/raforg/danectl
    Date: 20210826
    Author: raf <raf@raf.org>

