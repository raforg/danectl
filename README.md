# README

*danectl* - a DANE-friendly Certbot workflow


# DESCRIPTION

*Danectl* provides a DANE-friendly Certbot workflow. For background, see:

[https://en.wikipedia.org/wiki/DNS-based_Authentication_of_Named_Entities](https://en.wikipedia.org/wiki/DNS-based_Authentication_of_Named_Entities)

[https://community.letsencrypt.org/t/a-dane-friendly-certbot-workflow](https://community.letsencrypt.org/t/a-dane-friendly-certbot-workflow)

Danectl lets you create a pair of certbot certificate lineages to be used
with DANE. They are referred to as the "original" and the "duplicate", or
as the "current" and the "next". The current and next will repeatedly swap
places between the original and the duplicate as the key rolls over from
one to the other.

If you already have a certbot certificate lineage, then instead of creating
both certificate lineages, you can adopt the existing one for DANE use, so
that you can start with your existing certificate lineage, and then just
create the duplicate.

You then configure danectl with the set of port/protocol/host combinations
that you need TLSA records for. Danectl can then print out the TLSA records,
in zonefile format, and you need to publish them to the DNS (somehow).
Danectl can then check that the TLSA records have been published to the DNS.

You also need to configure danectl with the list of services that need to be
reloaded (by systemctl) when the key rolls over. This is needed even when
certbot is configured to do it with deploy hooks, because those hooks are
only run when a certificate is renewed. Service reloads also need to happen
when there's a DANE key rollover, and that doesn't happen at the same time
as automatic certbot certificate renewals.

You then need to configure your services to use the current certificate in
/etc/letsencrypt/current/<cert-name>, and then reload them.

After that, certbot automatically renews certificates every three months,
but the underlying keypair doesn't change, and the TLSA records can remain
stable.

Periodically, you can perform key rollovers on a schedule that suits you
(e.g. annually). An emergency key rollover is exactly the same. At any time,
you can show the status (which certificate lineages are current and which
are next, and which TLSA records are not yet published).

# INSTALL

To install danectl

    tar xzf danectl-0.1.tar.gz
    cd danectl-0.1
    make install

This will install:

    /usr/local/bin/danectl
    /usr/local/share/man/man1/danectl.1

# REQUIREMENTS

Danectl requires /bin/sh, grep, sed, awk, perl, pod2man, host, readlink, certbot,
openssl, sha256sum, and systemctl (just for reload).

--------------------------------------------------------------------------------

    URL: https://raf.org/danectl
    GIT: https://github.com/raforg/danectl
    Date: 20210824
    Author: raf <raf@raf.org>

