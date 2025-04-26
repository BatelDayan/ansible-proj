#!/bin/bash 
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com/) 
ZONE_ID="my zone id" # Replace with your actual hosted zone ID
NAME="my domain name" # Replace with your actual domain name

json=$(aws route53 list-resource-record-sets --hosted-zone-id $ZONE_ID --query "ResourceRecordSets[?Name == $NAME && Type == 'A']") 
change_batch=$(echo "$json" | jq --arg ip "$PUBLIC_IP" '{
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": (.[0] | .ResourceRecords[0].Value = $ip)
    }
  ]
}')

aws route53 change-resource-record-sets \
  --hosted-zone-id "$ZONE_ID" \
  --change-batch "$change_batch"
