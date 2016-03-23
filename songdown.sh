#!/bin/bash

#Options usage:
# -v or --video 							: Downloads video in highest quality (720p max). 			: Default = False
# -p OR --path <path> 						: Defines path of downloaded mp3 file.						: Default = ~/songdown/
# -r OR --results <integer(less than 15)> 	: Defines number of results to be shown from youtube search.: Default = 4
# -d OR --default <path>					: Sets default path.

#Script exits on error
set -e

#Setting default options
if [ ! -f ~/songdown/defaults.conf ]; then
	cat <<- EOL > ~/songdown/defaults.conf
		VIDEO=false
		DOWN_DIR="~/songdown/"
		RESULTS=3
	EOL
fi
source ~/songdown/defaults.conf

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
	DEFAULT_DIR=$2
	sed -i "s#DOWN_DIR=.*#DOWN_DIR=\"$DEFAULT_DIR\"#" ~/songdown/defaults.conf
    shift
    ;;
    *)
    echo -e "\nInvalid options. Proceeding with default settings"        # unknown option
    ;;
esac
shift # past argument or value
done
DOWN_DIR=$DOWN_DIR"/%(title)s.%(ext)s"

echo -e "\nSongDown started.\n\nEnter name of song - "
read

#Checking for prerequisite packages
echo -e "\nLooking for youtube-dl..."
if youtube-dl --version
	then
	echo "youtube-dl found!"
else
	echo "youtube-dl missing!"
	echo "To install youtube-dl you can follow the instructions at"
	echo "http://www.tecmint.com/install-youtube-dl-command-line-video-download-tool/"
	exit 1
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
	youtube-dl -o $DOWN_DIR -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio' --merge-output-format mp4 "${links[$index]}"
else
	youtube-dl -o $DOWN_DIR --extract-audio --audio-format mp3 --audio-quality 0 "${links[$index]}"
fi
echo -e "\nSongDown finished. Exiting...\n"
rm sample
exit 0