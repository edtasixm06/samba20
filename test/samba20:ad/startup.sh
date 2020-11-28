#! /bin/bash

# Esborrar la configuració prèvia
rm /etc/samba/smb.conf

# Fer el provisioning
# samba-tool domain provision --use-rfc2307 --interactive
samba-tool domain provision --server-role=dc --use-rfc2307 --dns-backend=SAMBA_INTERNAL --realm=EDT.ORG --domain=EDT --adminpass=Passw0rd

# Generar la configuració client DNS
# del /etc/resolv.conf

# Configurar kerberos
cp /var/lib/samba/private/krb5.conf /etc/krb5.conf

# Activar el servei
samba
