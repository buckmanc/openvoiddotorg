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
qrencode --margin=1 --size=1 "https://openvoid.org" --output "$TEMP/ovqr.png"
magick "$TEMP/ovqr.png" -interpolate integer -filter point -resize "${optBigWidth}x${optBigWidth}" "qr_qr.png"

# determine border for the text as one "pixel" from the enlarged qr code
# since it has a natural one "pixel" white border
qrBaseWidth="$(identify -format '%w' "$TEMP/ovqr.png")"
borderWidth="$((optBigWidth / qrBaseWidth))"
textWidth="$((optBigWidth - borderWidth - borderWidth))"

# generate text
# start too big
# then trim and resize down
# then add border
# then trim border from the top side only
magick -background white -gravity center -font PressStart2P.ttf -fill black \
	-size "$((textWidth + 200))x$((optBigWidth + 200))" label:'OPENVOID.ORG' \
	-trim +repage \
	-resize "${textWidth}x${optBigWidth}" \
	-bordercolor white -border "$borderWidth" -define trim:edges=north -trim qr_text_bottom.png

# top text
# magick -background white -gravity center -font PressStart2P.ttf -fill black \
# 	-size "$((textWidth + 200))x$((optBigWidth + 200))" label:'JOIN THE MOVEMENT' \
# 	-trim +repage \
# 	-resize "${textWidth}x${optBigWidth}" \
# 	-bordercolor white -border "$borderWidth" -define trim:edges=south -trim qr_text_top.png

# join bottom text
magick qr_qr.png qr_text_bottom.png -background white -gravity center -append images/qr_big.png

# create tiny version
magick images/qr_big.png -resize "${optSmallWidth}" images/qr.png

# # slap top text on the big qr
# magick qr_text_top.png images/qr_big.png -background white -gravity center -append images/qr_big.png


magick -background white -gravity center -font PressStart2P.ttf -fill black \
	-size "450x450" label:$'OPEN\nVOID\n.ORG' -trim \
	square_text.png

magick square_text.png -gravity center \
	-background white -extent '500x500' \
	images/open_void_social_card.png

magick square_text.png -gravity center \
	-background white -resize '400x400' +repage \
	-extent '640x480' \
	openvoid_intro_thumbnail.png

magick square_text.png -gravity center \
	-background white -resize '46x46' +repage \
	-extent '48x48' \
	favicon.png

# clean up
rm -f "qr_qr.png"
rm -f "qr_text_bottom.png"
rm -f "qr_text_top.png"
rm -f "$TEMP/ovqr.png"
rm -f "square_text.png"
