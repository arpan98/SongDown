#!/bin/bash

#Options usage:
# -v or --video : Downloads video in highest quality (720p max). (If not provided, downloads audio only)
# -r OR --results <integer(less than 15)> : Defines number of results to be shown from youtube search.
# -d OR --directory <path> : Defines path of downloaded mp3 file.

#Script exits on error
set -e

#Setting default options
VIDEO=false
DOWN_DIR="~/songdown"
RESULTS=3

#Taking options input if provided
while [[ $# > 0 ]]
do
key="$1"
case $key in
    -p|--path)
    DOWN_DIR="$2"
    shift # past argument
    ;;
    -r|--results)
    RESULTS="$2"
    if [[ $RESULTS =~ ^-?[0-9]+$ ]]; then
    	ONE="1"
		RESULTS=$((RESULTS-10#$ONE))
	else
		echo -e "\nNumber of results must be an integer!\nExiting...\n"
		exit 1
	fi
	shift
    ;;
    -v|--video)
	VIDEO=true
	shift
    ;;
    -d|--default)
	DEFAULT_DIR="$2"
	DEFAULT_DIR="$DEFAULT_DIR/%(title)s.%(ext)s"
	echo "$DEFAULT_DIR" > default_dir
    shift
    ;;
    *)
    echo -e "\nInvalid options. Proceeding with default settings"        # unknown option
    ;;
esac
shift # past argument or value
done
if [ ! -f default_dir ]; then
	DOWN_DIR="$DOWN_DIR/%(title)s.%(ext)s"
else
	DOWN_DIR=$(<default_dir)
fi

echo -e "\nSongDown started.\n\nEnter name of song - "
read

#Checking for prerequisite packages
echo -e "\nLooking for youtube-dl..."
if dpkg-query -W --showformat='${Status}\n' youtube-dl | grep -q "install ok installed"
	then
	echo "youtube-dl found!"
else
	echo -e "youtube-dl missing! \n\n Installing youtube-dl..."
	sleep 1
	sudo add-apt-repository ppa:nilarimogard/webupd8
	sudo apt-get update
	sudo apt-get install youtube-dl
fi

search_string=${REPLY// /+}
search_url="https://www.youtube.com/results?search_query="
search_url=$search_url$search_string
echo
echo "Retrieving results from Youtube..."
wget -qO- $search_url > sample
IFS=$'\n' links=($(cat sample | grep '<a href="/watch?v=' | sed 's/.*<a href="\(\/watch?v=.\{11\}\)".*/https:\/\/www\.youtube\.com\1/'))
IFS=$'\n' names=($(cat sample | grep '<a href="/watch?v=' | sed 's/.*<a href=.*dir="ltr">\(.*\)<\/a><span.*/\1/'))
len=${#names[*]}

for i in $(seq 0 $RESULTS); do
	echo
	echo "$i. ${names[$i]}"
done
echo -e "\nEnter selection number - "
read index
echo
echo "Downloading ${names[$index]}"

if [ "$VIDEO" = true ]; then
	youtube-dl -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio' --merge-output-format mp4 "${links[$index]}"
else
	youtube-dl -o $DOWN_DIR --extract-audio --audio-format mp3 --audio-quality 0 "${links[$index]}"
fi
echo -e "\nSongDown finished. Exiting...\n"
rm sample