# require ffmpeg and imagemagick installed

set -e
videoFilename=$1
filename="${videoFilename%.*}"
tmpFilename="$filename.tmp.gif"
gifFilename="$filename.gif"

# cf https://superuser.com/questions/556029/how-do-i-convert-a-video-to-gif-using-ffmpeg-with-reasonable-quality

filters="fps=10,scale=1000:-1:flags=lanczos,split[s0][s1];[s0]palettegen=max_colors=128[p];[s1][p]paletteuse=dither=bayer"

ffmpeg -i "$videoFilename" -vf "$filters" -c:v pam -f image2pipe - | convert -delay 10 - -loop 0 -layers optimize "$gifFilename"

echo "GIF $gifFilename generated"
