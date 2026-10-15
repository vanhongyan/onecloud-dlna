#!/bin/bash
cd /tmp/gmrender-resurrect-0.3.1
find . -name '*.c' -o -name '*.h' | head -20
echo '---'
grep -rn 'about-to-finish\|playbin\|uridecodebin\|use-buffering\|buffer-size\|buffer-duration' src/ 2>/dev/null | head -25 || grep -rn 'about-to-finish\|playbin\|uridecodebin' . --include='*.c' --include='*.h' | head -25
echo GREP-DONE
