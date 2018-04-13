#!/bin/sh
xset +fp /usr/share/fonts/local
xset fp rehash
xrdb -load ~/.Xresources
setxkbmap -option compose:ralt
export GTK_IM_MODULE=xim &&

case $1 in
bspwm)
  sxhkd &
  urxvt &
  exec bspwm
  ;;
hlwm)
	exec herbstluftwm --autostart "/home/robert/.config/herbstluftwm/autostart"
	;;
*)
	exec herbstluftwm --autostart "/home/robert/.config/herbstluftwm/autostart"
	;;
esac
