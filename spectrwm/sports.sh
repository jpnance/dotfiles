#!/bin/sh

#(echo $dmenu_bottom && echo $bar_font && echo $bar_color && echo $bar_font_color && echo $color_focus) | dmenu | xclip
#(echo $1 && echo $2 && echo $3 && echo $4 && echo $5) | dmenu -l 5

#bar_font="Terminus-8,-*-terminus-medium-*-*-*-12-*-*-*-*-*-*-*,-*-profont-*-*-*-*-12-*-*-*-*-*-*-*,-*-times-medium-r-*-*-12-*-*-*-*-*-*-*,-misc-fixed-medium-r-*-*-12-*-*-*-*-*-*-*,-*-*-*-r-*-*-*-*-*-*-*-*-*-*"
#bar_color="rgb:00/00/00"
#bar_font_color="rgb:a0/a0/a0"
#color_focus="rgb:5e/b1/ed"

bar_font=$1
bar_color=$2
bar_font_color=$3
color_focus=$4
dmenu_bottom=$5

((curl --silent "https://www.nbcsportsedge.com/api/player_news?sort=-created&page%5Blimit%5D=5&page%5Boffset%5D=0&filter%5Bleague.meta.drupal_internal__id%5D=1" | jq -r '.data[].attributes.headline') && (curl --silent "https://www.nbcsportsedge.com/api/player_news?sort=-created&page%5Blimit%5D=5&page%5Boffset%5D=0&filter%5Bleague.meta.drupal_internal__id%5D=11" | jq -r '.data[].attributes.headline') && (curl --silent "https://www.nbcsportsedge.com/api/player_news?sort=-created&page%5Blimit%5D=5&page%5Boffset%5D=0&filter%5Bleague.meta.drupal_internal__id%5D=21" | jq -r '.data[].attributes.headline')) | dmenu $dmenu_bottom -i -h 20 -fn $bar_font -nb $bar_color -nf $bar_font_color -sb $color_focus -sf black | xclip
