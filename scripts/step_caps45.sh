#!/bin/bash
gst-launch-1.0 -v -e videotestsrc pattern=smpte num-buffers=30 ! video/x-raw,width=1280,height=720,framerate=25/1 ! \
  videoscale add-borders=true ! video/x-raw,width=1280,height=720,pixel-aspect-ratio=1/1 ! \
  videobox fill=black left=-320 top=-180 right=-320 bottom=-180 ! fakesink 2>&1 | grep -E 'caps|INVALID' | grep -vE 'videotestsrc|src>' | head -10
echo CAPS-DONE
