#! /bin/bash

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

cp smb.alone.conf /etc/samba/smb.conf
/sbin/smbd
