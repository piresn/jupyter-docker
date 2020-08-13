source .env

echo Existing droplets = $(curl -s -X GET -H "Content-Type: application/json" \
	-H "Authorization: Bearer $TOKEN" "https://api.digitalocean.com/v2/droplets" \
	| jq '.droplets[].name')

echo Existing volumes = $(curl -s -X GET -H "Content-Type: application/json" \
	-H "Authorization: Bearer $TOKEN" "https://api.digitalocean.com/v2/volumes" \
	| jq '.volumes[].name')