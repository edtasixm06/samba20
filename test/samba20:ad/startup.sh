#! /bin/bash
#
# SAMBA AD DC 
# Installation procedure
# 
# -------------------------------------------------------------------

#if [ $# -ne 3 -a $# -ne 4 ]; then
#  echo "Usage: $0 hostname domain ipout null|ipin" 
#  echo "example install.sh ad edt.org 52.7.195.3 172.31.56.17" 
#  echo "administrator/Passw0rd"
#  exit 1  
#fi

#hostname=$1
#domain=$2
#ipout=$3
#ipin=$4

hostname="ad"
domain="edt.org"
ipout="52.7.195.3"
ipin="172.18.0.2"

# Esborrar la configuració prèvia
echo "Esborrant configuració prèvia"
rm /etc/samba/smb.conf

# Fer el provisioning
# samba-tool domain provision --use-rfc2307 --interactive
echo "Fent el provisioning"
samba-tool domain provision --server-role=dc --use-rfc2307 --dns-backend=SAMBA_INTERNAL --realm=EDT.ORG --domain=EDT --adminpass=Passw0rd

# Generar la configuració client DNS
# cat /etc/resolv.conf
#search edt.org
#nameserver 172.19.0.2
cp /etc/resolv.conf /etc/resolv.bk
cat <<FI > /etc/resolv.conf
search $domain
nameserver $ipout
FI
cat /etc/resolv.conf

# Configurar correctament el nomd e host
#127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
#172.31.56.17 ad.edt.org ad
#172.31.56.17 ip-172-31-56-17
#52.7.195.3 ad.edt.org
#hostnamectl set-hostname $hostname.$domain
cp /etc/hosts /etc/hosts.bk
cat <<FI > /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
$ipout $hostname.$domain
FI
cat /etc/hosts

# Configurar kerberos
echo "Configurant kerberos"
cp /var/lib/samba/private/krb5.conf /etc/krb5.conf

# Modificar la configuració de samba generada per personalitzar
echo "Remplaçant configuració de samba"
cp smb.conf /etc/samba/smb.conf

# Activar el servei
echo "Activant el servei"
samba

# Activar la resolució nsswitch amb winbind
echo "Activant resolució winbind al nsswitch"
cp nsswitch.conf /etc/nsswitch.conf

# Configurar PAM
echo "Activant autenticació PAM amb winbind"
cp system-auth /etc/pam.d/system-auth

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
cp /var/lib/samba/private/tls/ca.pem /etc/openldap/certs/

# Modificar la configuració DNS per usar l'adreça externa pública
# en lloc de l'adreça interna
if [ -n "$ipin"  ]; then
  echo "modificant adreces DNS públiques"	
  samba-tool dns update $ipout $domain $hostname.$domain A $ipin $ipout -U administrator
  samba-tool dns update $ipout $domain $domain A $ipin $ipout -U administrator
fi	


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
#   2 - verificar kinit de samba10
#   3 - crear més usuaris i grups del domini
#   4 - admin de kerberos
#   5 - practicar ldbedit ....

cp /var/lib/samba/private/tls/ca.pem /etc/openldap/certs/
while [ 1 -ne 0 ]; do
  sleep 1
done
