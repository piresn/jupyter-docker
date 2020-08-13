# create droplet

source .env

dropletNAME=docker-$(date | tr -d " " | tr -d :)

dropletID=$(curl -X POST "https://api.digitalocean.com/v2/droplets" \
	-d '{"name":"'$dropletNAME'","region":"'$REGION'","size":"s-1vcpu-1gb","image":"docker-18-04","ssh_keys":["'$FINGERPRINT'"]}' \
	-H "Authorization: Bearer $TOKEN" \
	-H "Content-Type: application/json" | jq '.droplet.id')

echo creating droplet with id $dropletID...

sleep 10

# retrieve ip
dropletIP=$(curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" "https://api.digitalocean.com/v2/droplets/$dropletID" | jq '.droplet.networks.v4[0].ip_address' | tr -d \")

echo droplet IP = $dropletIP
echo Preparing droplet...

scp -o StrictHostKeyChecking=no -o ServerAliveCountMax=20 -r docker/ root@$dropletIP:/root
ssh root@$dropletIP "cd docker; docker build -t jup .; docker run -d -p 8888:8888 --name labcont jup;"
ssh -L 8888:localhost:8888 -f -N root@$dropletIP

echo '++++++++++++++++++++'
echo Finished. Jupyter lab is now running at http://localhost:8888/lab
echo '++++++++++++++++++++'
echo To stop portforwarding, use "pkill ssh" directly.
echo
echo To destroy droplet, use
echo
echo source .env
echo curl -X DELETE -H \"Content-Type: application/json\" -H \"Authorization: Bearer \$TOKEN\" \"https://api.digitalocean.com/v2/droplets/$dropletID\"
echo
echo '++++++++++++++++++++'
