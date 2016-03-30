# misc-linux-tools 
Various scripts for Linux (and BSD, Mac, etc)

##  system-motd.sh  
Generates some real-time info about your machine, suitably for login.  It's requirements are: whois,finger,figlet,systemd, and optionally toilet.
It's been tested on openSUSE and Gentoo linux. The text colors are derived based on your distro. Thus, gentoo is purple, opensuse is green, fedora would be blue, etc.

##  image_rename.pl  
I wrote this script to move images off of my camera, and onto my filesystem. Yes, i know there are already tools to do this, but the single feature I wanted most out of this was to rename the files based on date/time in the format of my chosing. By default it will rename files from $ARGV1 to /home/USER/Pictures/sorted/YEAR/YYYY-MM-DD_HH:MM:SS-xxxx.ext. It will also automagically re-encode via ffmpeg .{mov,3gpp,etc} files to .mp4. This script is actively maintained and more features are in the works.

##  DIR_COLORS_256.fruitpunch  
256color LS_COLORS for your terminal. You wont find a more complete version.

##  dubkat-shell-prompt.sh  
The results of tinkering around with a "live" bash_prompt. Hack-it-up to suit your needs. Works on OS X if you upgrade your bash from macports.


