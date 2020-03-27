#!/bin/bash

# Set the date and time of now
NOW=`date +%Y-%m-%d.%H:%M:%S`

# The absolute path to the folder whjch contains all the scripts.
# Unless you are working with symlinks, leave the following line untouched.
PATHDATA="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#############################################################
# $DEBUG TRUE|FALSE
# Read debug logging configuration file
. $PATHDATA/../settings/debugLogging.conf

###########################################################
# Read global configuration file (and create is not exists) 
# create the global configuration file from single files - if it does not exist
if [ ! -f $PATHDATA/../settings/global.conf ]; then
    . inc.writeGlobalConfig.sh
fi
. $PATHDATA/../settings/global.conf
###########################################################

# Get args from command line (see Usage above)
# see following file for details:
. $PATHDATA/inc.readArgsFromCommandLine.sh

# get the name of the last folder played. As mpd doesn't store the name of the last
# playlist, we have to keep track of it via the Latest_Folder_Played file
LASTFOLDER=$(cat $PATHDATA/../settings/Latest_Folder_Played)
LASTPLAYLIST=$(cat $PATHDATA/../settings/Latest_Playlist_Played)

###########################################################
# handleSpecialCards (string cardId) : void
###########################################################
# return code: 0 - handled
#              1 - NOT handled
#
# Handles special cards for example volume changes, skipping, muting sound.
# If the input is of 'special' use, don't treat it like a trigger to play audio.
# Special uses are for example volume changes, skipping, muting sound.
handleSpecialCards () {

    local CARDID = $1

    case $CARDID in 
        $CMDSHUFFLE)
            # toggles shuffle mode  (random on/off)
            $PATHDATA/playout_controls.sh -c=playershuffle
            ;;
        $CMDMAXVOL30)
            # limit volume to 30%
            $PATHDATA/playout_controls.sh -c=setmaxvolume -v=30
            ;;
        $CMDMAXVOL50)
            # limit volume to 50%
            $PATHDATA/playout_controls.sh -c=setmaxvolume -v=50
            ;;
        $CMDMAXVOL75)
            # limit volume to 75%
            $PATHDATA/playout_controls.sh -c=setmaxvolume -v=75
            ;;
        $CMDMAXVOL80)
            # limit volume to 80%
            $PATHDATA/playout_controls.sh -c=setmaxvolume -v=80
            ;;
        $CMDMAXVOL85)
            # limit volume to 85%
            $PATHDATA/playout_controls.sh -c=setmaxvolume -v=85
            ;;
        $CMDMAXVOL90)
            # limit volume to 90%
            $PATHDATA/playout_controls.sh -c=setmaxvolume -v=90
            ;;
        $CMDMAXVOL95)
            # limit volume to 95%
            $PATHDATA/playout_controls.sh -c=setmaxvolume -v=95
            ;;
        $CMDMAXVOL100)
            # limit volume to 100%
            $PATHDATA/playout_controls.sh -c=setmaxvolume -v=100
            ;;
        $CMDMUTE)
            # amixer sset 'PCM' 0%
            $PATHDATA/playout_controls.sh -c=mute
            ;;
        $CMDVOL30)
            # amixer sset 'PCM' 30%
            $PATHDATA/playout_controls.sh -c=setvolume -v=30
            ;;
        $CMDVOL50)
            # amixer sset 'PCM' 50%
            $PATHDATA/playout_controls.sh -c=setvolume -v=50
            ;;
        $CMDVOL75)
            # amixer sset 'PCM' 75%
            $PATHDATA/playout_controls.sh -c=setvolume -v=75
            ;;
        $CMDVOL80)
            # amixer sset 'PCM' 80%
            $PATHDATA/playout_controls.sh -c=setvolume -v=80
            ;;
        $CMDVOL85)
            # amixer sset 'PCM' 85%
            $PATHDATA/playout_controls.sh -c=setvolume -v=85
            ;;
        $CMDVOL90)
            # amixer sset 'PCM' 90%
            $PATHDATA/playout_controls.sh -c=setvolume -v=90
            ;;
        $CMDVOL95)
            # amixer sset 'PCM' 95%
            $PATHDATA/playout_controls.sh -c=setvolume -v=95
            ;;
        $CMDVOL100)
            # amixer sset 'PCM' 100%
            $PATHDATA/playout_controls.sh -c=setvolume -v=100
            ;;
        $CMDVOLUP)
            # increase volume by x% set in Audio_Volume_Change_Step
            $PATHDATA/playout_controls.sh -c=volumeup   
            ;;
        $CMDVOLDOWN)
            # decrease volume by x% set in Audio_Volume_Change_Step
            $PATHDATA/playout_controls.sh -c=volumedown
            ;;
        $CMDSTOP)
            # kill all running audio players
            $PATHDATA/playout_controls.sh -c=playerstop
            ;;
        $CMDSHUTDOWN)
            # shutdown the RPi nicely
            # sudo halt
            $PATHDATA/playout_controls.sh -c=shutdown
            ;;
        $CMDREBOOT)
            # shutdown the RPi nicely
            # sudo reboot
            $PATHDATA/playout_controls.sh -c=reboot
            ;;
        $CMDNEXT)
            # play next track in playlist
            $PATHDATA/playout_controls.sh -c=playernext
            ;;
        $CMDPREV)
            # play previous track in playlist
            # echo "prev" | nc.openbsd -w 1 localhost 4212
            sudo $PATHDATA/playout_controls.sh -c=playerprev
            #/usr/bin/sudo /home/pi/RPi-Jukebox-RFID/scripts/playout_controls.sh -c=playerprev
            ;;

        # !!! CONNECTED FOLDERS

        $CMDREWIND)
            # play the first track in playlist
            sudo $PATHDATA/playout_controls.sh -c=playerrewind
            ;;
        $CMDSEEKFORW)
            # jump 15 seconds ahead
            $PATHDATA/playout_controls.sh -c=playerseek -v=+15
            ;;
        $CMDSEEKBACK)
            # jump 15 seconds back
            $PATHDATA/playout_controls.sh -c=playerseek -v=-15
            ;;
        $CMDPAUSE)
            # pause current track
            # echo "pause" | nc.openbsd -w 1 localhost 4212
            $PATHDATA/playout_controls.sh -c=playerpause
            ;;
        $CMDPLAY)
            # play / resume current track
            # echo "play" | nc.openbsd -w 1 localhost 4212
            $PATHDATA/playout_controls.sh -c=playerplay
            ;;
        $STOPAFTER5)
            # stop player after -v minutes
            $PATHDATA/playout_controls.sh -c=playerstopafter -v=5
            ;;
        $STOPAFTER15)
            # stop player after -v minutes
            $PATHDATA/playout_controls.sh -c=playerstopafter -v=15
            ;;
        $STOPAFTER30)
            # stop player after -v minutes
            $PATHDATA/playout_controls.sh -c=playerstopafter -v=30
            ;;
        $STOPAFTER60)
            # stop player after -v minutes
            $PATHDATA/playout_controls.sh -c=playerstopafter -v=60
            ;;
        $SHUTDOWNAFTER5)
            # shutdown after -v minutes
            $PATHDATA/playout_controls.sh -c=shutdownafter -v=5
            ;;
        $SHUTDOWNAFTER15)
            # shutdown after -v minutes
            $PATHDATA/playout_controls.sh -c=shutdownafter -v=15
            ;;
        $SHUTDOWNAFTER30)
            # shutdown after -v minutes
            $PATHDATA/playout_controls.sh -c=shutdownafter -v=30
            ;;
        $SHUTDOWNAFTER60)
            # shutdown after -v minutes
            $PATHDATA/playout_controls.sh -c=shutdownafter -v=60
            ;;
        $ENABLEWIFI)
            $PATHDATA/playout_controls.sh -c=enablewifi
            ;;
        $DISABLEWIFI)
            $PATHDATA/playout_controls.sh -c=disablewifi
            ;;
        $CMDPLAYCUSTOMPLS)
            $PATHDATA/playout_controls.sh -c=playlistaddplay -v="PhonieCustomPLS" -d="PhonieCustomPLS"
            ;;
        $STARTRECORD600)
            #start recorder for -v seconds
            $PATHDATA/playout_controls.sh -c=recordstart -v=600			             
            ;;
        $STOPRECORD)
            $PATHDATA/playout_controls.sh -c=recordstop
            ;;
        $RECORDSTART600)
            #start recorder for -v seconds
            $PATHDATA/playout_controls.sh -c=recordstart -v=600			             
            ;;
        $RECORDSTART60)
            #start recorder for -v seconds
            $PATHDATA/playout_controls.sh -c=recordstart -v=60			             
            ;;
        $RECORDSTART10)
            #start recorder for -v seconds
            $PATHDATA/playout_controls.sh -c=recordstart -v=10			             
            ;;
        $RECORDSTOP)
            $PATHDATA/playout_controls.sh -c=recordstop
            ;;
        $RECORDPLAYBACKLATEST)
            $PATHDATA/playout_controls.sh -c=recordplaybacklatest
            ;;
        *)
            # We checked if the card was a special command, seems it wasn't.
            # Now we expect it to be a trigger for one or more audio file(s).
            return 1
    esac
    return 0
}

###########################################################
# handleConnectedFolder (string cardId) : : void
###########################################################
# return code: 0 - handled
#              1 - NOT handled
#
# handles special cards in case of a connected folder: next.conf | previous.conf
# outputs the next/prev
#
handleConnectedFolder () {

    local CARDID = $1

    case $CARDID in 
        $CMDNEXTCONNECTED)
            # toggles shuffle mode  (random on/off)
            $PATHDATA/playout_controls.sh -c=playershuffle
            ;;
        $CMDPREVCONNECTED)
            # limit volume to 30%
            $PATHDATA/playout_controls.sh -c=setmaxvolume -v=30
            ;;
        *)
            # We checked if the card was a special command, seems it wasn't.
            # Now we expect it to be a trigger for one or more audio file(s).
            return 1
    esac
    return 0
}

###########################################################
# resolveFolder (string pathData, string cardId) : folder
###########################################################
# return code: 0 - shortcut found
#              1 - shortcut NOT found
#
# Resolves a folder that is assigned to a cardId. If there's no folder assigned, the cardId is returned as is
#
resolveFolder () {

    local PATHDATA = $1
    local CARDID = $2
    local RETURN_CODE = 0

    # Look for human readable shortcut in folder 'shortcuts'
    # check if CARDID has a text file by the same name - which would contain the human readable folder name
    if [ -f $PATHDATA/../shared/shortcuts/$CARDID ]
    then
        # Read human readable shortcut from file
        FOLDER=`cat $PATHDATA/../shared/shortcuts/$CARDID`
        # Add info into the log, making it easer to monitor cards
        echo "This ID has been used before." >> $PATHDATA/../shared/latestID.txt
        if [ "${DEBUG_rfid_trigger_play_sh}" == "TRUE" ]; then echo "This ID has been used before."   >> $PATHDATA/../logs/debug.log; fi
        RETURN_CODE = 0
    else
        # Human readable shortcut does not exists, so create one with the content $CARDID
        # this file can later be edited manually over the samba network
        echo "$CARDID" > $PATHDATA/../shared/shortcuts/$CARDID
        FOLDER=$CARDID
        # Add info into the log, making it easer to monitor cards
        echo "This ID was used for the first time." >> $PATHDATA/../shared/latestID.txt
        if [ "${DEBUG_rfid_trigger_play_sh}" == "TRUE" ]; then echo "This ID was used for the first time."   >> $PATHDATA/../logs/debug.log; fi
        RETURN_CODE = 1
    fi

    echo $FOLDER
    return $RETURN_CODE
}

