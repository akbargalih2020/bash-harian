#!/bin/bash

gp_connect() {
  osascript << EOF
tell application "System Events" to tell process "GlobalProtect"
	click menu bar item 1 of menu bar 2 -- Activates the GlobalProtect "window" in the menubar
	set frontmost to true -- keep window 1 active
	tell window 1
	  -- Find the status
	  tell (first UI element whose title is "Connect") to if exists then set message to "VPN is connecting now..."
	  tell (first UI element whose title is "Disconnect") to if exists then set message to "VPN is connected."
	  -- Click connect button
	  tell (first UI element whose title is "Connect") to if exists then click
	end tell
	click menu bar item 1 of menu bar 2 -- This will close the GlobalProtect "window" after clicking Connect/Disconnect. This is optional.
	say message
	return message
end tell
EOF
}

case $# in
   0)
      echo "Usage: $0 {start|stop}"
      exit 1
      ;;
   1)
      case $1 in
         start)
            echo "Starting GlobalProtect..."
            launchctl load /Library/LaunchAgents/com.paloaltonetworks.gp.pangpa.plist
            launchctl load /Library/LaunchAgents/com.paloaltonetworks.gp.pangps.plist
            echo "Done Launch, connecting to global protect!"
            gp-connect.sh
            ;;
         stop)
            echo "Stopping GlobalProtect..."
            launchctl remove com.paloaltonetworks.gp.pangps
            launchctl remove com.paloaltonetworks.gp.pangpa
            echo "Done!"
            ;;
         *)
            echo "'$1' is not a valid verb."
            echo "Usage: $0 {start|stop}"
            exit 2
            ;;
      esac
      ;;
   *)
      echo "Too many args provided ($#)."
      echo "Usage: $0 {start|stop}"
      exit 3
      ;;
esac
