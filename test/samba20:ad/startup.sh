#! /bin/bash

# Esborrar la configuració prèvia
rm /etc/samba/smb.conf

# Fer el provisioning
# samba-tool domain provision --use-rfc2307 --interactive
samba-tool domain provision --server-role=dc --use-rfc2307 --dns-backend=SAMBA_INTERNAL --realm=EDT.ORG --domain=EDT --adminpass=Passw0rd

# Generar la configuració client DNS
# cat /etc/resolv.conf
#search edt.org
#nameserver 172.19.0.2
cp /opt/docker/resolv.conf /etc/resolv.conf


# Configurar kerberos
cp /var/lib/samba/private/krb5.conf /etc/krb5.conf

# Activar el servei
samba

# Activar la resolució nsswitch amb winbind
cp /opt/docker/nsswitch.conf /etc/nsswitch.conf

# Configurar PAM
cp /opt/docker/system-auth /etc/pam.d/system-auth

# Creació d'usuaris
echo -e "Samba01\nSamba01\n" | smbpasswd -a samba01
echo -e "Samba02\nSamba02\n" | smbpasswd -a samba02
echo -e "Samba03\nSamba03\n" | smbpasswd -a samba03


# Configurar el client ldap
#cp /opt/docker/ldap.conf /etc/openldap/ldap.conf
echo "BASE    dc=edt,dc=org" >> /etc/openldap/ldap.conf
echo "URI     ldap://localhost" >> /etc/openldap/ldap.conf
echo "TLS_CACERT /var/lib/samba/private/tls/ca.pem" >> /etc/openldap/ldap.conf
#cp /var/lib/samba/private/tls/ca.pem /etc/openldap/certs/.

# Test kerberos
kinit
klist
kdestroy

# Test DNS
host -t SRV _ldap._tcp.edt.org
host -t SRV _kerberos._udp.edt.or
host -t A edt.org
host -t ns edt.org

# Test samba
smbclient -L localhost -N
smbclient //localhost/netlogon -UAdministrator -c 'ls'

