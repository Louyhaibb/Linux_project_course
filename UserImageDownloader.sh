#!/usr/bin/env bash

# Log file
LogFile="ErrorFiles.log"
touch "$LogFile"

# Check for folder name and ID arguments
if [ -z "$1" ]; then
    echo "Error: You must provide a folder name." >> "$LogFile"
    exit 1
fi

if [ -z "$2" ]; then
    echo "Error: You must provide at least one ID." >> "$LogFile"
    exit 2
fi

# Store arguments in array
ArgumentsArray=("$@")

# Folder name and API base URL
FolderName="$1"
ApiBaseUrl="https://reqres.in/api/users"

# Create folder if it doesn't exist
mkdir -p "$FolderName"

# Loop through provided IDs
for ((i = 1; i < ${#ArgumentsArray[@]}; i++)); do
    UserId="${ArgumentsArray[$i]}"
    ApiResponse=$(curl -s "$ApiBaseUrl/$UserId")
    if [ "$(echo "$ApiResponse" | jq -r '.data')" != "null" ]; then
        UserName=$(echo "$ApiResponse" | jq -r '.data.first_name')
        UserLastName=$(echo "$ApiResponse" | jq -r '.data.last_name')
        AvatarUrl=$(echo "$ApiResponse" | jq -r '.data.avatar')
        FileName="${UserId}_${UserName}_${UserLastName}.jpg"
        FilePath="$(pwd)/$FolderName/$FileName"
        curl -s "$AvatarUrl" -o "$FilePath"
    else
        echo "Error: There is no user with ID $UserId in the API." >> "$LogFile"
    fi
done

# Log user information
Username=$(whoami)
DateTime=$(date +%Y-%m-%d-%H:%M:%S:%N)
BranchName=$(git branch --show-current)
echo "User name: $Username" >> "$LogFile"
echo "Current git branch: $BranchName" >> "$LogFile"
echo "Date: $DateTime" >> "$LogFile"
echo "------------------------------------------------------------------------------------" >> "$LogFile"

