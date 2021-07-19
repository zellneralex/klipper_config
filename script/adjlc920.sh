#!/bin/bash

####################################
#
# adjlc920 - v4l2-ctl simple setup for logitech c920 for octoprint use. iterate through array
#            to execute the commands vcmd[]. If there is an error, log the error in
#            syslog and quit. If all commands execute print success in syslog. I run it
#            on reboot in rc.local but you can run it from the terminal if you wish
#
#            this will work for any camera. the controls will vary based on the cam. use
#            v4l2-ctl -l to list the controls you can adjust
#
# CAUTION:   this will exit your rc.local script if it fails. place it cautiously
#
####################################

# quit if v4l2-ctl cannot be found
if [ ! -f /usr/bin/v4l2-ctl ]; then 
  echo "adjlc920 - /usr/bin/v4l2-ctl unavailable"
  exit 2
  fi

# the v4l2-ctl commands I want to run in the order I want to run them 
# (to find the controls you can use the command v4l2-ctl -l)
vcmd[0]="/usr/bin/v4l2-ctl -c focus_auto=0"
vcmd[1]="/usr/bin/v4l2-ctl -c focus_absolute=30"

exe=${vcmd[0]%% *}                        # this is the command i.e. /usr/bin/v4l2-ctl
logstring="V4L2-CTL"

for cmds in "${vcmd[@]}"
do
  cmdarg=${cmds:21}                       # get the argument to command
  $cmds                                   # execute v4l2-ctl command(s)
  if [[ $? != 0 ]]                        # if error
  then
    failed=1
    logger -t $logstring $cmdarg failed!  # log err to syslog - look up in /var/log/syslog
    break                                 # break out of loop
  fi
done

if [ -z $failed ]; then logger -t $logstring Success!; fi

exit
