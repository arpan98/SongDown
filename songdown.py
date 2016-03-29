#!/usr/bin/env python

import os, sys, requests, json, subprocess, argparse

DEVELOPER_KEY = 'AIzaSyB3x0d4TgYSnKg128hcBQWoolhX0A9v9NU'
YOUTUBE_API_SERVICE_NAME = "youtube"
YOUTUBE_API_VERSION = "v3"

names=[]
ids=[]
views=[]

def youtube_search(search_string, RESULTS):

	payload = {'q':search_string, 'part':'id,snippet', 'maxResults':str(RESULTS), 'key':DEVELOPER_KEY}
	search_request = requests.get('https://www.googleapis.com/youtube/v3/search', params=payload)

	search_response = json.loads(search_request.text)
	for item in search_response["items"]:
		ids.append(item["id"]["videoId"])
		names.append(item["snippet"]["title"])

	# Add each result to the appropriate list
	search_videos = []
	search_videos = ",".join(ids)

	payload = {'id':search_videos, 'part':'statistics', 'key':DEVELOPER_KEY}
	video_request = requests.get('https://www.googleapis.com/youtube/v3/videos', params=payload)

	video_response = json.loads(video_request.text)
	for item in video_response["items"]:
		views.append(item["statistics"]["viewCount"])

	for i in xrange(len(names)):
		print i, ". ", names[i]
		print "Views: ", views[i], "\n"


if __name__ == "__main__":
	#Managing config file
	filename = os.path.expanduser('~/.songdownrc')
	if not os.path.isfile(filename):
		with open(filename, 'w') as file:
			file.write('VIDEO=false\nDOWN_DIR="~/Music/SongDown/"\nRESULTS=3')
	with open(filename, 'r') as file:
		for line in file:
			keys = line.split('=')
			if keys[0] == 'VIDEO':
				try:
					VIDEO = bool(keys[1])
				except:
					print "Config file error"
			elif keys[0] == 'DOWN_DIR':
				try:
					DOWN_DIR = keys[1].split('"')[1]
				except:
					print "Config file error"
			elif keys[0] == 'RESULTS':
				try:
					RESULTS = int(keys[1])
				except:
					print "Config file error"

	parser = argparse.ArgumentParser()
	parser.add_argument("-v", "--video", help="Download video")
	parser.add_argument("-p", "--path", help="Specify download path")
	parser.add_argument("-r", "--results", help="Specify number of search results to be shown")
	parser.add_argument("-d", "--default", help="Set default path")


	name = raw_input("\nSongdown started.\n\nEnter name of song - ")
	search_string = name.replace(' ','+')

	print "\nLooking for youtube-dl..."
	if not os.system("youtube-dl --version"):
		print "\nyoutube-dl found!"
	else:
		print "\nyoutube-dl missing!"
		print "To install youtube-dl you can follow the instructions at\nhttp://www.tecmint.com/install-youtube-dl-command-line-video-download-tool/"
		print "\nExiting...\n"
		sys.exit()

        DOWN_DIR = os.path.expanduser(DOWN_DIR)
        # Create download dir if necessary
        if not os.path.exists(DOWN_DIR):
            os.makedirs(DOWN_DIR)

	print "\nRetrieving results from youtube...\n"
	youtube_search(search_string, RESULTS)

	selected = False
	while not selected:
		index = raw_input("Enter selection number - ")
		try:
			index = int(index)
			print "\nDownloading", names[index]
			selected = True
		except:
			print "\nInvalid selection!\n"
	title = '/%' + '(title)s.%' +'(ext)s'
	path = DOWN_DIR + title
	if VIDEO:
		subprocess.call(['youtube-dl', '-o', path, '-f', 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio', '--merge-output-format', 'mp4', 'https://www.youtube.com/watch?v='+ids[index]])
	else:
		subprocess.call(['youtube-dl', '-o', path, '--extract-audio', '--audio-format', 'mp3', '--audio-quality', '0', 'https://www.youtube.com/watch?v='+ids[index]])
	print "\nSongDown finished. Exiting...\n"
