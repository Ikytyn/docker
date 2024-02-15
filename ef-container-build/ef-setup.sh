#!/bin/bash

echo 'efadmin:efadmin' | chpasswd
# echo 'ruser:ruser' | chpasswd
# chown ruser /home/ruser


# insert ext ip in nat.conf
extip=`curl --silent http://169.254.169.254/latest/meta-data/public-ipv4`
if [[ $extip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ && "$ENV_HOST_HOSTNAME" != "" ]]; then
    if [ "`grep $ENV_HOST_HOSTNAME /opt/nice/enginframe/conf/plugins/interactive/nat.conf`" != "" ] ; then
	# replace entry with new IP 
	sed -i -e 's/'$ENV_HOST_HOSTNAME'.*/'$ENV_HOST_HOSTNAME' '$extip'/g' /opt/nice/enginframe/conf/plugins/interactive/nat.conf
    else
	echo "$ENV_HOST_HOSTNAME  $extip" >> /opt/nice/enginframe/conf/plugins/interactive/nat.conf
    fi
fi

/opt/nice/enginframe/bin/enginframe start
# service enginframe start

function f_terminate  {
    echo "TRAP SIGTERM received ...";
    }

trap 'f_terminate;  exit 0' SIGTERM

if [ "$1" == "nobash" ] ; then
    while true; do sleep 1; done
    tail -f /dev/null
else
    :
    # exec  /bin/bash --rcfile /etc/profile.d/openlava.sh
fi
