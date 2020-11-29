FROM fedora:27
RUN dnf -y install vim wget iproute procps nmap iputils tree samba samba-client samba-winbind samba-winbind-clients krb5-workstation openldap-clients
RUN mkdir /opt/docker
RUN ulimit -n 1024
COPY . /opt/docker
WORKDIR /opt/docker
CMD /bin/bash

