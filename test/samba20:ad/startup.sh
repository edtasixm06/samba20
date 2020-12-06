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
cp /etc/resolv.conf /etc/resolv.bk
cp /opt/docker/resolv.conf /etc/resolv.conf


# Configurar kerberos
cp /var/lib/samba/private/krb5.conf /etc/krb5.conf

# Modificar la configuració de samba generada per personalitzar
cp /opt/docker/smb.conf /etc/samba/smb.conf

# Activar el servei
samba

# Activar la resolució nsswitch amb winbind
cp /opt/docker/nsswitch.conf /etc/nsswitch.conf

# Configurar PAM
cp /opt/docker/system-auth /etc/pam.d/system-auth

# Crear usuaris samba
echo "creant usuari samba10 .. 11 .. 12"
samba-tool user create samba10 Samba10
samba-tool user create samba11 Samba11
samba-tool user create samba12 Samba12

# Configurar el client ldap
#cp /opt/docker/ldap.conf /etc/openldap/ldap.conf
echo "BASE    dc=edt,dc=org" >> /etc/openldap/ldap.conf
echo "URI     ldap://localhost" >> /etc/openldap/ldap.conf
echo "TLS_CACERT /var/lib/samba/private/tls/ca.pem" >> /etc/openldap/ldap.conf
echo "TLS_REQCERT allow" >> /etc/openldap/ldap.conf
cp /var/lib/samba/private/tls/ca.pem /etc/openldap/certs/.


# Test de configuració
echo  "-------------------------------"
echo  "Executa el test de coniguració"
echo  "bash startup-test.sh"
echo  " administrator / Passw0rd "
echo  "-------------------------------"


# ADUC
# https://wiki.samba.org/index.php/Maintaining_Unix_Attributes_in_AD_using_ADUC
#  Curses ADUC --> https://appimage.github.io/admin-tools/
#  Appimage --> https://download.opensuse.org/repositories/home:/dmulder:/YaST:/AppImage/AppImage/admin-tools-latest-x86_64.AppImage.mirrorlist
# (( ja estan incorporades a la imatge docker ))
# wget https://download.opensuse.org/repositories/home:/dmulder:/YaST:/AppImage/AppImage/admin-tools-latest-x86_64.AppImage
# mv admin-tools-latest-x86_64.AppImage admin-tools
# chmod +x admin-tools
# ./admin-tools

## RSAT
# Administrar el AD des de windows remotament
# https://wiki.samba.org/index.php/Installing_RSAT

# Pendent:
#   1- instal·lar RSAT
#   2 - verificar kinit de samba01
#   3 - crear més usuaris i grups del domini
#   4 - admin de kerberos
#   5 - practicar ldbedit ....

/bin/bash
