#! /bin/bash
docker run --rm --name samba.edt.org -h samba.edt.org --net 2hisix -p 137:137 -p 138:138 -p 139:139 -p 445:445 -it edtasixm06/samba20:test-dc

