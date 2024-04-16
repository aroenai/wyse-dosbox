#!/bin/bash

DIALOG_CANCEL=1
DIALOG_ESC=255
HEIGHT=0
WIDTH=50
_backtitle="Dell Wyse 3040"

# Define the menu title, labels and command(s) to run separated by a comma
main_menu=(
  "Main Menu"
  "Start DOSBOX,_launch dosbox"
  "Start ScummVM,_launch scummvm"
  "Options,_options"
  "Shutdown,sudo shutdown -h now"
)

options_menu=(
  "Options"
  "Sound Mixer,alsamixer"
  "Configure DOSBOX,nano $HOME/.config/dosbox/dosbox-staging.conf"
  "Configure ScummVM,nano $HOME/.config/scummvm/scummvm.ini"
  "Reboot,sudo shutdown -r now"
  "Shutdown,sudo shutdown -h now"
)

_t () {
  type -p "$1" &>/dev/null;
}

_which_cmd () {
  _t dialog && DIA=dialog && DIA_CANCEL="--cancel-label" && return
  _t whiptail && DIA=whiptail && DIA_CANCEL="--cancel-button" && return
  if [ -z $DIA ]; then
    echo "No whiptail or dialog found."
    exit 1
  fi
}

_launch () {
  # Parameter can be executable from $PATH or full path
  echo $@ > "$HOME/._openapp"
  if [ $(tty) == "/dev/tty1" ]; then
    startx -- >/dev/null 2>&1
  fi
}

_dialog () {
  local menu_items=("$@")
  declare -i i=0
  declare -a menu action
  for row in "${menu_items[@]}"; do
    if [ $i == 0 ]
    then
      _menutitle="$row"
      if [ "$_menutitle" == "${main_menu[0]}" ]
      then
        # Set the action for exiting the main menu
        local _cancellabel="Exit"
        local _cancelaction="echo 'Return to Linux shell' && exit"
      else
        # Set the action for any sub menus
        local _cancellabel="Back"
        local _cancelaction="break"
      fi
    else
      menu+=("$(expr ${i})")
      menu+=("$(echo "$row" | awk -F',' '{ print $1 }')")
      action[$i]=$(echo "$row" | awk -F',' '{ print $2 }')
    fi
    i+=1
  done
  while true; do
    # Deplicate (make a backup copy of) file descriptor 1 (stdout)
    # on descriptor 3
    exec 3>&1
    # Generate the dialog box while running dialog in a subshell
    selection=$("$DIA" \
      --backtitle "$_backtitle" \
      --title "$_menutitle" \
      --clear \
      "$DIA_CANCEL" "$_cancellabel" \
      --menu "Please select:" $HEIGHT $WIDTH $(expr ${i} - 1) \
      "${menu[@]}" \
      2>&1 1>&3)
    # Get dialog's exit status
    exit_status=$?
    # Close file descriptor 3
    exec 3>&-
    case $exit_status in
      $DIALOG_CANCEL | $DIALOG_ESC )
        clear
        eval "${_cancelaction}"
        ;;
      0 )
        eval "${action[${selection}]}"
        ;;
    esac
  done
}

_options () {
  _dialog "${options_menu[@]}"
  # Set the menu title for the previous dialog
  _menutitle=${main_menu[0]}
}

_which_cmd
_dialog "${main_menu[@]}"
