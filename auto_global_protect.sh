#!/bin/bash

gp-connect() {
osascript <<EOF
  tell application "System Events" to tell process "GlobalProtect"
    click menu bar item 1 of menu bar 2 -- Activates the GlobalProtect "window" in the menubar
    set frontmost to true -- keep window 1 active
    tell window 1
      -- Click on the connect or disconnect button, depending on if they exist or not
      if exists (first UI element whose title is "Connect") then
        tell (first UI element whose title is "Connect") to if exists then click
      else
        tell (first UI element whose title is "Disconnect") to if exists then set message to "VPN is connected."
      end if
    end tell
    say message
    return message
    click menu bar item 1 of menu bar 2 -- This will close the GlobalProtect "window" after clicking Connect/Disconnect. This is optional.
  end tell
EOF
}
check_toggle() {
    osascript << EOF
tell application "System Events" to tell process "GlobalProtect"
        click menu bar item 1 of menu bar 2 -- Activates the GlobalProtect "window" in the menubar
        set frontmost to true -- keep window 1 active
        tell window 1
          -- Find the status
          tell (first UI element whose title is "Connect") to if exists then set message to "globalprotect restarted"
          tell (first UI element whose title is "Disconnect") to if exists then set message to "globalprotect started."
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
  output=$(gp-connect | grep -v "execution error")
  while true; do
    if echo $output | grep "connect"; then
        echo "vpn connected"
        #exit
        break
    else
         echo "vpn not connected yet, try again;"
         output=$(gp-connect | grep -v "execution error")
         sleep 30
    fi
  done
}
check_gp() {
  toggle=$(check_toggle)
  if echo $toggle | grep "restart" ; then
    echo "sudah logout"
    read -p "re-login? (y/n) " yn
      case $yn in
        y ) echo "re-login now"
            try_gp ;;
        n ) echo "ok, see you."
            exit ;;
        * ) echo "invalid response"
            ;;
      esac
  else
    echo "masih login"
  fi
}

prompt() {
 read -p "running globalprotect? (y/n) " yn
    case $yn in
      y ) echo "ok, proceed now;"
          ;;
      n ) echo "ok, see you;"
          exit ;;
      * ) echo "invalid response"
    esac
}
n=0
if pgrep -l Global | grep [G]lobalProtect; then
  echo "app globalprotect still running"
else
  prompt;
  echo "run globalprotect;"
  tell_gp start
  echo "wait a second"
  sleep 20
  try_gp
fi

while true ; do
  check_gp ;
  sleep 1800
done
