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
cp /var/lib/samba/private/tls/ca.pem /etc/openldap/certs/.
echo "BASE    dc=edt,dc=org" >> /etc/openldap/ldap.conf
echo "URI     ldap://localhost" >> /etc/openldap/ldap.conf
echo "TLS_CACERT /var/lib/samba/private/tls/ca.pem" >> /etc/openldap/ldap.conf
echo "TLS_REQCERT allow" >> /etc/openldap/ldap.conf

# Test kerberos
echo "Test Kerberos"
kinit
klist
kdestroy

# Test DNS
echo "Test DNS"
host -t SRV _ldap._tcp.edt.org
host -t SRV _kerberos._udp.edt.or
host -t A edt.org
host -t ns edt.org

# Test samba
echo "Test Samba"
smbclient -L localhost -N
smbclient //localhost/netlogon -UAdministrator -c 'ls'

# Test LDAP
echo "Test LDAP"
ldapsearch -x  -LLL  -Z -D 'cn=Administrator,cn=Users,dc=edt,dc=org' -w Passw0rd -b 'CN=Users,dc=edt,dc=org' dn

# Test winbind
echo "test winbind"
wbinfo -u
wbinfo -g
getent passwd administrator
getent group EDT\\domain\ users
wbinfo --pam-logon EDT\\administrator

# ADUC
# https://wiki.samba.org/index.php/Maintaining_Unix_Attributes_in_AD_using_ADUC
#  Curses ADUC --> https://appimage.github.io/admin-tools/
#  Appimage --> https://download.opensuse.org/repositories/home:/dmulder:/YaST:/AppImage/AppImage/admin-tools-latest-x86_64.AppImage.mirrorlist
wget https://download.opensuse.org/repositories/home:/dmulder:/YaST:/AppImage/AppImage/admin-tools-latest-x86_64.AppImage
mv admin-tools-latest-x86_64.AppImage admin-tools
chmod +x admin-tools
./admin-tools

## RSAT
# Administrar el AD des de windows remotament
# https://wiki.samba.org/index.php/Installing_RSAT

# Pendent:
#   1- instal·lar RSAT
#   2 - verificar kinit de samba01
#   3 - crear més usuaris i grups del domini
#   4 - admin de kerberos

