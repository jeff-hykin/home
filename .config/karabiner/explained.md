if key_going_down:quote
    quote_layer = 1
if key_going_up:quote
    quote_layer = 0
if key_going_down:quote
    quote_layer = 1
if key_going_up:quote
    quote_layer = 0
if key_going_down:spacebar
    spacebar_layer = 1
if key_going_up:spacebar
    spacebar_layer = 0

if spacebar_layer == 1 && quote_layer == 1
    if key_going_down:l
        send:right_arrow + alt + other modifiers
        return
    if key_going_down:j
        send:left_arrow + alt + other modifiers
        return

if spacebar_layer == 1
    if key_going_down:l
        send:right_arrow + other modifiers
        return
    if key_going_down:j
        send:left_arrow + other modifiers
        return
