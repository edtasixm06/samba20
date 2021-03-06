# SAMBA AD


#### Install:
```
dnf -y install  samba samba-client samba-dc


#### Esborrar configuració prèvia:
```
rm /etc/samba/smb.conf
```

#### Fer el provisioning:
```
[root@ad docker]# samba-tool domain provision --server-role=dc --use-rfc2307 --dns-backend=SAMBA_INTERNAL --realm=EDT.ORG --domain=EDT --adminpass=Passw0rd
Looking up IPv4 addresses
Looking up IPv6 addresses
No IPv6 address will be assigned
Setting up share.ldb
Setting up secrets.ldb
Setting up the registry
Setting up the privileges database
Setting up idmap db
Setting up SAM db
Setting up sam.ldb partitions and settings
Setting up sam.ldb rootDSE
Pre-loading the Samba 4 and AD schema
Adding DomainDN: DC=edt,DC=org
Adding configuration container
Setting up sam.ldb schema
Setting up sam.ldb configuration data
Setting up display specifiers
Modifying display specifiers
Adding users container
Modifying users container
Adding computers container
Modifying computers container
Setting up sam.ldb data
Setting up well known security principals
Setting up sam.ldb users and groups
Setting up self join
Adding DNS accounts
Creating CN=MicrosoftDNS,CN=System,DC=edt,DC=org
Creating DomainDnsZones and ForestDnsZones partitions
Populating DomainDnsZones and ForestDnsZones partitions
Setting up sam.ldb rootDSE marking as synchronized
Fixing provision GUIDs
The Kerberos KDC configuration for Samba AD is located at /var/lib/samba/private/kdc.conf
A Kerberos configuration suitable for Samba AD has been generated at /var/lib/samba/private/krb5.conf
Merge the contents of this file with your system krb5.conf or replace it with this one. Do not create a symlink!
Setting up fake yp server settings
Once the above files are installed, your Samba AD server will be ready to use
Server Role:           active directory domain controller
Hostname:              ad
NetBIOS Domain:        EDT
DNS Domain:            edt.org
DOMAIN SID:            S-1-5-21-2003500921-2819830493-478582650
```

#### Confiurar la resolució DNS:
```
[root@ad docker]# cat /etc/resolv.conf
search edt.org
nameserver 172.19.0.2
options ndots:0
```

#### Configurar kerberos
```
[root@ad docker]# cp /var/lib/samba/private/krb5.conf /etc/.

[root@ad docker]# cat /etc/krb5.conf
[libdefaults]
	default_realm = EDT.ORG
	dns_lookup_realm = false
	dns_lookup_kdc = true
```

#### Activar i test de funcionament de samba

```
[root@ad docker]# samba

[root@ad docker]# ps ax
  PID TTY      STAT   TIME COMMAND
    1 pts/0    Ss     0:00 /bin/bash
   87 ?        Ss     0:00 samba
   88 ?        S      0:00 samba
   89 ?        S      0:00 samba
   90 ?        S      0:00 samba
   91 ?        S      0:00 samba
   92 ?        S      0:00 samba
   93 ?        Ss     0:00 /usr/sbin/smbd -D --option=server role check:inhibit=yes --foreground
   94 ?        R      0:00 samba
   95 ?        S      0:00 samba
   96 ?        S      0:00 samba
   97 ?        S      0:00 samba
   98 ?        S      0:00 samba
   99 ?        S      0:00 samba
  100 ?        S      0:00 samba
  101 ?        S      0:00 /usr/sbin/krb5kdc -n
  102 ?        S      0:00 samba
  103 ?        S      0:00 samba
  104 ?        Ss     0:00 /usr/sbin/winbindd -D --option=server role check:inhibit=yes --foreground
  105 ?        S      0:00 samba
  106 ?        S      0:00 samba
  109 ?        S      0:00 samba
  110 ?        R      0:00 /usr/bin/python2 /usr/sbin/samba_dnsupdate
  115 ?        S      0:00 /usr/sbin/smbd -D --option=server role check:inhibit=yes --foreground
  116 ?        S      0:00 /usr/sbin/smbd -D --option=server role check:inhibit=yes --foreground
  117 ?        S      0:00 /usr/sbin/winbindd -D --option=server role check:inhibit=yes --foreground
  118 ?        S      0:00 /usr/sbin/smbd -D --option=server role check:inhibit=yes --foreground
  120 pts/0    R+     0:00 ps ax


[root@ad docker]# testparm 
Load smb config files from /etc/samba/smb.conf
Processing section "[netlogon]"
Processing section "[sysvol]"
Loaded services file OK.
Server role: ROLE_ACTIVE_DIRECTORY_DC

Press enter to see a dump of your service definitions
```


Llistat de shares, prova de connectivitat:
```
root@ad docker]# smbclient -L localhost
Enter EDT\GUEST's password: 
Anonymous login successful

	Sharename       Type      Comment
	---------       ----      -------
	netlogon        Disk      
	sysvol          Disk      
	IPC$            IPC       IPC Service (Samba 4.7.10)
Reconnecting with SMB1 for workgroup listing.
Anonymous login successful

	Server               Comment
	---------            -------

	Workgroup            Master
	---------            -------
```

Llistat de ports del servidor:
```
[root@ad docker]# nmap localhost

Starting Nmap 7.60 ( https://nmap.org ) at 2020-11-28 17:37 UTC
Nmap scan report for localhost (127.0.0.1)
Host is up (0.000037s latency).
Other addresses for localhost (not scanned): ::1
Not shown: 987 closed ports
PORT      STATE SERVICE
53/tcp    open  domain
88/tcp    open  kerberos-sec
135/tcp   open  msrpc
139/tcp   open  netbios-ssn
389/tcp   open  ldap
445/tcp   open  microsoft-ds
464/tcp   open  kpasswd5
636/tcp   open  ldapssl
3268/tcp  open  globalcatLDAP
3269/tcp  open  globalcatLDAPssl
49152/tcp open  unknown
49153/tcp open  unknown
49154/tcp open  unknown
```

Verificar l'accés al share *netlogon* amb l'usuari *Administrator*:
```
[root@ad docker]# smbclient //localhost/netlogon -UAdministrator -c 'ls'
Enter EDT\Administrator's password: 
  .                                   D        0  Sat Nov 28 17:13:40 2020
  ..                                  D        0  Sat Nov 28 17:13:45 2020

		35119764 blocks of size 1024. 14179140 blocks available
```


#### Verificació dels registres de recurs de DNS
```
[root@ad docker]# host edt.org
edt.org has address 172.19.0.2

[root@ad docker]# host ad.edt.org
ad.edt.org has address 172.19.0.2

[root@ad docker]# host -t SRV _ldap._tcp.edt.org
_ldap._tcp.edt.org has SRV record 0 100 389 ad.edt.org.

[root@ad docker]# host -t SRV _kerberos._udp.edt.org
_kerberos._udp.edt.org has SRV record 0 100 88 ad.edt.org.

[root@ad docker]# host -t a ad.edt.org
ad.edt.org has address 172.19.0.2

root@ad docker]# host -t ns edt.org
edt.org name server ad.edt.org.
[root@ad docker]# 
[root@ad docker]# host -t axfr edt.org
Trying "edt.org"
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 58653
;; flags: qr aa ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 0

;; QUESTION SECTION:
;edt.org.			IN	AXFR

;; AUTHORITY SECTION:
edt.org.		3600	IN	SOA	ad.edt.org. hostmaster.edt.org. 1 900 600 86400 3600
```

#### Verificar funcionament de kerberos

Cal tenir instal3lat el paquet client *krb5-workstation*
```
[root@ad docker]# kinit Administrator
Password for Administrator@EDT.ORG: 

[root@ad docker]# klist 
Ticket cache: FILE:/tmp/krb5cc_0
Default principal: Administrator@EDT.ORG

Valid starting     Expires            Service principal
11/28/20 17:55:37  11/29/20 03:55:37  krbtgt/EDT.ORG@EDT.ORG
	renew until 11/29/20 17:55:32

[root@ad docker]# kdestroy 
```

#### Miscel·lània
```
smbstatus
smb -b 
```


#### Winbind

# Configurar /etc/nsswitch.conf per usar winbind
```
passwd:     files winbind systemd
shadow:     files sss
group:      files winbind systemd
```

# Cal tenir instal·lat samba-winbind-clients
[root@ad docker]# wbinfo --ping-dc
checking the NETLOGON for domain[EDT] dc connection to "ad.edt.org" succeeded

[root@ad docker]# wbinfo -a Administrator
Enter Administrator's password: 
plaintext password authentication succeeded
Enter Administrator's password: 
challenge/response password authentication succeeded

[root@ad docker]# wbinfo --all-domains
BUILTIN
EDT

[root@ad docker]# wbinfo -i EDT\\administrator
EDT\administrator:*:0:100::/home/EDT/administrator:/bin/false

[root@ad docker]# getent passwd EDT\\administrator
EDT\administrator:*:0:100::/home/EDT/administrator:/bin/false
``` 

Llistat d'informació
``` 
[root@ad docker]# wbinfo -D EDT
Name              : EDT
Alt_Name          : edt.org
SID               : S-1-5-21-2003500921-2819830493-478582650
Active Directory  : Yes
Native            : Yes
Primary           : Yes

[root@ad docker]# wbinfo -u
EDT\administrator
EDT\guest
EDT\krbtgt

root@ad docker]# wbinfo -g    
EDT\cert publishers
EDT\ras and ias servers
EDT\allowed rodc password replication group
EDT\denied rodc password replication group
EDT\dnsadmins
EDT\enterprise read-only domain controllers
EDT\domain admins
EDT\domain users
EDT\domain guests
EDT\domain computers
EDT\domain controllers
EDT\schema admins
EDT\enterprise admins
EDT\group policy creator owners
EDT\read-only domain controllers
EDT\dnsupdateproxy

[root@ad docker]# wbinfo --pam-logon EDT\\administrator
Enter EDT\administrator's password: 
plaintext password authentication succeeded
```


#### Autenticació PAM pam_winbind.so


```
[root@ad docker]# ls /usr/lib64/security/pam_winbind.so 
/usr/lib64/security/pam_winbind.so


```

#### Test connectivitat ldap

Cal tenir instal·lat *openldap-clients*
```
$ ldapsearch -vx -LLL -h 172.19.0.2 -D 'cn=Administrator,cn=edt,dc=org' -w Passw0rd
ldap_initialize( ldap://172.19.0.2 )
ldap_bind: Strong(er) authentication required (8)
	additional info: BindSimple: Transport encryption required.

[root@ad docker]# ldapsearch -x  -LLL  -Z -D 'cn=Administrator,cn=Users,dc=edt,dc=org' -w Passw0rd -b 'dc=edt,dc=org'

[root@ad docker]# ldapsearch -x  -LLL  -Z -D 'cn=Administrator,cn=Users,dc=edt,dc=org' -w Passw0rd -b 'dc=edt,dc=org' 'cn=samba01'
dn: CN=samba01,CN=Users,DC=edt,DC=org
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: user
cn: samba01
instanceType: 4
whenCreated: 20201128201058.0Z
uSNCreated: 3769
name: samba01
objectGUID:: SN94FVovvEuT4mm9ueuDsQ==
badPwdCount: 0
codePage: 0
countryCode: 0
badPasswordTime: 0
lastLogoff: 0
primaryGroupID: 513
objectSid:: AQUAAAAAAAUVAAAAPrR3fNk6AZLwayyUTwQAAA==
accountExpires: 9223372036854775807
sAMAccountName: samba01
sAMAccountType: 805306368
objectCategory: CN=Person,CN=Schema,CN=Configuration,DC=edt,DC=org
userAccountControl: 512
pwdLastSet: 132510678580000000
lastLogonTimestamp: 132510679004229280
whenChanged: 20201128201140.0Z
uSNChanged: 3779
lastLogon: 132510689132533700
logonCount: 1
distinguishedName: CN=samba01,CN=Users,DC=edt,DC=org
# refldap://edt.org/CN=Configuration,DC=edt,DC=org
# refldap://edt.org/DC=DomainDnsZones,DC=edt,DC=org
# refldap://edt.org/DC=ForestDnsZones,DC=edt,DC=org

[root@ad docker]# ldapsearch -x  -LLL  -Z -D 'cn=Administrator,cn=Users,dc=edt,dc=org' -w Passw0rd -b 'dc=edt,dc=org' -s one dn
dn: CN=LostAndFound,DC=edt,DC=org
dn: CN=Builtin,DC=edt,DC=org
dn: OU=Domain Controllers,DC=edt,DC=org
dn: CN=System,DC=edt,DC=org
dn: CN=Program Data,DC=edt,DC=org
dn: CN=NTDS Quotas,DC=edt,DC=org
dn: CN=Users,DC=edt,DC=org
dn: CN=ForeignSecurityPrincipals,DC=edt,DC=org
dn: CN=Infrastructure,DC=edt,DC=org
dn: CN=Computers,DC=edt,DC=org
# refldap://edt.org/CN=Configuration,DC=edt,DC=org??base
# refldap://edt.org/DC=DomainDnsZones,DC=edt,DC=org??base
# refldap://edt.org/DC=ForestDnsZones,DC=edt,DC=org??base

root@ad docker]# ldapsearch -x  -LLL  -Z -D 'cn=Administrator,cn=Users,dc=edt,dc=org' -w Passw0rd -b 'CN=computers,dc=edt,dc=org'     
dn: CN=DM,CN=Computers,DC=edt,DC=org
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: user
objectClass: computer
cn: DM
instanceType: 4
whenCreated: 20201128204448.0Z
whenChanged: 20201128204448.0Z
uSNCreated: 3781
name: DM
objectGUID:: EkG0eFdDu0yz74YBlJMayA==
badPwdCount: 0
codePage: 0
countryCode: 0
badPasswordTime: 0
lastLogoff: 0
primaryGroupID: 515
objectSid:: AQUAAAAAAAUVAAAAPrR3fNk6AZLwayyUUgQAAA==
accountExpires: 9223372036854775807
sAMAccountName: DM$
sAMAccountType: 805306369
objectCategory: CN=Computer,CN=Schema,CN=Configuration,DC=edt,DC=org
isCriticalSystemObject: FALSE
msDS-SupportedEncryptionTypes: 31
userAccountControl: 69632
pwdLastSet: 132510698882824660
dNSHostName: dm.edt.org
servicePrincipalName: HOST/DM
servicePrincipalName: HOST/dm.edt.org
lastLogonTimestamp: 132510698885866770
uSNChanged: 3785
lastLogon: 132510702771054340
logonCount: 5
distinguishedName: CN=DM,CN=Computers,DC=edt,DC=org

dn: CN=Computers,DC=edt,DC=org
objectClass: top
objectClass: container
cn: Computers
instanceType: 4
whenCreated: 20201128201054.0Z
whenChanged: 20201128201054.0Z
uSNCreated: 3374
name: Computers
objectGUID:: +D/N8Sr3KEe0kORhxjxDBA==
objectCategory: CN=Container,CN=Schema,CN=Configuration,DC=edt,DC=org
description: Default container for upgraded computer accounts
systemFlags: -1946157056
isCriticalSystemObject: TRUE
showInAdvancedViewOnly: FALSE
uSNChanged: 3375
distinguishedName: CN=Computers,DC=edt,DC=org


[root@ad docker]# ldapsearch -x  -LLL  -Z -D 'cn=Administrator,cn=Users,dc=edt,dc=org' -w Passw0rd -b 'CN=Users,dc=edt,dc=org' dn
dn: CN=Allowed RODC Password Replication Group,CN=Users,DC=edt,DC=org
dn: CN=samba03,CN=Users,DC=edt,DC=org
dn: CN=DnsUpdateProxy,CN=Users,DC=edt,DC=org
dn: CN=Domain Guests,CN=Users,DC=edt,DC=org
dn: CN=Users,DC=edt,DC=org
dn: CN=RAS and IAS Servers,CN=Users,DC=edt,DC=org
dn: CN=Domain Computers,CN=Users,DC=edt,DC=org
dn: CN=Domain Users,CN=Users,DC=edt,DC=org
dn: CN=Administrator,CN=Users,DC=edt,DC=org
dn: CN=Enterprise Admins,CN=Users,DC=edt,DC=org
dn: CN=DnsAdmins,CN=Users,DC=edt,DC=org
dn: CN=Cert Publishers,CN=Users,DC=edt,DC=org
dn: CN=Read-only Domain Controllers,CN=Users,DC=edt,DC=org
dn: CN=Denied RODC Password Replication Group,CN=Users,DC=edt,DC=org
dn: CN=Schema Admins,CN=Users,DC=edt,DC=org
dn: CN=Guest,CN=Users,DC=edt,DC=org
dn: CN=Enterprise Read-only Domain Controllers,CN=Users,DC=edt,DC=org
dn: CN=Group Policy Creator Owners,CN=Users,DC=edt,DC=org
dn: CN=krbtgt,CN=Users,DC=edt,DC=org
dn: CN=Domain Admins,CN=Users,DC=edt,DC=org
dn: CN=Domain Controllers,CN=Users,DC=edt,DC=org
dn: CN=samba02,CN=Users,DC=edt,DC=org
dn: CN=samba01,CN=Users,DC=edt,DC=org
```


# Creació d'usuaris

CN=samba01,CN=Users,DC=edt,DC=org

```
[root@ad docker]# smbpasswd -a samba03
New SMB password:  Samba03
Retype new SMB password: Samba03
Added user samba03.

[root@ad docker]# pdbedit -L
AD$:3000019:
Administrator:0:
samba01:3000020:
samba02:3000021:
samba03:3000022:
krbtgt:3000023:
nobody:99:Nobody

[root@ad docker]# smbclient //localhost/netlogon -U samba01
Enter EDT\samba01's password: 
Try "help" to get a list of possible commands.
smb: \> 

```


## SMB.CONF

atenció, cal afegir al que genera automàticament samba-provisioning les 
següents línies al /etc/samba/smb.conf
```
        ;Permet a getent llistar els usuaris
        winbind enum users = yes
        winbind enum groups = yes

        ; assignar un shell i un home generic
        ; atenció, sinó el shell /bin/bash i inicia i tanca sessió automàticament
        template shell = /bin/bash
        template homedir = /home/%U

```
