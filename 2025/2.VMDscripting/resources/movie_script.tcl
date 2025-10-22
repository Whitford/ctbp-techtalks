source visualization.tcl

retrieve_vp 1

## Movement from vp 1 to vp 2
move_vp_render 1 2 0 . "animate"

# correct frame count of take_picture
set take_picture(frame) 50
take_picture

## Go through frames 1 to 500
increment 1 501 1

## Movement from vp 2 to vp 1
move_vp_render 2 1 551 . "animate"

# correct frame count of take_picture
set take_picture(frame) 601

## Go through frames 601 to 1000
increment 601 1001 1
