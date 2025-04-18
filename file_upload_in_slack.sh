#!/bin/bash

#set the variables according to your tokens and ID's
SLACK_TOKEN=" "
FILENAME=" "
CHANNEL_ID=" "

# Step 1: Get upload URL and file ID
response=$(curl -s -X POST -H "Authorization: Bearer $SLACK_TOKEN" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data "filename=$FILENAME&length=$(stat -c%s $FILENAME)" \
  https://slack.com/api/files.getUploadURLExternal)

# Parse upload_url and file_id from the response
upload_url=$(echo $response | jq -r '.upload_url')
file_id=$(echo $response | jq -r '.file_id')

# Check if both values are successfully retrieved
if [[ -z "$upload_url" || -z "$file_id" ]]; then
  echo "Error: Failed to retrieve upload URL or file ID."
  exit 1
fi

# Step 2: Upload the file using the upload_url
curl -F file=@$FILENAME -F "filename=$FILENAME" "$upload_url"

# Step 3: Complete the upload using the file ID and channel ID
curl -X POST -H "Authorization: Bearer $SLACK_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"files\": [{\"id\":\"$file_id\", \"title\":\"slack-test\"}], \"channel_id\": \"$CHANNEL_ID\"}" \  https://slack.com/api/files.completeUploadExternal

echo "File upload completed successfully!"
