#/bin/bash
# Script to install and setup Ubuntu for Formula and general use
# options
#   -v: verbose (show output of all commands)
#   -y: yes all (do not prompt before running each step)
#   -s: show command (print commands before running)

# flags
while getopts vys flag
do
    case "${flag}" in
        v) VERBOSE='true';;
        y) YESALL='true';;
        s) SHOWCMD='true';;
    esac
done

# redirect 3 and 4 to /dev/null unless VERBOSE is set
if [ -n "$VERBOSE" ]; then
  exec 3>&1 4>&2
else
  exec 3>> /dev/null 4>> /dev/null
fi

# redirect 5 to /dev/null unless SHOWCMD is set
if [ -n "$SHOWCMD" ]; then
  exec 5>&1
else
  exec 5>> /dev/null
fi

# Formatting shorthands
BOLD="\033[1m"
REGULAR="\033[0m"

# Zoom
# fish
# exa
# spacething
# theme applier
# fonts
# icons
# theme
# firefox extensions?
# firefox bookmarks?


#region Banner
BANNER=$(cat << "BANNER"

\033[34m                          ...,;:loxk0KXXXOc.                                    
\033[34m           ....',;:clodxxkO0KXNNWWMMMMMMMMXd.                                   
\033[34m;:cclodxkO0KKXNWWWMMMMMMMMMMMMMMMMMMMMMMMMMW0:                                  
\033[34mxNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNo.                                
\033[34m.:0WMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWWNNXXK0OOko'                \033[0m....,,;:ccloddl,
\033[34m  .cONMMMMMMMMMMMMWWNNXK00Okxdollc:;' \033[33m,..........             \033[0m.o0KXXNWWWMMWXx:. 
\033[34m    .':odxxxdollc:''` \033[33m,..........,,,;:ccllodxkO00Kx.            \033[0m:XMMMMMMMNOl.   
\033[33m           .....,,;;:clodxkkO0KXNNWWWMMMMMMMMMMMMWx.           \033[0m,0MMMMWXd,.      
\033[33m          'oOKXXNWWWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNl         \033[0m.c0WMMW0l.         
\033[33m           .;d0NMMMMMMMMMMMMMMMMMWWNXXK00Okxddolc:;.      \033[0m.,dKWMMNO:.           
\033[33m              .,coxk000Okkxdolc:;''` \033[0m,............,.,. .'lONMMMNk;.             
                          .....,,;:cloodxxkO0KXXNNWWN0k0NMMMMNk;                
                         .,cdkKXNWMMMMMMMMMMMMMMMMMMMMMMMMMWO:.                 
                             ..,;clodxkkkOOOOOO0XMMMMMMMMMKl.                   
                                                ,OWMMMMMWk'                     
                                                 ,0MMMMXl.                      
                                                  cO00k;                        
           .,,,,,,,.       .,,,.          .,,,.  ,,...,       .,,..             
        .ckKNWWWWNKkl'     cXNN0,        'ONNNo   ONNNXo.    ;0NNXc             
      .lKWMMWNXXNWMMMXd.   lWMMK;        '0MMWo   lWMMMWk'   ;XMMNl             
     .dWMMWOc;''':kNMMWk.  lWMMK;        '0MMWo   lNMMMMMK:  ;XMMNl             
     :XMMWx.      .oNMMWo  lNMMK;        '0MMWo   lNMMMMMMXo.;XMMNl             
     oWMMX:        ,KMMMx. lWMMK;        '0MMWo   lNMMWXNMMWkxXMMNl             
     :XMMWd.      .lNMMWo  lWMMK;        '0MMWo   lNMMXccKWMMWWMMNl             
     .dWMMWOc'...:xNMMWO'  lWMMXc.....   '0MMWo   lNMMX; 'kWMMMMMNc             
      .oXWMMWNXXNWMMMXd.   lWMMWNXXXXKc  '0MMWo   lNMMX;  .oXMMMMNc             
        .lkKNWWWWNXOo,     lXWWWWWWWWNl  'OWWNo   cXWWK,    ;0NWWXc             
           `'```''`'       `'``'''```'`   '``'`   `'``''     `'``'`             
                   ..                       .,         ..                       
          .:::.    o;    .:::.     ..::.. ,.lx,, ...:. ''    ..::..             
        .:c'''::.  o;  ,c;'':;.  .:c:'';; ::dk:; cx:'. ;l  .:c;'':;             
       .dl.....lo. o; ,x:....,dc.co.        ;o.  lo.   :o .lc                   
       'xo,''''``  o; :kc,'''`` .ll         ;o.  cl    :o .o:                   
        ;l;...,,   o; .cc,..,..  .lc'...'.  ;o.  cc    :o  ,l:'....             
         'loooo;   :'   ,ooool'   .:oddol,  ':.  ;;    ,:   .cdddl.             

BANNER
)


echo -e "$BANNER\n\n"
#endregion

## Welcome Prompt
PROMPT="\033[1;33m>\033[0m"
ASK="\033[1;33m?\033[0m"
CHECK="\033[34m✓\033[0m"
COMMAND="\033[34m$\033[0m"
echo -e "${PROMPT} Welcome to the ${BOLD}Formula Setup Utility${REGULAR}!"

# run a task
# arguments
#   1: task description message
#   2: command to run
run () {
  echo -en "${ASK} ${1} (Y/n)? "
  if [ "${YESALL}" = 'true' ]; then
    echo "y"
    ANSWER="y"
  else
    read -n 1 -p "" ANSWER
    echo ""
  fi
  case ${ANSWER:0:1} in
    # No
    n|N )
      true
    ;;
    # Yes (Default)
    * )
      # generally not the best idea to use, but it's safe enough because we aren't giving any user input
      eval "${@:2}"
    ;;
  esac
}

# check if a package is installed and do something if it isn't
# arguments
#   1: package to check for
#   2: command to run if it is not installed
check_for () {
  VERSION="$(dpkg-query -W -f='${Version}' ${1} 2>&1)"
  if [[ $VERSION =~ "no packages found" ]];
  then
    eval "${@:2}"
  else
    echo -e "${PROMPT} Found ${BOLD}v${VERSION}${REGULAR} already installed."
  fi
}

# run and print a command
c () {
  echo -e "${COMMAND} ${@:1}" >&5
  eval "${@:1}" >&3 2>&4
}

## Install Apps
#region
#region VSCode
install_vscode () {
  # Microsoft APT Repository
  c "wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg"
  c sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
  c sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
  echo -e "${CHECK} Added the ${BOLD}Microsoft APT Repository${REGULAR}."
  c rm -f packages.microsoft.gpg
  # VSCode
  c sudo apt install apt-transport-https -y
  c sudo apt update -y
  c sudo apt install code -y
  echo -e "${CHECK} Installed ${BOLD}Visual Studio Code${REGULAR}."
}

run "Install ${BOLD}Visual Studio Code${REGULAR}" check_for code install_vscode
#endregion

#region KiCad
# Confirm install
install_kicad () {
  # Kicad PPA
  c sudo add-apt-repository --yes ppa:kicad/kicad-5.1-releases
  echo -e "${CHECK} Added the ${BOLD}KiCad PPA${REGULAR}."
  # KiCad
  c sudo apt update
  c sudo apt install --install-recommends kicad -y
  echo -e "${CHECK} Installed ${BOLD}KiCad${REGULAR}."
}

run "Install ${BOLD}KiCad${REGULAR}" check_for kicad install_kicad
#endregion

#region Discord
# Confirm install
install_discord () {
  # Download
  c wget -O ~/Downloads/discord.deb "https://discordapp.com/api/download?platform=linux&format=deb"
  echo -e "${CHECK} Downloaded ${BOLD}Discord${REGULAR}."
  # Install
  c sudo apt install ~/Downloads/discord.deb -y
  echo -e "${CHECK} Installed ${BOLD}Discord${REGULAR}."
}

run "Install ${BOLD}Discord${REGULAR}" check_for discord install_discord
#endregion

#region Slack
install_slack () {
  # Download
  c wget -O ~/Downloads/slack.deb "https://downloads.slack-edge.com/linux_releases/slack-desktop-4.17.0-amd64.deb"
  echo -e "${CHECK} Downloaded ${BOLD}Slack${REGULAR}."
  # Install
  c sudo apt install ~/Downloads/slack.deb -y
  echo -e "${CHECK} Installed ${BOLD}Slack${REGULAR}."
}

run "Install ${BOLD}Slack${REGULAR}" check_for slack-desktop install_slack
#endregion

#region Zoom
# Confirm install
install_zoom () {
  # Download
  c wget -O ~/Downloads/zoom.deb "https://zoom.us/client/latest/zoom_amd64.deb"
  echo -e "${CHECK} Downloaded ${BOLD}Zoom${REGULAR}."
  # Install
  c sudo apt install ~/Downloads/zoom.deb -y
  echo -e "${CHECK} Installed ${BOLD}Zoom${REGULAR}."
}

run "Install ${BOLD}Zoom${REGULAR}" check_for zoom install_zoom
#endregion

#endregion

## Packages
#region
#region Install build tools
# build tools and essential packages
install_packages () {
  c sudo apt-get install build-essential manpages-dev gcc gcc-avr avrdude git neofetch -y
  echo -e "${CHECK} Installed ${BOLD}required packages${REGULAR}."
}

run "Install ${BOLD}required packages${REGULAR}" check_for gcc-avr install_packages
#endregion

# Done!
echo -e "${CHECK} Setup Complete. \n\n"

neofetch