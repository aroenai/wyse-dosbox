#!/bin/bash

DIALOG_CANCEL=1
DIALOG_ESC=255
HEIGHT=0
WIDTH=0
_backtitle="Dell Wyse 3040"

_launch () {
  echo $@ > $HOME/._openapp
  if [ $(tty) == "/dev/tty1" ]; then
    startx -- >/dev/null 2>&1
  fi
}

_options () {
  while true; do
    exec 3>&1
    selection=$(dialog \
      --backtitle "$_backtitle" \
      --title "Options" \
      --clear \
      --cancel-label "Back" \
      --menu "Please select:" $HEIGHT $WIDTH 4 \
      "1" "Sound Mixer" \
      "2" "Configure DOSBOX" \
      "3" "Reboot" \
      "4" "Shutdown" \
      2>&1 1>&3)
    exit_status=$?
    exec 3>&-
    case $exit_status in
      $DIALOG_CANCEL | $DIALOG_ESC )
        clear
        break
        ;;
    esac
    case $selection in
      1 )
        alsamixer
        ;;
      2 )
        nano $HOME/.config/dosbox/dosbox-staging.conf
        ;;
      3 )
        sudo shutdown -r now
        ;;
      4 )
        sudo shutdown -h now
        ;;
    esac
  done
}

while true; do
  # Deplicate (make a backup copy of) file descriptor 1 (stdout)
  # on descriptor 3
  exec 3>&1
  # Generate the dialog box while running dialog in a subshell
  selection=$(dialog \
    --backtitle "$_backtitle" \
    --title "Main Menu" \
    --clear \
    --cancel-label "Exit" \
    --menu "Please select:" $HEIGHT $WIDTH 4 \
    "1" "Start DOSBOX" \
    "2" "Start ScummVM" \
    "3" "Options" \
    "4" "Shutdown" \
    2>&1 1>&3)
  # Get dialog's exit status
  exit_status=$?
  # Close file descriptor 3
  exec 3>&-
  case  $exit_status in
    $DIALOG_CANCEL | $DIALOG_ESC )
      clear
      echo "Return to linux shell."
      exit
      ;;
  esac
  case $selection in
    1 )
      _launch dosbox
      ;;
    2 )
      _launch scummvm
      ;;
    3 )
      _options
      ;;
    4 )
      sudo shutdown -h now
      ;;
  esac
done
