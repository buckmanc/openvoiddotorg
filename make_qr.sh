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

qrBaseWidth="$(identify -format '%w' "$TEMP/orqr.png")"
borderWidth="$((optBigWidth / qrBaseWidth))"


# generate text
magick -background white -gravity center -font PressStart2P.ttf -fill black -size "${optBigWidth}x${optBigWidth}" caption:'OPENROLL.ORG' +repage -trim -bordercolor white -border 10 qr_text.png

# join and shrink
magick qr_qr.png qr_text.png -gravity center -append images/qr_big.png
magick images/qr_big.png -resize "${optSmallWidth}" images/qr.png

rm "qr_qr.png"
rm "qr_text.png"
