#######################################
# Library of env vars for terminal colors.
#######################################

. bin/lib/tput.bash

COLOR_FG_BLACK='\033[30m'
COLOR_FG_RED='\033[31m'
COLOR_FG_GREEN='\033[32m'
COLOR_FG_YELLOW='\033[33m'
COLOR_FG_BLUE='\033[34m'
COLOR_FG_MAGENTA='\033[35m'
COLOR_FG_CYAN='\033[36m'
COLOR_FG_WHITE='\033[37m'

COLOR_BG_BLACK='\033[40m'
COLOR_BG_RED='\033[41m'
COLOR_BG_GREEN='\033[42m'
COLOR_BG_YELLOW='\033[43m'
COLOR_BG_BLUE='\033[44m'
COLOR_BG_MAGENTA='\033[45m'
COLOR_BG_CYAN='\033[46m'
COLOR_BG_WHITE='\033[47m'

COLOR_NONE=$(tput.suppress.error sgr0)
COLOR_RESET=$(tput.suppress.error init)

export COLOR_FG_BLACK
export COLOR_FG_RED
export COLOR_FG_GREEN
export COLOR_FG_YELLOW
export COLOR_FG_BLUE
export COLOR_FG_MAGENTA
export COLOR_FG_CYAN
export COLOR_FG_WHITE

export COLOR_BG_BLACK
export COLOR_BG_RED
export COLOR_BG_GREEN
export COLOR_BG_YELLOW
export COLOR_BG_BLUE
export COLOR_BG_MAGENTA
export COLOR_BG_CYAN
export COLOR_BG_WHITE

export COLOR_NONE
export COLOR_RESET
