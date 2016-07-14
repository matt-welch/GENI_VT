#!/bin/bash

# to use these colors call printf like: 
# printf "This is not colored"
# printf "${CLR_RED} This line is red ${CLR_NON}"
CLR_BLK='\033[0;30m' # Black
CLR_RED='\033[0;31m' # Red
CLR_GRN='\033[0;32m' # Green
CLR_BNO='\033[0;33m' # Brown/Orange a.k.a. bright yellow
CLR_BLU='\033[0;34m' # Blue
CLR_PUR='\033[0;35m' # Purple
CLR_CYN='\033[0;36m' # Cyan
CLR_LGY='\033[0;37m' # Light Gray
CLR_DGY='\033[1;30m' # Dark Gray
CLR_LRD='\033[1;31m' # Light Red
CLR_LGR='\033[1;32m' # Light Green
CLR_YEL='\033[1;33m' # Yellow
CLR_LBL='\033[1;34m' # Light Blue
CLR_LPU='\033[1;35m' # Light Purple
CLR_LCY='\033[1;36m' # Light Cyan
CLR_WHT='\033[1;37m' # White
CLR_NON='\033[0m'    # None

# carriage return type (defaults to add CR at EOL)
CR_TYPE="\n"

function fcn_print_red ( ) {
    OUTPUT="$1"
    if [ -n "$2" ] ; then 
        # suppress carriage return if any 2nd argument
        CR_TYPE=""
    fi
    printf "${CLR_RED}${OUTPUT}${CLR_NON}${CR_TYPE}"
}

function bash_color_usage ( ) {
#    echo ">>>${0}::${FUNCNAME[0]}:: "
    COLOR_LIST=(  "BLK"   "RED" "GRN"   "BNO"          "BLU"  "PUR"    "CYN"  "LGY" \
        "DGY"      "LRD"      "LGR"       "YEL"    "LBL"       "LPU"         "LCY"       "WHY" )
    COLOR_NAMES=( "Black" "Red" "Green" "Brown/Orange" "Blue" "Purple" "Cyan" "LightGrey" \
        "DarkGrey" "LightRed" "LightGreen" "Yellow" "LightBlue" "LightPurple" "LightCyan" "White" )
    NUM_COLORS=${#COLOR_LIST[*]}
    echo -e "\n  bash_colors.sh usage: $0 'my string' 'bash_color_code'"
    echo -e "    where bash_color_code is one of [$NUM_COLORS] available colors: \n"
    echo -e "Color\t\tColor\t\tCode"
    echo -e "-----\t\t-----\t\t----"
    for (( i=0; i<${NUM_COLORS}; i++ ))
    do 
        #echo $i
        echo -ne "${COLOR_NAMES[$i]}:\t\t" 
        fcn_print_color "${COLOR_NAMES[$i]}\t\t" ${COLOR_LIST[$i]} 0
        fcn_print_color "${COLOR_LIST[$i]}\t\n" ${COLOR_LIST[$i]} 0
    done
}

function select_color ( ) {
#    echo ">>>${0}::${FUNCNAME[0]}:: "
    # select the color
    CHOICE="$1"
    case "$CHOICE" in
        BLK) # Black
            COLOR="${CLR_BLK}"
            ;;
        RED) # Red
            COLOR="${CLR_RED}"
            ;;
        GRN) # Green
            COLOR="${CLR_GRN}"
            ;;
        BNO) # Brown/Orange
            COLOR="${CLR_BNO}"
            ;;
        BLU) # Blue
            COLOR="${CLR_BLU}"
            ;;
        PUR) # Purple
            COLOR="${CLR_PUR}"
            ;;
        CYN) # Cyan
            COLOR="${CLR_CYN}"
            ;;
        LGY) # Light Gray
            COLOR="${CLR_LGY}"
            ;;
        DGY) # Dark Gray
            COLOR="${CLR_DGY}"
            ;;
        LRD) # Light Red
            COLOR="${CLR_LRD}"
            ;;
        LGR) # Light Green
            COLOR="${CLR_LGR}"
            ;;
        YEL) # Yellow
            COLOR="${CLR_YEL}"
            ;;
        LBL) # Light Blue
            COLOR="${CLR_LBL}"
            ;;
        LPU) # Light Purple
            COLOR="${CLR_LPU}"
            ;;
        LCY) # Light Cyan
            COLOR="${CLR_LCY}"
            ;;
        WHT) # White
            COLOR="${CLR_WHT}"
            ;;
        NON) # None
            COLOR="${CLR_NON}"
            ;;
        *)
            COLOR="${CLR_NON}"
    esac
    echo "$COLOR"
}

function fcn_print_color ( ) {
#    echo ">>>${0}::${FUNCNAME[0]}:: "
    OUTPUT="$1"
    COLOR="$2"
    CLR_CHOICE="$(select_color "$COLOR")"
#    echo "Color Chosen= $COLOR :: <$CLR_CHOICE>"
    CR_TYPE="\n"
    if [ -n "$3" ] ; then 
        # suppress carriage return if any 3rd argument
        CR_TYPE=""
    fi
    printf "${CLR_CHOICE}${OUTPUT}${CLR_NON}${CR_TYPE}"
}

# if $0 is /bin/bash, we're probably sourced by /bin/bash 
# and running a function 
# from bash directly, no need to do anything for bash_colors.sh
if [ "$0" != "/bin/bash" ] ; then 
    # otherwise, 
    if [ -z "$1" ] ; then 
        # no text specified as an argument
        bash_color_usage
    else
        TEXT="$1"

        # assume bash_colors.sh is being called to change text color
        COLOR="$2"
        if [ -z "$COLOR" ] ; then 
            # no color code was specified on the command line, assume they want red :)
            COLOR="RED"
        fi
        # arg $3 is the "CR_TYPE" so any argument there will supress a CR at EOL
        fcn_print_color "$TEXT" "$COLOR" "$3"
    fi
fi

