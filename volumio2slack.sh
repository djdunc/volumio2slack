#!/bin/bash
GLOBIGNORE=*

# If you don't know your Slack User OAuth Token then follow the instructions in the 
# slack-api-token folder / README.md file or follow one of the many examples online 
# (Google "slack token generator")
APIKEY="ADD IN YOUR SLACK USER OAUTH TOKEN HERE" 
trap onexit INT

# If in the loop no song is playing then it resets the status to "empty"
function reset() {
    echo 'Resetting status'
    /usr/bin/curl -s -d "payload=$json" "https://slack.com/api/users.profile.set?token="$APIKEY"&profile=%7B%22status_text%22%3A%22%22%2C%22status_emoji%22%3A%22%22%7D" > /dev/null
}

# If script exits also tidies up and calls reset function.
function onexit() {
    echo 'Exiting'
    reset
    exit
}

# Run endlessly
while true; do

    # get the current state of volumio from the device API - returns a JSON object
    volumio=$(/usr/bin/curl -s 'volumio.local/api/v1/getState')  
 
    # JSON object has lots of info but below are the items I wanted to use
    state=$(echo $volumio | jq -r '.status')
    title=$(echo $volumio | jq -r '.title' | cut -c1-25) # max 25 chars, some names really long 
    artist=$(echo $volumio | jq -r '.artist' | cut -c1-25) 
    volume=$(echo $volumio | jq -r '.volume')
    service=$(echo $volumio | jq -r '.service')

    # wanted to make the tag for radio vs spotify more human readable 
    case $service in
        webradio)
          service="the radio"
          ;;
        spop)
          service="Spotify"
          ;;
    esac

    #echo $volumio
    #echo "$state"
    #echo "Playing $title by $artist on $service at $volume% volume"

   # if nothing is playing then reset otherwise compile the message and send to slack api
   if [[ "$state" != "play" ]]; then
        reset
    else
        # compile the message into format for display in slack status
        SONG=$(echo "Playing ${title} by ${artist} on ${service} at ${volume}% volume")
        # format that message so it doesnt mess up URL
        URLSONG=$(echo "$SONG" | /usr/bin/perl -MURI::Escape -ne 'chomp;print uri_escape($_),"\n"')
        #echo $SONG
        #echo $URLSONG

        /usr/bin/curl -s -d "payload=$json" "https://slack.com/api/users.profile.set?token="$APIKEY"&profile=%7B%22status_text%22%3A%22"$URLSONG"%22%2C%22status_emoji%22%3A%22%3Anotes%3A%22%7D"  > /dev/null
    fi
     
    # wait 20 seconds before checking again to see what is (or isn't) playing
    sleep 20
done


