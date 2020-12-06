# Samba

1) **Atenció** Generar apropiadament /etc/resolv.conf i /etc/hosts
2)  posar les directives de enum (pel getent) al smb.comf

 docker run --rm --name ad.edt.org -h ad.edt.org --net 2hisix -p 53:53 -p 53:53/udp -p 88:88 -p 135:135 -p 137:137/udp -p 138:138/udp -p 139:139 -p 139:139/udp -p 389:389 -p 445:445 -p 464:464 -p 636:363 -p 3268:3268 -p 3269:3269 -p 49152:49152 -p 49153:49153 -p 49154:49154  --privileged -it edtasixm06/samba20:test-ad


