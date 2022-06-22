#!/bin/bash
# Script to install and setup Ubuntu for Formula and general use
# options
#   -v: verbose (show output of all commands)
#   -y: yes all (do not prompt before running each step)
#   -s: show command (print commands before running)

# TODO: chsh for fish
# TODO: browser extensions
# TODO: vscode extensions
# TODO: browser bookmarks
# TODO: kicad settings
# TODO: git setup
#         - clone repos from config
#         - run smudge filters (should be in config?)
#         - git config --global...
# TODO: kicad 6
# TODO: ssh key
# TODO: olin wifi
# TODO: move configs and options into a config file (can have one for formula and one personal)

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

# force a sudo prompt right away
echo -e "${PROMPT} Setup requires super user permission "
sudo -k
sudo echo "" > /dev/null

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

# check if a package is installed and do something if it isn't
# arguments
#   1: package to check for
#   2: flag to check version
#   3: command to run if it is not installed
check_for_version () {
  VERSION="$(${1} ${2} 2>&1)"
  if [[ $VERSION =~ "${0}" ]];
  then
    eval "${@:3}"
  else
    echo -e "${PROMPT} Found ${BOLD}${VERSION}${REGULAR} already installed."
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
  c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list'
  echo -e "${CHECK} Added the ${BOLD}Visual Studio Code APT Repository${REGULAR}."
  c rm -f packages.microsoft.gpg
  # VSCode
  c sudo apt install apt-transport-https -y
  c sudo apt update -y
  c sudo apt install code -y
  echo -e "${CHECK} Installed ${BOLD}Visual Studio Code${REGULAR}."
}

run "Install ${BOLD}Visual Studio Code${REGULAR}" check_for code install_vscode
#endregion

#region Edge
install_edge () {
  c "wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg"
  c sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
  c 'echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/edge stable main" | sudo tee /etc/apt/sources.list.d/microsoft-edge-beta.list'
  echo -e "${CHECK} Added the ${BOLD}Microsoft Edge APT Repository${REGULAR}."
  c sudo apt update -y
  c sudo apt install microsoft-edge-beta
  echo -e "${CHECK} Installed ${BOLD}Microsoft Edge${REGULAR}."
}

run "Install ${BOLD}Microsoft Edge${REGULAR}" check_for microsoft-edge-beta install_edge
#endregion

#region KiCad
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
# exa
install_exa () {
  EXA_VERSION="0.10.1"
  c wget -q -O "~/Downloads/exa_${EXA_VERSION}.zip" "https://github.com/ogham/exa/releases/download/v${EXA_VERSION}/exa-linux-x86_64-v${EXA_VERSION}.zip"
  c unzip -o "~/Downloads/exa_${EXA_VERSION}.zip" -d "~/Downloads/exa_v${EXA_VERSION}"
  c sudo cp "~/Downloads/exa_v${EXA_VERSION}/bin/exa" /usr/local/bin/exa
  c sudo chmod +x /usr/local/bin/exa
  c sudo cp "~/Downloads/exa_v${EXA_VERSION}/man/exa.1" /usr/share/man/man1/exa.1
  c sudo cp "~/Downloads/exa_v${EXA_VERSION}/completions/exa.fish" /usr/share/fish/vendor_completions.d/exa.fish
  
  echo -e "${CHECK} Installed ${BOLD}exa${REGULAR}."
}

run "Install ${BOLD}exa${REGULAR}" install_exa check_for exa
#endregion

#region
# build tools and essential packages (for formula)
install_packages () {
  # TODO: move to config
  c sudo apt-get install build-essential manpages-dev gcc gcc-avr avrdude git neofetch zip unzip -y
  echo -e "${CHECK} Installed ${BOLD}required packages${REGULAR}."
}

run "Install ${BOLD}required packages${REGULAR}" install_packages
#endregion

## Shell stuff
#region
#region fish
install_fish () {
  c sudo apt-get install -y fish
  echo -e "${CHECK} Installed ${BOLD}fish${REGULAR}."
}

run "Install ${BOLD}fish${REGULAR}" check_for fish install_fish
#endregion

#region starship
install_starship () {
  c curl -fsSL https://starship.rs/install.sh -o ~/Downloads/starship
  c sh ~/Downloads/starship -y
  c "echo 'eval \"\$(starship init bash)\"' >> ~/.bashrc"
  c mkdir -p ~/.config/fish
  c "echo 'starship init fish | source' >> ~/.config/fish/config.fish"
  echo -e "${CHECK} Installed ${BOLD}starship${REGULAR}."
}

run "Install ${BOLD}starship${REGULAR}" check_for_version starship -V install_starship
#endregion

#region jq
install_jq () {
  c sudo apt-get install -y jq
  echo -e "${CHECK} Installed ${BOLD}jq${REGULAR}."
}

run "Install ${BOLD}jq${REGULAR}" check_for jq install_jq
#endregion

#region font
install_cascadia_nf () {
  # this mess gets the latestet release from API AND uses jq to get the download url AND downloads it
  c mkdir -p ~/.fonts
  URL="$(curl -s https://api.github.com/repos/adam7/delugia-code/releases/latest | jq '.assets | map(select(.name == "delugia-complete.zip")) | .[0].browser_download_url' | tr -d \\\")"
  c curl -L "${URL}" -o ~/Downloads/delugia-code.zip
  echo -e "${CHECK} Downloaded ${BOLD}Cascadia Code Nerd Font${REGULAR}."
  c unzip -o ~/Downloads/delugia-code.zip -d ~/Downloads/delugia-code
  c cp -r ~/Downloads/delugia-code/delugia-complete ~/.fonts/
  c sudo fc-cache -f -v
  echo -e "${CHECK} Installed ${BOLD}Cascadia Code Nerd Font${REGULAR}."
}
run "Install ${BOLD}Cascadia Code Nerd Font${REGULAR}" check_for cascadia_code install_cascadia_nf
#endregion

#endregion

## Theme

## Grub

## NodeJS
#region 
install_node () {
  # take ownership of the directory it installs to
  sudo mkdir -p /usr/local/n
  sudo chown -R $(whoami) /usr/local/n
  sudo mkdir -p /usr/local/bin /usr/local/lib /usr/local/include /usr/local/share
  sudo chown -R $(whoami) /usr/local/bin /usr/local/lib /usr/local/include /usr/local/share
  
  c curl -L https://raw.githubusercontent.com/tj/n/master/bin/n -o ~/Downloads/n
  chmod +x ~/Downloads/n
  c bash ~/Downloads/n lts
  c sudo npm install -g n
  echo -e "${CHECK} Installed ${BOLD}Node${REGULAR}."
}

run "Install ${BOLD}Node${REGULAR}" check_for_version node -v install_node
#endregion

# Done!
echo -e "${CHECK} Setup Complete. \n\n"

neofetch

# Install theme

# Install grub theme
#endregion

## Git
#region
# Generate SSH Key

# Update config

# Setup Formula repo
#endregion

## Configs
# Apply configs

# missing:
# theme
# homepage settings
# ddg
# bookmarks
# extensions

# vscode
# extensions
# settings