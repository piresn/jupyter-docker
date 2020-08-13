# create droplet

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

sleep 10

scp -o StrictHostKeyChecking=no -o ServerAliveCountMax=20 -r docker/ root@$dropletIP:/root
ssh root@$dropletIP "cd docker; docker build -t jup .; docker run -d -p 8888:8888 --name labcont jup;"
ssh -L 8888:localhost:8888 -f -N root@$dropletIP


echo export dropletNAME=$dropletNAME > .last
echo export dropletID=$dropletID >> .last

echo '++++++++++++++++++++'
sh listDroplets.sh
echo Jupyter lab is now running at http://localhost:8888/lab
echo To stop portforwarding, use "pkill ssh" directly.
echo To destroy this droplet ($dropletNAME), run removeLastDroplet.sh
echo '++++++++++++++++++++'
