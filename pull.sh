#!/usr/bin/env bash

url="https://youtu.be/dQw4w9WgXcQ"
yt-dlp -S "res:720" --no-embed-thumbnail -t sleep "$url" -o "openroll_temp.webm"
ffmpeg -i openroll_temp.webm -vf 'crop=ih/3*4:ih' openroll.webm
rm openroll_temp.webm
