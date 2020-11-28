#! /bin/bash
docker run --rm --name dc.edt.org -h dc.edt.org --net 2hisix -p 137:137/udp -p 138:138/udp -p 139:139/tcp -p 139:139/udp -p 445:445 -it edtasixm06/samba20:test-dc

