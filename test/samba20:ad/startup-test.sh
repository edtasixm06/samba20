#! /bin/bash

# user: administrator
# passwd: Passw0rd

# Test kerberos
echo "Test Kerberos"
kinit administrator
klist
kdestroy

# Test DNS
echo "Test DNS"
host -t SRV _ldap._tcp.edt.org
host -t SRV _kerberos._udp.edt.org
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
