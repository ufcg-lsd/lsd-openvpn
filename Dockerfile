# Original credit: https://github.com/jpetazzo/dockvpn

# Smallest base image
FROM alpine:latest

LABEL maintainer="Kyle Manna <kyle@kylemanna.com>"

# Testing: pamtester
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories && \
    apk add --update openvpn \ 
        iptables \
        bash \
        easy-rsa \
        openvpn-auth-pam \
        google-authenticator \
        pamtester \
        libqrencode \
        python3-dev \
        openldap-dev \
        cyrus-sasl-dev \
        openssl-dev \
        gcc \
        musl-dev \
        libffi-dev \
        make \
        py3-pip \
        build-base \
        pipx && \
    ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*

# Installing binary necessary for LDAP authentication
RUN pipx install openvpn-ldap-auth

# Needed by scripts
ENV OPENVPN=/etc/openvpn
ENV EASYRSA=/usr/share/easy-rsa \
    EASYRSA_CRL_DAYS=3650 \
    EASYRSA_PKI=$OPENVPN/pki

VOLUME ["/etc/openvpn"]

# Internally uses port 1194/udp, remap using `docker run -p 443:1194/tcp`
EXPOSE 1194/udp

CMD ["ovpn_run"]

ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

# Add support for OTP authentication using a PAM module
ADD ./otp/openvpn /etc/pam.d/
