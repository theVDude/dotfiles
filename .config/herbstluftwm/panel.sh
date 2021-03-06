#!/bin/bash
set -f
monitor=${1:-0}
geometry=( $(herbstclient monitor_rect "$monitor") )
if [ -z "$geometry" ] ;then
    echo "Invalid monitor $monitor"
    exit 1
fi
# geometry has the format: WxH+X+Y
x=${geometry[0]}
y=${geometry[1]}
panel_width=${geometry[2]}
panel_height=14
font="-*-terminus-medium-*-*-*-12-*-*-*-*-*-*-*"
font2="Terminus:size=8"
#bgcolor=$(herbstclient get frame_border_normal_color)
bgcolor='#222222'
selbg=$(herbstclient get window_border_active_color)
selfg='#222222'

####
# Try to find textwidth binary.
# In e.g. Ubuntu, this is named dzen2-textwidth.
if [ -e "$(which textwidth 2> /dev/null)" ] ; then
    textwidth="textwidth";
elif [ -e "$(which dzen2-textwidth 2> /dev/null)" ] ; then
    textwidth="dzen2-textwidth";
else
    echo "This script requires the textwidth tool of the dzen2 project."
    exit 1
fi
####
# true if we are using the svn version of dzen2
dzen2_version=$(dzen2 -v 2>&1 | head -n 1 | cut -d , -f 1|cut -d - -f 2)
if [ -z "$dzen2_version" ] ; then
    dzen2_svn="true"
else
    dzen2_svn=""
fi

function uniq_linebuffered() {
    awk '$0 != l { print ; l=$0 ; fflush(); }' "$@"
}

herbstclient pad $monitor $panel_height
{
    # events:
    while true ; do
        # Add a clickable area (ca) to the date/time to show a dropdown calendar
        date +'date ^ca(1, dzen-cal)^fg(#ababab)%H:%M^fg(#007700) :: ^fg(#ababab)%Y-%m-%d^ca()'
        sleep 1 || break
    done > >(uniq_linebuffered)  &
    childpid=$!
    herbstclient --idle
    kill $childpid
} 2> /dev/null | {
    TAGS=( $(herbstclient tag_status $monitor) )
    stripped_tags=( ${TAGS[@]/?f/} ) # Here is where we remove the "f" tag for floating layer
    visible=true
    date=""
    nowplaying=""
    windowtitle=""
    while true ; do
        bordercolor="#26221C"
        separator="^bg()^fg($selbg)|"
        # draw tags
        for i in "${stripped_tags[@]}" ; do
            case ${i:0:1} in
                '#') # Tag is on specified monitor AND focused
                    echo -n "^bg($selbg)^fg($selfg)"
                    ;;
                '+') # Tag is on specified monitor AND NOT focused
                    echo -n "^bg($selbg)^fg(#ababab)"
                    #echo -n "^bg(#93D44F)^fg(#141414)"
                    ;;
                ':') # Tag is not empty
                    echo -n "^bg(#444444)^fg(#ababab)"
                    ;;
                '!') # URGENT TAG
                    echo -n "^bg(#ababab)^fg(#141414)"
                    ;;
                '.') # This one is empty tags. I choose to not show them, personal preference.
                    continue
                    ;;
                '-') # Tag is on specified monitor AND NOT focused
                    echo -n "^bg(#93D44F)^fg(#141414)"
                    ;;
                '%') # Tag is on specified monitor AND NOT focused
                    echo -n "^bg(#93D44F)^fg(#141414)"
                    ;;
                *)
                    echo -n "^bg()^fg(#ababab)"
                    ;;
            esac
            if [ ! -z "$dzen2_svn" ] ; then
                echo -n "^ca(1,herbstclient focus_monitor $monitor && "'herbstclient use "'${i:1}'") '"${i:1} ^ca()"
            else
                echo -n " ${i:1} "
            fi
        done
        echo -n "$separator"
        echo -n "^bg()^fg(#ababab) ${windowtitle//^/^^}"
        # small adjustments
        right="$separator^bg() $date $separator"
        right_text_only=$(echo -n "$right"|sed 's.\^[^(]*([^)]*)..g')
        # get width of right aligned text.. and add some space..
        # textwidth chokes on unicode, so I'll just fudge it!
        width=($(echo -n "$right_text_only" | wc -m)+3)*6
        #width=$($textwidth "$font" "$right_text_only    ")
        echo -n "^pa($(($panel_width - $width)))$right"
        echo
        # wait for next event
        read line || break
        cmd=( $line )
        # find out event origin
        case "${cmd[0]}" in
            tag*)
                #echo "reseting tags" >&2
                TAGS=( $(herbstclient tag_status $monitor) )
                stripped_tags=( ${TAGS[@]/?f/} )
                ;;
            date)
                #echo "reseting date" >&2
                date="${cmd[@]:1}"
                ;;
            acpi)
                #echo "resetting batt percent" >&2
                acpi="${cmd[@]:1}"
                ;;
            quit_panel)
                exit
                ;;
            togglehidepanel)
                #echo "togglehide()"
                if $visible ; then
                    visible=false
                    herbstclient pad $monitor 0
                else
                    visible=true
                    herbstclient pad $monitor $panel_height
                fi
                ;;
            reload)
                exit
                ;;
            focus_changed|window_title_changed)
                windowtitle="${cmd[@]:2}"
                ;;
        esac
        done
} 2> /dev/null | dzen2 -w $panel_width -x $x -y $y -fn "$font" -h $panel_height \
    -ta l -bg "$bgcolor" -fg '#efefef'


