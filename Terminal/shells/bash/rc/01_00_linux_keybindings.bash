# if [ "$OSTYPE" = "linux-gnu" ] 
# then
#     # if xmodmap exists
#     if [ -n "$(command -v "xmodmap")" ]
#     then
#         # remap Ctrl_L to ModeSwitch, then use it to map arrow keys so that
#         # they act like on the MacBook keyboard with Fn key pressed 
#         xmodmap -e "keycode 37=Mode_switch"
#         xmodmap -e "keycode 113 = Left NoSymbol Home"
#         xmodmap -e "keycode 114 = Right NoSymbol End"
#         xmodmap -e "keycode 111 = Up NoSymbol Prior"
#         xmodmap -e "keycode 116 = Down NoSymbol Next"
#     fi
# fi