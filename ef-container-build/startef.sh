#!/bin/bash
podman stop ef;
podman rm ef;
# -p 8080:8080 -p 8553:8553 -p 8445:8445 
#  -v /opt/nice/enginframe/spoolers:/opt/nice/enginframe/spoolers -v /opt/nice/enginframe/sessions:/opt/nice/enginframe/sessions
podman run -e ENV_HOST_HOSTNAME=$(hostname) --privileged -d -h master  -v /usr/bin/podman:/usr/bin/podman:ro -v /usr/lib64/libseccomp.so.2:/lib64/libseccomp.so.2:ro  -v /usr/local/lib/libapparmor.so.1:/lib64/libapparmor.so.1:ro -v /usr/lib64/libdevmapper.so.1.02:/lib64/libdevmapper.so.1.02.1:ro  --name ef -p 8080:8080 -p 8553:8553 -p 8446:8445 nisp/enginframe 
echo You can start a shell inside the EF container with: podman exec -it ef bash
extip=`hostname -I`
   echo The EnginFrame Url is: https://$extip:8553


