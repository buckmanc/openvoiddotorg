#!/usr/bin/env bash

set -e

ffmpegLocArgs=()

if ! type ffmpeg > /dev/null 2>&1
then
	curlArgs=(--referer 'https://ffbinaries.com' --location --anyauth --insecure --header "Upgrade-Insecure-Requests: 1" --user-agent "Mozilla/5.0 Gecko")
	apiResponse="$(curl "${curlArgs[@]}" 'https://ffbinaries.com/api/v1/version/latest')"
	# echo "apiResponse: $apiResponse"
	binaryUrl="$(echo "$apiResponse" | jq -r '.bin."linux-64"'.ffmpeg)"
	curl "${curlArgs[@]}" -O "$binaryUrl"
	zipPath="$(find . -type f -iname 'ffmpeg*.zip' -print -quit)"

	ls -sh "$zipPath"
	file "$zipPath"

	unzip "$zipPath" -d .
	ffmpegLocArgs=(--ffmpeg-location ".")

	rm "$zipPath"
fi

if ! type yt-dlp > /dev/null 2>&1
then
	pip install yt-dlp
fi

url="https://youtu.be/dQw4w9WgXcQ"
yt-dlp \
	-S "res:720" \
	--no-embed-thumbnail \
	-t sleep \
	"$url" \
	-o "openroll_temp.webm" \
	--write-subs \
	--sub-format 'vtt' \
	--sub-langs 'en' \
	"${ffmpegLocArgs[@]}"

# crop out the black bars
ffmpeg -i openroll_temp.webm -vf 'crop=ih/3*4:ih' openroll_intro.webm
mv openroll_temp.en.vtt openroll_intro.en.vtt

# clean up
rm openroll_temp.webm
rm -f ./ffmpeg
