FROM fedora:27
RUN dnf -y install vim wget iproute procps nmap iputils tree samba samba-client
RUN mkdir /opt/docker
COPY . /opt/docker
WORKDIR /opt/docker
CMD /bin/bash

