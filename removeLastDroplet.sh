source .env
source .last

echo Removing $dropletNAME...

curl -X DELETE -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" "https://api.digitalocean.com/v2/droplets/$dropletID"

sleep 3
sh listDroplets.sh
