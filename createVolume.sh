source .env

NAME=$1
SIZE=$2

curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d '{"size_gigabytes":'$SIZE', "name": "'$NAME'", "region": "'$REGION'", "filesystem_type": "ext4", "filesystem_label": "'$NAME'"}' "https://api.digitalocean.com/v2/volumes"