mol new ./spike_protein.gro 
mol addfile ./sample_trajectory.xtc 0

source ctbp_basic_scripts/la.tcl
source ctbp_basic_scripts/orient.tcl
source ctbp_basic_scripts/visualization.tcl
source vps.tcl

retrieve_vp 1

mol representation NewCartoon 0.3 10 4.1
mol material AOChalky
color Display Background white
colorByFile 0 ./SASA_scores.txt 2 1 0 2

animate goto 1
move_vp_render 1 2 0 . move 20

for {set i 1} {$i < 360} {incr i 10} {
rotate_axis {0 1 0} 10 top
take_picture
}

move_vp_render 2 1 20 . move 20
increment 1 75 5

mol selection "not protein"
mol representation Licorice 0.30 12.00 12.00
mol color ColorID 7
mol addrep 0
increment 75 150 5

mol delrep 1 0
increment 150 249 5

exit
