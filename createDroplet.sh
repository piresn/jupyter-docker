# create droplet

while getopts v: flag
	do
	    case "${flag}" in
	        v) VOLUMENAME=${OPTARG};;
	    esac
	done;


source .env

CPU=1
MEM=1
dropletSIZE=$(echo s-$CPU vcpu- $MEM gb | tr -d ' ')
dropletNAME=docker-$(date | tr -d " " | tr -d :)
dropletIMAGE=docker-18-04

echo creating droplet $dropletNAME...

dropletID=$(curl -s -X POST "https://api.digitalocean.com/v2/droplets" \
	-d '{"name":"'$dropletNAME'","region":"'$REGION'","size":"'$dropletSIZE'","image":"'$dropletIMAGE'","ssh_keys":["'$FINGERPRINT'"]}' \
	-H "Authorization: Bearer $TOKEN" \
	-H "Content-Type: application/json" | jq '.droplet.id')

echo droplet ID = $dropletID

sleep 10

# retrieve ip
dropletIP=$(curl -s -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" "https://api.digitalocean.com/v2/droplets/$dropletID" | jq '.droplet.networks.v4[0].ip_address' | tr -d \")

echo droplet IP = $dropletIP
echo Preparing droplet...

sleep 5

# add volume
echo Adding volume $VOLUMENAME
curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d '{"type": "attach", "volume_name": "'$VOLUMENAME'", "region": "'$REGION'", "droplet_id": "'$dropletID'","tags":["aninterestingtag"] }' "https://api.digitalocean.com/v2/volumes/actions"

sleep 10

scp -o StrictHostKeyChecking=no -o ServerAliveCountMax=20 -r docker/ root@$dropletIP:/root

ssh root@$dropletIP "mkdir -p /mnt/persistent_storage; \
	mount -o discard,defaults,noatime /dev/disk/by-id/scsi-0DO_Volume_$VOLUMENAME /mnt/persistent_storage; \
	cd docker; \
	docker-compose up -d;"

ssh -L 8888:localhost:8888 -f -N root@$dropletIP


echo export dropletNAME=$dropletNAME > .last
echo export dropletID=$dropletID >> .last

echo
echo '++++++++++++++++++++'
sh listDroplets.sh
echo Droplet $dropletNAME $dropletID has IP $dropletIP
echo Jupyter lab is now running at http://localhost:8888/lab
echo To restart port-forwarding use
echo ssh -L 8888:localhost:8888 -f -N root@$dropletIP
echo To stop portforwarding, use "pkill ssh" directly.
echo To destroy this droplet - $dropletNAME - run removeLastDroplet.sh
echo '++++++++++++++++++++'
