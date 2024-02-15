VENDOR=nisp
PROD=enginframe

docker=docker
docker=podman

$docker stop ef;

$docker build -t $VENDOR/$PROD . 

$docker tag  $VENDOR/$PROD  $VENDOR/$PROD:2021.0  # Add a new tag

# exit

# create users for testing
#if ! id "ruser" >/dev/null 2>&1; then
#    echo useradd -u 1010 ruser
#    sudo useradd -u 1010 ruser
#fi

# echo docker create  -v /opt --name appzupdata busybox  /bin/true
echo "#!/bin/bash
$docker stop ef;
$docker rm ef;
# -p 8080:8080 -p 8553:8553 -p 8445:8445 
#  -v /opt/nice/enginframe/spoolers:/opt/nice/enginframe/spoolers -v /opt/nice/enginframe/sessions:/opt/nice/enginframe/sessions
$docker run -e ENV_HOST_HOSTNAME=\$(hostname) --privileged -d -h master  -v /usr/bin/$docker:/usr/bin/$docker:ro -v /lib/x86_64-linux-gnu/libseccomp.so.2:/lib64/libseccomp.so.2:ro  -v /lib/x86_64-linux-gnu/libapparmor.so.1:/lib64/libapparmor.so.1:ro -v /lib/x86_64-linux-gnu/libdevmapper.so.1.02.1:/lib64/libdevmapper.so.1.02.1:ro  --name ef --network="host" $VENDOR/$PROD 
echo You can start a shell inside the EF container with: podman exec -it ef bash
extip=\`curl --silent http://169.254.169.254/latest/meta-data/public-ipv4\`
if [[ \$extip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}\$ ]] ; then
   echo The EnginFrame Url is: https://\$extip:8553
fi

" > startef.sh

chmod 755 startef.sh

