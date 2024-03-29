#!/bin/bash

usage()
{
cat << EOF
usage: $0 options

This script compares a given list of screenshots based on the list of urls.

OPTIONS:
   -h      Show this message
   -v      Version of the site currently being tested, whose screenshots will go into the actual directory (this value is only used to add a label to the diff images).
EOF
}

VERSION=
DIFF_FOUND=0

# arguments followed by : take a value
while getopts “hu:v” OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         v)
             VERSION="-$OPTARG"
             ;;
         ?)
             usage
             exit
             ;;
     esac
done

RED='\e[1;31m'
GREEN='\e[1;32m'
NC='\e[0m' # No Color

# prepare the diff directory and make sure it is empty
mkdir -p diff
rm -rf diff/*

# Get current version of the repository checkout (only 6 chars to keep it short).
#COMMIT=`git show`
#VERSION=${COMMIT:7:6}


#for img in `cd base; ls *.png`
for URL in `cat urls.txt`
do
  NAME=$URL

  # Replace slashes in path to fit in a filename.
  FILE=${URL//\//|}

  # frontpage syntax
  if [ "$URL" = "<front>" ]; then
    URL=''
  fi

  echo "-- Comparing screenshots for $NAME"

  #First compare the geometry/size of the images.
  if [ `identify -format %g base/$FILE.png` = `identify -format %g actual/$FILE.png` ]; then
    # Calculate the absolute error between the two images
    AE=`compare -metric ae base/$FILE.png actual/$FILE.png diff/$FILE$VERSION.shadow.png 2>&1`

    # Delete the diff file if there are no differences.
    if [ "$AE" = 0 ]; then
      echo -e "${GREEN}No difference found for $NAME${NC}"
      rm diff/$FILE$VERSION.shadow.png
      # Move on to the next URL.
      continue
    fi
  fi

  # If we got here, it means the images are different.
  echo -e "${RED}The screenshots for $NAME are different${NC}"
  DIFF_FOUND=1
  # The compare script might have already generated a diff image with the second image
  # as background if both images were the same size.
  # Generate other types of diff images in case the differences are not abvious.
  # The methods below do not require both images to have the same size.

  # Generate a composite difference image.
  # The destination image determines the final size of the difference image,
  # so use the taller screenshot as destination. The order of the image does
  # matter as the difference compose method is associative.
  BASE_H=`identify -format %h base/$FILE.png`
  ACTUAL_H=`identify -format %h actual/$FILE.png`
  if [ "$BASE_H" -ge "$ACTUAL_H" ]; then
    composite actual/$FILE.png base/$FILE.png -compose difference diff/$FILE$VERSION.composite.png
  else
    composite base/$FILE.png actual/$FILE.png -compose difference diff/$FILE$VERSION.composite.png
  fi

  # Generate a flicker.
  if [ "$BASE_H" -ge "$ACTUAL_H" ]; then
    convert -delay 50 base/$FILE.png actual/$FILE.png -loop 0 diff/$FILE$VERSION.flicker.gif
  else
    convert -delay 50 actual/$FILE.png base/$FILE.png -loop 0 diff/$FILE$VERSION.flicker.gif
  fi

done

# exit with error status if differences were found.
if [ "$DIFF_FOUND" = "1" ]; then
  echo 'At least one URL has differences.'
  exit 1
fi
