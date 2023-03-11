#!/bin/bash

gp-connect() {
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


tell_gp() {
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
            echo "Done Launch, connect to gp!"
            ;;
         stop):
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
}
try_gp() {
  #./gp-connect.sh > output.txt
  gp-connect >& output.txt
  while true; do
    if cat output.txt | grep "connect"; then
        echo "vpn connected"
        #exit
        break
    else
         echo "vpn not connected yet, try again;"
         gp-connect >& output.txt
         sleep 20
    fi
  done
}
check_gp() {
 if ping 10.62.205.26 | head -3 | grep "Request timeout"; then
   echo "vpn not connected. reconnect;"
   try_gp ;
 else
   echo "vpn still connected"
 fi
}
prompt() {
 read -p "running globalprotect? (y/n) " yn
    case $yn in
      y ) echo "ok, proceed now;"
#        try_gp
         ;;
      n ) echo "ok, see you;"
        exit ;;
      * ) echo "invalid response"
    esac
}
n=0
prompt;
while true ; do
  if ps -ef | grep -E "[G]lobalProtect" ; then
    if [ $n == 1 ] ; then
        echo "sudah 2 jam"
        n=0
        tell_gp stop
        exit
    else
        echo "belum 2 jam"
        n=$(( $n +1 ))
        check_gp;
        sleep 1800
    fi
  else
    echo "belum ada proses globalprotect,start proses!"
    tell_gp start
    sleep 30
    try_gp;
  fi
done
