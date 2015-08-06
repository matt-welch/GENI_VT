#!/bin/bash

# to use these colors call printf like: 
# printf "This is not colored"
# printf "${CLR_RED} This line is red ${CLR_NON}"
CLR_BLK='\033[0;30m' # Black
CLR_RED='\033[0;31m' # Red
CLR_GRN='\033[0;32m' # Green
CLR_BNO='\033[0;33m' # Brown/Orange
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

function fcn_print_red() {
    OUTPUT="$1"
    printf "${CLR_RED}${OUTPUT}${CLR_NON}\n"
}
