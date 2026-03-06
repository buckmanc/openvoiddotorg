#!/usr/bin/env bash

set -e

optBigWidth=2000
optSmallWidth=500
fontPath="PressStart2P.ttf"

# download the font if not present
if [[ ! -f "$fontPath" ]]
then
	curl --refer 'dafont.com' 'https://dl.dafont.com/dl/?f=press_start_2p' -o 'font.zip'
	7z e 'font.zip' "$fontPath"
	rm 'font.zip'
fi

# generate qr
qrencode --margin=1 --size=1 "ihttps://openroll.org" --output "$TEMP/orqr.png"
magick "$TEMP/orqr.png" -interpolate integer -filter point -resize "${optBigWidth}x${optBigWidth}" "qr_qr.png"

# determine border for the text as one "pixel" from the enlarged qr code
# since it has a natural one "pixel" white border
qrBaseWidth="$(identify -format '%w' "$TEMP/orqr.png")"
borderWidth="$((optBigWidth / qrBaseWidth))"
textWdith="$((optBigWidth - borderWidth - borderWidth))"

# generate text
# start too big
# then trim and resize down
# then add border
# then trim border from the top side only
magick -background white -gravity center -font PressStart2P.ttf -fill black \
	-size "$((textWdith + 200))x$((optBigWidth + 200))" caption:'OPENROLL.ORG' \
	-trim +repage \
	-resize "${textWdith}x${optBigWidth}" \
	-bordercolor white -border "$borderWidth" -define trim:edges=north -trim qr_text.png

# join and shrink
magick qr_qr.png qr_text.png -background white -gravity center -append images/qr_big.png
magick images/qr_big.png -resize "${optSmallWidth}" images/qr.png

# clean up
rm "qr_qr.png"
rm "qr_text.png"
rm "$TEMP/orqr.png"
