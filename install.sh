#!/bin/bash

#Initialise variables

#Checks if there's no arguments 
if [[ $1 == "" ]]; then
	./install.sh -h
	exit 0
fi

# Get arguments
while getopts "n:t:c:p:h" opt; do
  case $opt in
    n) name="$OPTARG" ;;
    t) token="$OPTARG" ;;
    c) channelID="$OPTARG";;
    p) path="$OPTARG";;
    h) echo "Install your discord bot to retrieve EpicFreeGames

install.sh -n name_of_the_bot -t token -c channelID

-n : the name of the bot
-t : the token
-c : the channel ID
-p : path where u want to install it (only absolute Path !!!)
-h : Displays this"
exit 0;;
  esac
done

if [[ $path == "" ]];then
	path="./"
fi

# Get the file from github
mkdir -p $path/showEpicBot

curl -sLO --output-dir $path/showEpicBot https://raw.githubusercontent.com/S3F1RO/ShowEpicFreeGames/main/requirements.txt

curl -sLO --output-dir $path/showEpicBot https://raw.githubusercontent.com/S3F1RO/ShowEpicFreeGames/main/retrieveEpicGames.py

cd $path/showEpicBot/

#Installation of libraries
cat requirements.txt | awk -F '>' '{print $1}' > libraries

while read -r line; do
	sudo apt install -y python3-$line
done < libraries

#Creation of the .env file
echo "DISCORD_TOKEN=$token" > $path/showEpicBot/.env
echo "CHANNEL_ID=$channelID" >> $path/showEpicBot/.env

#Creation of the service file
echo "
[Unit]
Description=Retrieve Epic Games Discord Bot Service
After=network.target # Launchs after

[Service]
Type=simple
User=$USER
WorkingDirectory=$path/showEpicBot
ExecStart=/usr/bin/python3 -u $path/showEpicBot/retrieveEpicGames.py
Restart=on-failure		#Restart if service Crashes
RestartSec=5			    #Take 5s to restart

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/$name.service

sudo systemctl daemon-reload
sudo systemctl enable $name.service
sudo systemctl start $name.service

clear

sudo systemctl status $name.service
