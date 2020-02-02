#!/bin/bash

# Reads the card ID or the folder name with audio files
# from the command line (see Usage).
# Then attempts to get the folder name from the card ID
# or play audio folder content directly
#
# Usage for card ID
# ./rfid_trigger_play.sh -i=1234567890
# or
# ./rfid_trigger_play.sh --cardid=1234567890
#
# For folder names:
# ./rfid_trigger_play.sh -d='foldername'
# or
# ./rfid_trigger_play.sh --dir='foldername'
#
# or for recursive play of sudfolders
# ./rfid_trigger_play.sh -d='foldername' -v=recursive

# ADD / EDIT RFID CARDS TO CONTROL THE PHONIEBOX
# All controls are assigned to RFID cards in this 
# file:
# settings/rfid_trigger_play.conf
# Please consult this file for more information.
# Do NOT edit anything in this file.

# The absolute path to the folder whjch contains all the scripts.
# Unless you are working with symlinks, leave the following line untouched.
PATHDATA="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# include functions
. $PATHDATA/inc.functions.sh


if [ "${DEBUG_rfid_trigger_play_sh}" == "TRUE" ]; then echo "########### SCRIPT rfid_trigger_play.sh ($NOW) ##" >> $PATHDATA/../logs/debug.log; fi

# create the configuration file from sample - if it does not exist
if [ ! -f $PATHDATA/../settings/rfid_trigger_play.conf ]; then
    cp $PATHDATA/../settings/rfid_trigger_play.conf.sample $PATHDATA/../settings/rfid_trigger_play.conf
    # change the read/write so that later this might also be editable through the web app
    sudo chown -R pi:www-data $PATHDATA/../settings/rfid_trigger_play.conf
    sudo chmod -R 775 $PATHDATA/../settings/rfid_trigger_play.conf
fi

# Read configuration file
. $PATHDATA/../settings/rfid_trigger_play.conf

##################################################################
# Check if we got the card ID or the audio folder from the prompt.
# Sloppy error check, because we assume the best.
if [ "$CARDID" ]; then
    # we got the card ID
    # If you want to see the CARDID printed, uncomment the following line
    # echo CARDID = $CARDID

    # Add info into the log, making it easer to monitor cards 
    echo "Card ID '$CARDID' was used at '$NOW'." > $PATHDATA/../shared/latestID.txt
    echo "$CARDID" > $PATHDATA/../settings/Latest_RFID
    if [ "${DEBUG_rfid_trigger_play_sh}" == "TRUE" ]; then echo "Card ID '$CARDID' was used" >> $PATHDATA/../logs/debug.log; fi

    # If the input is of 'special' use, don't treat it like a trigger to play audio.
    # Special uses are for example volume changes, skipping, muting sound.
    handleSpecialCards "$CARDID"
    if [ "$?" -ne 0 ]; then
        # We checked if the card was a special command, seems it wasn't.
        # Now we expect it to be a trigger for one or more audio file(s).
        # Let's look at the ID, write a bit of log information and then try to play audio.
    
        FOLDER_TO_BE_PLAYED=$(resolveFolder "$PATHDATA" "$CARDID")
        # Add info into the log, making it easer to monitor cards
        echo "The shortcut points to audiofolder '$FOLDER'." >> $PATHDATA/../shared/latestID.txt
        if [ "${DEBUG_rfid_trigger_play_sh}" == "TRUE" ]; then echo "The shortcut points to audiofolder '$FOLDER'." >> $PATHDATA/../logs/debug.log; fi
    fi
fi

##############################################################
# We should now have a folder name with the audio files.
# Either from prompt of from the card ID processing above
# Sloppy error check, because we assume the best.

#TODO!!! NEXT_CONNECTED_FOLDER=$(${PATHDATA}/get_connected_folder.php --folder="${FOLDER}" --direction=next)
#TODO!!! PREV_CONNECTED_FOLDER=$(${PATHDATA}/get_connected_folder.php --folder="${FOLDER}" --direction=next)

if [ "${DEBUG_rfid_trigger_play_sh}" == "TRUE" ]; then echo "# Attempting to handle: $AUDIOFOLDERSPATH/$FOLDER" >> $PATHDATA/../logs/debug.log; fi
if [ "${DEBUG_rfid_trigger_play_sh}" == "TRUE" ]; then echo "# Type of play \$VALUE: $VALUE" >> $PATHDATA/../logs/debug.log; fi

# check if 
# - $FOLDER is not empty (! -z "$FOLDER") 
# - AND (-a) 
# - $FOLDER is set (! -z ${FOLDER+x})
# - AND (-a) 
# - and points to existing directory (-d "${AUDIOFOLDERSPATH}/${FOLDER}")
if [ ! -z "$FOLDER" -a ! -z ${FOLDER+x} -a -d "${AUDIOFOLDERSPATH}/${FOLDER}" ]; then

    if [ "${DEBUG_rfid_trigger_play_sh}" == "TRUE" ]; then echo "\$FOLDER set, not empty and dir exists: ${AUDIOFOLDERSPATH}/${FOLDER}" >> $PATHDATA/../logs/debug.log; fi

    # if we play a folder the first time, add some sensible information to the folder.conf
    if [ ! -f "${AUDIOFOLDERSPATH}/${FOLDER}/folder.conf" ]; then
        # now we create a default folder.conf file by calling this script
        # with the command param createDefaultFolderConf
        # (see script for details)
        # the $FOLDER would not need to be passed on, because it is already set in this script
        # see inc.writeFolderConfig.sh for details
        . $PATHDATA/inc.writeFolderConfig.sh -c=createDefaultFolderConf -d="${FOLDER}"
    fi

    # this might need to go? resume not working... echo ${FOLDER} > $PATHDATA/../settings/Latest_Folder_Played
    if [ "${DEBUG_rfid_trigger_play_sh}" == "TRUE" ]; then echo "  Var \$LASTFOLDER: $LASTFOLDER" >> $PATHDATA/../logs/debug.log; fi
    if [ "${DEBUG_rfid_trigger_play_sh}" == "TRUE" ]; then echo "  Var \$LASTPLAYLIST: $LASTPLAYLIST" >> $PATHDATA/../logs/debug.log; fi    
    if [ "${DEBUG_rfid_trigger_play_sh}" == "TRUE" ]; then echo "Checking 'recursive' list? VAR \$VALUE: $VALUE" >> $PATHDATA/../logs/debug.log; fi

    if [ "$VALUE" == "recursive" ]; then
        # set path to playlist
        # replace subfolder slashes with " % "
        PLAYLISTPATH="${PLAYLISTSFOLDERPATH}/${FOLDER//\//\ %\ }-%RCRSV%.m3u"
        PLAYLISTNAME="${FOLDER//\//\ %\ }-%RCRSV%"
        $PATHDATA/playlist_recursive_by_folder.php --folder "${FOLDER}" --list 'recursive' > "${PLAYLISTPATH}"
        if [ "${DEBUG_rfid_trigger_play_sh}" == "TRUE" ]; then echo "recursive? YES"   >> $PATHDATA/../logs/debug.log; fi
        if [ "${DEBUG_rfid_trigger_play_sh}" == "TRUE" ]; then echo "$PATHDATA/playlist_recursive_by_folder.php --folder \"${FOLDER}\" --list 'recursive' > \"${PLAYLISTPATH}\""   >> $PATHDATA/../logs/debug.log; fi
    else
        # set path to playlist
        # replace subfolder slashes with " % "
        PLAYLISTPATH="${PLAYLISTSFOLDERPATH}/${FOLDER//\//\ %\ }.m3u"
        PLAYLISTNAME="${FOLDER//\//\ %\ }"
        $PATHDATA/playlist_recursive_by_folder.php --folder "${FOLDER}" > "${PLAYLISTPATH}"
        if [ "${DEBUG_rfid_trigger_play_sh}" == "TRUE" ]; then echo "recursive? NO"   >> $PATHDATA/../logs/debug.log; fi
        if [ "${DEBUG_rfid_trigger_play_sh}" == "TRUE" ]; then echo "$PATHDATA/playlist_recursive_by_folder.php --folder \"${FOLDER}\" > \"${PLAYLISTPATH}\""   >> $PATHDATA/../logs/debug.log; fi
    fi

    # Second Swipe value
    if [ "${DEBUG_rfid_trigger_play_sh}" == "TRUE" ]; then echo "  Var \$SECONDSWIPE: ${SECONDSWIPE}"   >> $PATHDATA/../logs/debug.log; fi
    # Playlist name
    if [ "${DEBUG_rfid_trigger_play_sh}" == "TRUE" ]; then echo "  Var \$PLAYLISTNAME: ${PLAYLISTNAME}"   >> $PATHDATA/../logs/debug.log; fi
    if [ "${DEBUG_rfid_trigger_play_sh}" == "TRUE" ]; then echo "  Var \$LASTPLAYLIST: ${LASTPLAYLIST}"   >> $PATHDATA/../logs/debug.log; fi
    
    # Setting a VAR to start "play playlist from start"
    # This will be changed in the following checks "if this is the second swipe"
    PLAYPLAYLIST=yes
    
    # Check if the second swipe happened
    # - The same playlist is cued up ("$LASTPLAYLIST" == "$PLAYLISTNAME")
    if [ "$LASTPLAYLIST" == "$PLAYLISTNAME" ]
    then
        if [ "${DEBUG_rfid_trigger_play_sh}" == "TRUE" ]; then echo "  Second Swipe DID happen: \$LASTPLAYLIST == \$PLAYLISTNAME"   >> $PATHDATA/../logs/debug.log; fi
        
        # check if 
        # - $SECONDSWIPE is set to toggle pause/play ("$SECONDSWIPE" == "PAUSE") 
        # - AND (-a)
        # - check the length of the playlist, if =0 then it was cleared before, a state, which should only
        #   be possible after a reboot ($PLLENGTH -gt 0)
        PLLENGTH=$(echo -e "status\nclose" | nc -w 1 localhost 6600 | grep -o -P '(?<=playlistlength: ).*')
        if [ $PLLENGTH -eq 0 ]
        then
            # after a reboot we want to play the playlist once no matter what the setting is
            if [ "${DEBUG_rfid_trigger_play_sh}" == "TRUE" ]; then echo "  Take second wipe as first after fresh boot" >> $PATHDATA/../logs/debug.log; fi
        elif [ "$SECONDSWIPE" == "PAUSE" -a $PLLENGTH -gt 0 ]
        then
            # The following involves NOT playing the playlist, so we set: 
            PLAYPLAYLIST=no
        
            STATE=$(echo -e "status\nclose" | nc -w 1 localhost 6600 | grep -o -P '(?<=state: ).*')
            if [ $STATE == "play" ]
            then
                if [ "${DEBUG_rfid_trigger_play_sh}" == "TRUE" ]; then echo "  MPD playing, pausing the player" >> $PATHDATA/../logs/debug.log; fi
                sudo $PATHDATA/playout_controls.sh -c=playerpause &>/dev/null
            else
                if [ "${DEBUG_rfid_trigger_play_sh}" == "TRUE" ]; then echo "MPD not playing, start playing" >> $PATHDATA/../logs/debug.log; fi
                sudo $PATHDATA/playout_controls.sh -c=playerplay &>/dev/null
            fi
            if [ "${DEBUG_rfid_trigger_play_sh}" == "TRUE" ]; then echo "  Completed: toggle pause/play" >> $PATHDATA/../logs/debug.log; fi
        elif [ "$SECONDSWIPE" == "NOAUDIOPLAY" ]
        then
            # The following involves NOT playing the playlist, so we set: 
            PLAYPLAYLIST=no

            # "$SECONDSWIPE" == "NOAUDIOPLAY"
            # "$LASTPLAYLIST" == "$PLAYLISTNAME" => same playlist triggered again 
            # => do nothing
            # echo "do nothing" > /dev/null 2>&1
            if [ "${DEBUG_rfid_trigger_play_sh}" == "TRUE" ]; then echo "  Completed: do nothing" >> $PATHDATA/../logs/debug.log; fi
        elif [ "$SECONDSWIPE" == "SKIPNEXT" ]
        then
            # We will not play the playlist but skip to the next track: 
            PLAYPLAYLIST=skipnext
            if [ "${DEBUG_rfid_trigger_play_sh}" == "TRUE" ]; then echo "  Completed: skip next track" >> $PATHDATA/../logs/debug.log; fi
        fi
    fi
    # now we check if we are still on for playing what we got passed on:
    if [ "$PLAYPLAYLIST" == "yes" ]
    then
        if [ "${DEBUG_rfid_trigger_play_sh}" == "TRUE" ]; then echo "We must play the playlist no matter what: \$PLAYPLAYLIST == yes"   >> $PATHDATA/../logs/debug.log; fi

        # Above we already checked if the folder exists -d "$AUDIOFOLDERSPATH/$FOLDER" 
        #
        # the process is as such - because of the recursive play option:
        # - each folder can be played. 
        # - a single folder will create a playlist with the same name as the folder
        # - because folders can live inside other folders, the relative path might contain
        #   slashes (e.g. audiobooks/Moby Dick/)
        # - because slashes can not be in the playlist name, slashes are replaced with " % "
        # - the "recursive" option means that the content of the folder AND all subfolders
        #   is being played
        # - in this case, the playlist is related to the same folder name, which means we need
        #   to make a different name for "recursive" playout
        # - a recursive playlist has the suffix " %RCRSV%" - keeping it cryptic to avoid clashes
        #   with a possible "real" name for a folder
        # - with this new logic, there are no more SPECIALFORMAT playlists. Live streams and podcasts
        #   are now all unfolded into the playlist
        # - creating the playlist is now done in the php script with parameters:
        #   $PATHDATA/playlist_recursive_by_folder.php --folder "${FOLDER}" --list 'recursive'

        if [ "${DEBUG_rfid_trigger_play_sh}" == "TRUE" ]; then echo "  VAR FOLDER: $FOLDER"   >> $PATHDATA/../logs/debug.log; fi
        if [ "${DEBUG_rfid_trigger_play_sh}" == "TRUE" ]; then echo "  VAR PLAYLISTPATH: $PLAYLISTPATH"   >> $PATHDATA/../logs/debug.log; fi
       
		# save position of current playing list "stop"
		$PATHDATA/playout_controls.sh -c=playerstop
		# play playlist
        # the variable passed on to play is the playlist name -v (NOT the folder name) 
        # because (see above) a folder can be played recursively (including subfolders) or flat (only containing files)        
        # load new playlist and play
        $PATHDATA/playout_controls.sh -c=playlistaddplay -v="${PLAYLISTNAME}" -d="${FOLDER}"
        if [ "${DEBUG_rfid_trigger_play_sh}" == "TRUE" ]; then echo "  Command: $PATHDATA/playout_controls.sh -c=playlistaddplay -v=\"${PLAYLISTNAME}\" -d=\"${FOLDER}\"" >> $PATHDATA/../logs/debug.log; fi
        # save latest playlist not to file
        sudo echo ${PLAYLISTNAME} > $PATHDATA/../settings/Latest_Playlist_Played
        sudo chmod 777 $PATHDATA/../settings/Latest_Playlist_Played
    fi
    if [ "$PLAYPLAYLIST" == "skipnext" ]
    then
        if [ "${DEBUG_rfid_trigger_play_sh}" == "TRUE" ]; then echo "Skip to the next track in the playlist: \$PLAYPLAYLIST == skipnext"   >> $PATHDATA/../logs/debug.log; fi
        if [ "${DEBUG_rfid_trigger_play_sh}" == "TRUE" ]; then echo "  VAR FOLDER: $FOLDER"   >> $PATHDATA/../logs/debug.log; fi
        if [ "${DEBUG_rfid_trigger_play_sh}" == "TRUE" ]; then echo "  VAR PLAYLISTPATH: $PLAYLISTPATH"   >> $PATHDATA/../logs/debug.log; fi
       
        if [ "${DEBUG_rfid_trigger_play_sh}" == "TRUE" ]; then echo "  Command: $PATHDATA/playout_controls.sh -c=playernext" >> $PATHDATA/../logs/debug.log; fi
        $PATHDATA/playout_controls.sh -c=playernext
    fi
else
    if [ "${DEBUG_rfid_trigger_play_sh}" == "TRUE" ]; then echo "Path not found $AUDIOFOLDERSPATH/$FOLDER" >> $PATHDATA/../logs/debug.log; fi
fi
