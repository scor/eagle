#!/bin/bash

usage()
{
cat << EOF
usage: $0 options

This script crawls a given list of urls from the site given in the -u argument

OPTIONS:
   -h      Show this message
   -u      URL of the frontpage to crawl 
   -v      Verbose
EOF
}

BASE=
VERBOSE=

# allow for default local configuration
if [ -f eagleconfig ]; then
    echo "Using local eagleconfig file"
    . eagleconfig
fi


# arguments followed by : take a value
while getopts “hu:v” OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         u)
             BASE=$OPTARG
             ;;
         v)
             VERBOSE=1
             ;;
         ?)
             usage
             exit
             ;;
     esac
done

# required values
#if [[ -z $TEST ]] || [[ -z $SERVER ]] || [[ -z $PASSWD ]]
if [[ -z $BASE ]]
then
     usage
     exit 1
fi

# this is the directory of the baseline screenshots.
mkdir -p actual

for URL in `cat urls.txt`
do
  FILE=$URL
  if [ "$URL" = "<front>" ]; then
    URL=''
  fi
  echo "Taking screenshot of $BASE$URL"
  CutyCapt --url=$BASE$URL --out=actual/$FILE.png
  #compare -metric ae old/$img new/$img diff/$img
done

