#!/bin/bash

X_DRIVE="/mnt/x"
PERSONAL_DRIVE="/mnt/u"

SYNERGY="Ignore"
SYNERGY_SERVER="10.10.10.22"

MOUNT="Ignore"

# If an external monitor is connected, place it with xrandr
SCREEN="Ignore"

# External output may be "VGA" or "VGA-0" or "DVI-0" or "TMDS-1"
EXTERNAL_OUTPUT="DVI-I-2" #"HDMI2" #"2 #"VGA1"
INTERNAL_OUTPUT="DVI-I-1" #"HDMI1"

# EXTERNAL_LOCATION may be one of: left, right, above, or below
EXTERNAL_LOCATION="right"

usage()
{
    echo ""
    echo "$0 is a tool for setting mount points, screens and resolution."
    echo ""
    echo "the settings are divided to three sections:"
    echo -e "	\033[1m1.\033[0m Setting mount points (a.k.a X drive)."
    echo -e "	\033[1m2.\033[0m Screen setting (Single\Dual, Primary) and resolution."
    echo -e "	\033[1m3.\033[0m Network settings (Currently only Synergy)"
    echo ""
    echo "usage: $0 [OPTIONS]"
    echo ""
    echo -e "where \033[1;4mOPTIONS\033[0m are:"
    echo -e "      \033[1m-h\033[0m, \033[1m--help\033[0m"
    echo "          Show this manual."
    echo -e "      \033[1m-v\033[0m, \033[1m--video\033[0m"
    echo "          Set the screen setting (default == $SCREEN)"
    echo "          where the valid values are:"
    echo "             - [Ignore] do not set the display(s)."
    echo "             - [Auto] set the display(s) automatically."
    echo "             - [SingleEx] set the external display as a single screen."
    echo "             - [Single|SingleIn] set internal display (laptop) as a single screen."
    echo "             - [DualExLeft|DualEL] set dual screen display, external will be left of the internal."
    echo "             - [DualExRight|DualER] set dual screen display, external will be right of the internal."
    echo "             - [Rot] set dual screen display, with rotated external screen." 
    echo -e "      \033[1m-m\033[0m, \033[1m--mount\033[0m"
    echo "          Tells the script if it should mount the network drives (default == $MOUNT)"
    echo "          where the valid values are: [Yes] [No] [Ignore]"
    echo -e "      \033[1m-s\033[0m, \033[1m--synergy\033[0m"
    echo "          Set the synergy client (default == $SYNERGY)"
    echo "          where the valid values are: [On] [Off] [Ignore]"
    echo ""
}

#read arguments
while [ "$1" != "" ]; do
PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        -h | --help)
            usage
            exit 0
            ;;
        -v | --video)
            SCREEN=$VALUE
            if [[ ! "Auto SingleEx Single SingleIn DualExLeft DualEL DualExRight DualER DualExLeft2 DualEL2 DualExRight2 DualER2 Rot" =~ ( |^)$SCREEN($| ) ]];
            then
                echo "invalid screen setting ($SCREEN), valid values: "
                echo "    [Auto] [SingleEx] [Single] [SingleIn] [DualExLeft] [DualEL] [DualExRight] [DualER]"
                exit 1
            fi
            ;;
        -s | --synergy)
            SYNERGY=$VALUE
            if [[ ! "Ignore On Off" =~ ( |^)$SYNERGY($| ) ]]
            then
                echo "invalid synergy setting, valid values: "
                echo "    [Ignore] [On] [Off]"
                exit 1
            fi
            ;;
        -m | --mount)
            MOUNT=$VALUE
            if [[ ! "Ignore Yes No" =~ ( |^)$MOUNT($| ) ]]
            then
                echo "invalid synergy setting, valid values: "
                echo "    [Ignore] [Yes] [No]"
                exit 1
            fi
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
shift
done

case $MOUNT in
    Ignore)
        ;;
    Yes)
        if [ ! -d $X_DRIVE/Users ]; then
            gksu umount $X_DRIVE
            sudo umount $PERSONAL_DRIVE
            sudo mount -a
        fi
        ;;
    No)
        if [ -d $X_DRIVE/Users ]; then
            gksu umount $X_DRIVE
            sudo umount $PERSONAL_DRIVE
        fi
        ;;
    *)
        usage
        exit 1
        ;;
esac

case $SYNERGY in
    Ignore)
        ;;
    On)
        killall -s 9 synergyc &> /dev/null
        synergyc --daemon $SYNERGY_SERVER &> /dev/null
        ;;
    Off)
        killall -s 9 synergyc &> /dev/null
        killall -s 9 synergys &> /dev/null
        ;;
    *)
        usage
        exit 1
        ;;
esac

case "$EXTERNAL_LOCATION" in
       left|LEFT)
               EXTERNAL_LOCATION="--left-of $INTERNAL_OUTPUT"
               ;;
       right|RIGHT)
               EXTERNAL_LOCATION="--right-of $INTERNAL_OUTPUT"
               ;;
       top|TOP|above|ABOVE)
               EXTERNAL_LOCATION="--above $INTERNAL_OUTPUT"
               ;;
       bottom|BOTTOM|below|BELOW)
               EXTERNAL_LOCATION="--below $INTERNAL_OUTPUT"
               ;;
       *)
               EXTERNAL_LOCATION="--left-of $INTERNAL_OUTPUT"
               ;;
esac

xrandr | grep $EXTERNAL_OUTPUT | grep -q " connected "

if [ $? -eq 0 ]; then
    # External monitor is connected
    grep -q open /proc/acpi/button/lid/*/state
    if [ $? -eq 0 ]; then
        xrandr --output $INTERNAL_OUTPUT --auto --output $EXTERNAL_OUTPUT --primary --auto $EXTERNAL_LOCATION

        # Alternative command in case of trouble:
        # (sleep 2; xrandr --output $INTERNAL_OUTPUT --auto --output $EXTERNAL_OUTPUT --auto $EXTERNAL_LOCATION) &
    else
        # Lid is closed, project only to the external monitor
        xrandr --output $EXTERNAL_OUTPUT --auto --output $INTERNAL_OUTPUT --off
    fi
else
    # No external monitor
    xrandr --output $INTERNAL_OUTPUT --auto --output $EXTERNAL_OUTPUT --off
fi

case $SCREEN in
    Ignore)
        ;;
    SingleEx)
        xrandr --output $EXTERNAL_OUTPUT --auto --output $INTERNAL_OUTPUT --off
        ;;
    Single | SingleIn)
        xrandr --output $INTERNAL_OUTPUT --auto --output $EXTERNAL_OUTPUT --same-as $INTERNAL_OUTPUT
        ;;
    DualExLeft2 | DualEL2)
        xrandr --output $INTERNAL_OUTPUT --auto --output $EXTERNAL_OUTPUT --auto --primary --left-of $INTERNAL_OUTPUT
        ;;
    DualExRight2 | DualER2)
        xrandr --output $INTERNAL_OUTPUT --auto --output $EXTERNAL_OUTPUT --auto --primary --right-of $INTERNAL_OUTPUT
        ;;
    DualExLeft | DualEL)
#        xrandr --output $INTERNAL_OUTPUT --auto --output $EXTERNAL_OUTPUT --auto --primary --left-of $INTERNAL_OUTPUT
        xrandr --output $INTERNAL_OUTPUT --auto --primary --output $EXTERNAL_OUTPUT --auto --left-of $INTERNAL_OUTPUT
        ;;
    DualExRight | DualER)
#        xrandr --output $INTERNAL_OUTPUT --auto --output $EXTERNAL_OUTPUT --auto --primary --right-of $INTERNAL_OUTPUT
        xrandr --output $INTERNAL_OUTPUT --auto --primary --output $EXTERNAL_OUTPUT --auto --right-of $INTERNAL_OUTPUT
        ;;
    Rot)
        xrandr --output $EXTERNAL_OUTPUT --auto --primary --rotate left --output $INTERNAL_OUTPUT --auto --right-of $EXTERNAL_OUTPUT --rotate normal
        xrandr --output $INTERNAL_OUTPUT --pos 1080x232
        ;; 
    Auto)
        xrandr | grep $EXTERNAL_OUTPUT | grep -q " connected "

        if [ $? -eq 0 ]; then
            # External monitor is connected
            grep -q open /proc/acpi/button/lid/*/state
            if [ $? -eq 0 ]; then
                xrandr --output $INTERNAL_OUTPUT --auto --output $EXTERNAL_OUTPUT --primary --auto $EXTERNAL_LOCA$

                # Alternative command in case of trouble:
                # (sleep 2; xrandr --output $INTERNAL_OUTPUT --auto --output $EXTERNAL_OUTPUT --auto $EXTERNAL_LO$
            else
                # Lid is closed, project only to the external monitor
                xrandr --output $EXTERNAL_OUTPUT --auto --output $INTERNAL_OUTPUT --off
            fi
        else
            # No external monitor
            xrandr --output $INTERNAL_OUTPUT --auto --output $EXTERNAL_OUTPUT --off
        fi
        ;;
    *)
        usage
        exit 1
        ;;
esac

echo "All settings performed successfully."
