# Samba

## Samba al host (no docker)

Directori de dades i scripts: samba20:base/test/samba20:ad
Executar: ./install.sh ad edt.org 52.7.195.3 172.31.56.17
   - genera el provisioning, configura els fitxers i crea usuaris
   - ad nom del host
   - edt.org nom del domini
   - 52.7.195.3 adreça públic on actua el nameserver. Si és un host amb una sola adreça
                ja pública només cal aquest argument
   - 172.31.56.17 adreça interna. Si és un docker o un host de AWS EC2 que té una adreça interna
                i una adreça publica posar aqui la interna. En fer tota la configuració
                s'utilitza la externa, però el provisioning igualment posa la interna als registres
                de DNS. Llavors cal canviar amb samba-tool les entrades DNS per publicar
                l'adreça externa.


## Samba docker

1) **Atenció** Generar apropiadament /etc/resolv.conf i /etc/hosts
2)  posar les directives de enum (pel getent) al smb.comf

 docker run --rm --name ad.edt.org -h ad.edt.org --net 2hisix -p 53:53 -p 53:53/udp -p 88:88 -p 135:135 -p 137:137/udp -p 138:138/udp -p 139:139 -p 139:139/udp -p 389:389 -p 445:445 -p 464:464 -p 636:363 -p 3268:3268 -p 3269:3269 -p 49152:49152 -p 49153:49153 -p 49154:49154  --privileged -it edtasixm06/samba20:test-ad


