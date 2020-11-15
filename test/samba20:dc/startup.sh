#! /bin/bash
cp /opt/docker/smb.dc.conf /etc/samba/smb.conf


mkdir /var/lib/samba/public && chmod 777 /var/lib/samba/public
cp /usr/bin/cal /usr/bin/date /var/lib/samba/public
date > /var/lib/samba/public/date.txt
uname -a > /var/lib/samba/public/uname.txt
useradd pere
useradd pau
useradd anna
echo -e "pere\npere" | smbpasswd -a -s pere
echo -e "pau\npau" | smbpasswd -a -s pau
echo -e "anna\nanna" | smbpasswd -a -s anna
groupadd WinAdmins
groupadd WinUsers
groupadd WinGuests
groupadd WinBackupOperators
groupadd WinRestoreOperators
usermod -g WinAdmins -G WinUsers pere
usermod -g WinBackupOperators -G WinUsers pau
usermod -g WinRestoreOperators -G WinUsers anna

/sbin/smbd
/sbin/nmbd

echo -e "jupiter\njupiter" | smbpasswd -a root
net groupmap add ntgroup="Domain Admins" unixgroup=WinAdmins rid=512 type=d
net groupmap add ntgroup="Domain Users" unixgroup=WinUsers rid=513 type=d
net groupmap add ntgroup="Domain Guests" unixgroup=WinGuests rid=514 type=d
net groupmap add ntgroup="Domain Backup Operators" unixgroup=WinBackupOperators rid=515 type=d
net groupmap add ntgroup="Domain Restore Operators" unixgroup=WinRestoreOperators rid=516 type=d
net groupmap list
echo  "jupiter" | net rpc rights grant "SAMBADOMAIN\Domain Admins" SeMachineAccountPrivilege -U root
echo  "jupiter" | net rpc rights grant "SAMBADOMAIN\Domain Admins" SePrintOperatorPrivilege -U root
echo  "jupiter" | net rpc rights grant "SAMBADOMAIN\Domain Admins" SeAddUsersPrivilege -U root
echo  "jupiter" | net rpc rights grant "SAMBADOMAIN\Domain Admins" SeRemoteShutdownPrivilege -U root
echo  "jupiter" | net rpc rights grant "SAMBADOMAIN\Domain Admins" SeDiskOperatorPrivilege -U root
echo  "jupiter" | net rpc rights grant "SAMBADOMAIN\Domain Admins" SeTakeOwnershipPrivilege -U root
echo  "jupiter" | net rpc rights grant "SAMBADOMAIN\Domain Backup Operators" SeBackupPrivilege -U root
echo  "jupiter" | net rpc rights grant "SAMBADOMAIN\Domain Restore Operators" SeRestorePrivilege -U root
echo "" | net rpc rights list 

useradd -M -s /sbin/nologin ZULU$
smbpasswd -m -a ZULU$
useradd -M -s /sbin/nologin WIN10$
smbpasswd -m -a WIN10$

