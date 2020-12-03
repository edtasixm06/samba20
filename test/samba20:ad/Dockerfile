FROM fedora:27
RUN dnf -y install vim wget iproute procps nmap iputils tree samba samba-client samba-dc bind-utils openldap-clients krb5-workstation samba-winbind-clients ldb-tools
RUN mkdir /opt/docker
COPY . /opt/docker
RUN chmod +x /opt/docker/startup.sh
WORKDIR /opt/docker
CMD /opt/docker/startup.sh

