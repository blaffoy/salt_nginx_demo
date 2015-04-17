#!/bin/bash
FILE_ROOT=$(dirname $(readlink -e $0))
FQDN=$(host -Tta $(hostname -s) | grep "has address" | awk '{print $1}')

# prepare the environment for salt config
mkdir -p /srv/
rm /srv/salt && ln -svf $FILE_ROOT/saltstate /srv/salt
rm /srv/pillar && ln -svf $FILE_ROOT/pillar /srv/pillar

# install salt from the custom apt repo
add-apt-repository ppa:saltstack/salt -y
apt-get update -y
apt-get install salt-master salt-minion salt-cloud -y

# prepare base salt install:
# must set the local minions' master to localhost; accept the key; set the
# salt-master role, and finally state.highstate
echo "master: localhost" > /etc/salt/minion
salt-call test.ping || true # this ensures that the minion key is waiting to be accepted
salt-key -y -a $FQDN
salt-call grains.setval roles ['salt-master']
salt-call state.highstate

# deploy the machine configuration in saltstate/map.sls to EC2
salt-cloud -m ${FILE_ROOT}/saltstate/map.sls -y -P

# horrible text munging for the win!
# This is likely to be very brittle in the face of any unexpected errors. Better
# long term solution would be to extract this info from some custom salt grain
LBADDR=$(salt -G roles:loadbalancer grains.get public_ip | tail -n 1 | awk '{print $1}')
TESTADDR=$(salt -G roles:testserver grains.get public_ip | tail -n 1 | awk '{print $1}')

echo "Production service is available at http://$LBADDR:8080/companyNews"
echo "Test service is available at http://$TESTADDR:8080/companyNews"
