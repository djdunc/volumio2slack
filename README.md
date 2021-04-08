# How to set up volumio status to slack status on a mac

Goal: create a script that runs in the background on my work mac that displays the current Spotify Desktop or Volumio track I am listening to as my Slack status. 

## Overview

This script was created during lockdown to share my music listening habits with colleagues. We had been exploring how we could use Slack as a channel for sending notifications when services to Connected Environments infrastructure were down so this seemed like an interesting proof of concept. The notes below describe how to connect Slack, Spotify and Volumio.

Volumio is set-up on a RPi connected to my old (circa 1989) Kenwood stereo and typically plays either Spotify playlists or WebRadio (BBC R6 or R4). I noticed it had a really handy [API](https://volumio.github.io/docs/API/REST_API.html) with a bunch of useful info around track names, current volume etc. Two example responses are in the volumio.json file in the repo - one for WebRadio and one for Spotify.

Spotify also has an [API](https://developer.spotify.com/documentation/web-api/) - note it requires a developer account sign-up. Go to your Dashboard and create an App to get a Client ID and Secret.

The Slack [API](https://api.slack.com) required a little more work. The old developer token method has now been deprecated and replaced with an OAuth approach - hence the initial step described below of creating an application in Slack and then requesting the access token.

The final step was setting up the shell scripts to run using launctl on Mac at start-up.

2 versions of the scripts; Spotify and Volumio. I originally planned to have a combination of both running so that whichever application I as using it would update Slack. In reality I only really use Volumio at from this machine so the example below just talks through the install for Volumio but the process would be the same for Spotify.

## Getting a Slack token
First up we need to get the Slack API token so that we can change our status. The script in the subfolder ```slack-api-token``` contains a shell script that loads up the server.js node application and presents a dialogue to request your API token from Slack. You will need to go to [your apps](https://api.slack.com/apps) section of the Slack API and click on your app to see your app credentials. Add these into the  ```slack-get-token.sh``` file and then from Terminal or similar run this shell script.

Once you have followed through the OAuth process you will end up with a "User OAuth Token" - copy this and insert it into the ```volumio2slack.sh``` script. (Note: Once this has been set-up you can also retrieve this token from the Slack API site under the sub menu of "Settings" called "Install App".)

To check the script runs open Volumio (we are assuming it is at volumio.local on the same network) and open the slack workspace you have associated the App with. From Terminal or similar run ```volumio2slack.sh``` to check it is connecting properly - you should now see some music symbols in your slack profile and if you mouse over you will see track info.

## Setting up the script to run at start-up
Now that your ```volumio2slack.sh``` file is configured and working the last step is to have it running in the background on your mac. Using launchctl set this up as a daemon to run at starting using the following 3 steps:

1. Use the template .plist file in the repo ```volumio2slack.plist``` to set-up for your system (ie edit line 8 to point to the location where you will deploy your script).
2. Place the .plist file in ```~/Library/LaunchAgents```
3. Re log in (or run manually via ```launchctl load volumio2slack.plist```)

## File Summary

```volumio2slack.plist``` and ```volumio2slack.sh``` are the two files you need to run the track updater from your Mac.

```spotify2slack.plist``` and ```spotify2slack.sh``` are the Spotify equivalents.

```volumio.json``` contains examples of content returned from a call to the Volumio API.

```slack-api-token``` is a folder of files from @sjg to return the Slack User OAuth Token