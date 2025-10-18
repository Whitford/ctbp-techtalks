
#Alignment of 'target_sel' based on principal componet of 'sel'
#Requires to source orient.tcl and la.tcl 
proc align_pi {sel target_sel} {

	package require Orient
	namespace import Orient::orient

	set I [draw principalaxes $sel]
	set A [orient $sel [lindex $I 2] {0 0 1}]
	$target_sel move $A
	draw delete all
}

#Render current view as a .dat file
proc take_picture {args} {
  global take_picture

  # when called with no parameter, render the image
  if {$args == {}} {
    set f [format $take_picture(format) $take_picture(frame)]
    # take 1 out of every modulo images
    if { [expr $take_picture(frame) % $take_picture(modulo)] == 0 } {
      render $take_picture(method) $f
      # call any unix command, if specified
      if { $take_picture(exec) != {} } {
        set f [format $take_picture(exec) $f $f $f $f $f $f $f $f $f $f]
        eval "exec $f"
       }
    }
    # increase the count by one
    incr take_picture(frame)
    return
  }
  lassign $args arg1 arg2
  # reset the options to their initial stat
  # (remember to delete the files yourself
  if {$arg1 == "reset"} {
    set take_picture(frame)  0
    set take_picture(format) "./animate.%04d.dat"
    set take_picture(method) Tachyon 
    set take_picture(modulo) 1
    set take_picture(exec)    {}
    return
  }
  # set one of the parameters
  if [info exists take_picture($arg1)] {
    if { [llength $args] == 1} {
      return "$arg1 is $take_picture($arg1)"
    }
    set take_picture($arg1) $arg2
    return
  }
  # otherwise, there was an error
  error {take_picture: [ | reset | frame | format  | \
  method  | modulo ]}
}
# to complete the initialization, this must be the first function
# called.  Do so automatically.
take_picture reset

#Rotate 'deg' degrees the object based on 'vect' 
proc rotate_axis {vec deg {molid top}} {
    # get the current matrix
    lassign [molinfo $molid get rotate_matrix] curr
    # the transformation matrix
    set r [trans axis $vec $deg]
    # get the new matrix
    set m [transmult $r $curr]
    # and apply it to the molecule
    molinfo $molid set rotate_matrix "{ $m }"
}

#Increment the trajectory frame from 'start' to 'end' using a 'increment' as step without rendering
proc increment_np { start end increment} {
    for {set i $start} {$i < $end} {incr i $increment} {
            # go to the given frame
            animate goto $i
            # force display update
            display update
    }
}

#Increment the trajectory frame from 'start' to 'end' using a 'increment' as step while rendering each frame
proc increment { start end increment} {
    for {set i $start} {$i < $end} {incr i $increment} {
            # go to the given frame
            animate goto $i
            # force display update
            display update
            # take the picture              
            take_picture
    }
}

# Save viewpoints into a file
proc write_vps {filename} {
  global viewpoints
  set myfile [open $filename w]
  puts $myfile "\#This file contains viewpoints for a VMD script, view_change.tcl.\n\#Type 'source $filename' from the VMD command window to load these viewpoints.\n"
  foreach mol [molinfo list] {
    foreach v [array names viewpoints] {
      if [string equal -length 5 $v "here,"] {continue}
	    puts $myfile "set viewpoints($v) { $viewpoints($v) }\n "
    }
  }
  puts $myfile "puts \"\\nLoaded viewpoints file $filename \\n\"\n"
  close $myfile
}

# Save viewpoint 
proc save_vp {view_num} {
  global viewpoints
  if [info exists viewpoints($view_num)] {unset viewpoints($view_num)}
  # get the current matricies
  foreach mol [molinfo list] {
    set viewpoints($view_num,$mol,0) [molinfo $mol get rotate_matrix]
    set viewpoints($view_num,$mol,1) [molinfo $mol get center_matrix]
    set viewpoints($view_num,$mol,2) [molinfo $mol get scale_matrix]
    set viewpoints($view_num,$mol,3) [molinfo $mol get global_matrix]
  }
} 

# Move from viewpoint 'start' to viewpoint 'end'
proc move_vp {start end {morph_frames 50} args} {
  global viewpoints 
  set pi 3.1415926535
  set smooth 1
  set tumble 0
  set ninja  0
  set render 0
  if {[lsearch $args "smooth"] > -1}  {set smooth 1}  ;#default
  if {[lsearch $args "sharp"] > -1} {set smooth 0}
  if {[lsearch $args "tumble"] > -1}  {set tumble 1}
  if {[lsearch $args "ninja"] > -1}   {set ninja 1}
  if {[lsearch $args "-render"] > -1} {set render 1}  ;# only for use by move_vp_render
  if {$render} {set framenum $::VCR::first_frame_num}
  if {$start == "here" || $end == "here"} {save_vp "here"}       
  foreach mol [molinfo list] {
    if [info exists viewpoints($start,$mol,0)] {
      set old_rotate($mol)  $viewpoints($start,$mol,0)
      set old_center($mol) $viewpoints($start,$mol,1)
      set old_scale($mol) $viewpoints($start,$mol,2)
      set old_global($mol)  $viewpoints($start,$mol,3)
    } else {
      puts "Starting view $start was not saved" 
    }
    if [info exists viewpoints($end,$mol,0)] {
      set new_rotate($mol)  $viewpoints($end,$mol,0)
      set new_center($mol) $viewpoints($end,$mol,1)
      set new_scale($mol) $viewpoints($end,$mol,2)
      set new_global($mol)  $viewpoints($end,$mol,3)
    } else {
      puts "Starting view $start was not saved" 
    }
    #leave if don't have both viewpoints
    if {!([info exists viewpoints($start,$mol,0)] && [info exists viewpoints($end,$mol,0)])} {
      error "move_vp_render failed, don't have both start and end viewpoints"
    }
    set begin_euler [matrix_to_euler $old_rotate($mol)]
    set end_euler   [matrix_to_euler $new_rotate($mol)]
    set diff [vecsub $end_euler $begin_euler]
    # Make sure to take the quickest path!
    set f [expr 1./$pi]
    for {set i 0} {$i < 3} {incr i} {
      if  {[lindex $diff $i] > $pi} {
        set end_euler [lreplace $end_euler $i $i [expr [lindex $end_euler $i] -2.*$pi]]
      } elseif {[lindex $diff $i] < [expr -$pi]} {
        set end_euler [lreplace $end_euler $i $i [expr 2.*$pi + [lindex $end_euler $i]]]
      }
    }
    if {$ninja} {
      set end_euler [lreplace $end_euler 2 2 [expr 2.*$pi + [lindex $end_euler 2]]]
    }
    set needed_center($mol) [sub_mat  $new_center($mol) $old_center($mol)]
    set needed_scale($mol)  [sub_mat  $new_scale($mol)  $old_scale($mol)]
    set needed_global($mol) [sub_mat  $new_global($mol) $old_global($mol)]
  }
  set firstj 0
  if {$start == "here"} {set firstj 1}   
  for {set j $firstj} {$j<= ($morph_frames - 1)} {incr j} {
    foreach mol [molinfo list] {
      #set scaling to apply for this individual frame
      if {$smooth} {
        #accelerate smoothly to start and stop 
        set theta [expr 3.1415927 * (0.0 + $j)/($morph_frames - 1)] 
        set scale_factor [expr 0.5*(1 - cos($theta))]
      } else {
        #infinite acceleration to start and stop
        set scale_factor [expr (0.0 + $j)/($morph_frames - 1)] 
      }
      if {$j == $morph_frames} {
        #avoid roundoff errors by ending in correct position
        set current_rotate($mol) $new_rotate($mol)
        set current_center($mol) $new_center($mol)
        set current_scale($mol)  $new_scale($mol)
        set current_global($mol) $new_global($mol)
      } else {
        set euler {}
        set random 0.
        if {$tumble} {set random 0.1} 
        lappend euler [expr (1.-$scale_factor)*[lindex $begin_euler 0] + $scale_factor*[lindex $end_euler 0] + $random*rand()]
        lappend euler [expr (1.-$scale_factor)*[lindex $begin_euler 1] + $scale_factor*[lindex $end_euler 1] + $random*rand()]
        lappend euler [expr (1.-$scale_factor)*[lindex $begin_euler 2] + $scale_factor*[lindex $end_euler 2] + $random*rand()]
        set current_rotate($mol) [euler_to_matrix $euler]
        set current_center($mol) [add_mat $old_center($mol) [scale_mat $needed_center($mol) $scale_factor]]
        set current_scale($mol)  [add_mat $old_scale($mol)  [scale_mat $needed_scale($mol)  $scale_factor]]
        set current_global($mol) [add_mat $old_global($mol) [scale_mat $needed_global($mol) $scale_factor]]
      }
      molinfo $mol set rotate_matrix $current_rotate($mol)
      molinfo $mol set center_matrix $current_center($mol)
      molinfo $mol set scale_matrix $current_scale($mol)
      molinfo $mol set global_matrix $current_global($mol)
    }
    display update
    if {$render} {
      set frametext [justify $framenum]
      render Tachyon [file join $::VCR::dirName $::VCR::filePrefixName.$frametext.dat]  
      puts "Rendering frame [file join $::VCR::dirName $::VCR::filePrefixName.$frametext.dat]"
      incr framenum
    }
  }
}


# Move from viewpoint 'start' to viewpoint 'end' and render each intermediate frame
proc move_vp_render {start end first_frame_num dirName filePrefixName {morph_frames 50} args} {
  set ::VCR::first_frame_num $first_frame_num
  set ::VCR::dirName         $dirName
  set ::VCR::filePrefixName  $filePrefixName
  eval move_vp $start $end $morph_frames -render $args
}

# Retrieve 'view_num' viewpoint 
proc retrieve_vp {view_num} {
  global viewpoints
  foreach mol [molinfo list] {
    if [info exists viewpoints($view_num,$mol,0)] {
      molinfo $mol set rotate_matrix   $viewpoints($view_num,$mol,0)
      molinfo $mol set center_matrix   $viewpoints($view_num,$mol,1)
      molinfo $mol set scale_matrix   $viewpoints($view_num,$mol,2)
      molinfo $mol set global_matrix   $viewpoints($view_num,$mol,3)
    } else {
      puts "View $view_num was not saved"}
  }
}

# Alternative way of getting/setting view points for all molecules
proc get_vp {} {
  set molid 0
  set M [list [molinfo $molid get center_matrix] [molinfo $molid get rotate_matrix] [molinfo $molid get scale_matrix] [molinfo $molid get global_matrix ] ]
  return $M
}

proc set_vp {viewname viewmatrix} {
  global viewpoints
  foreach mol [molinfo list] {
    set viewpoints($viewname,$mol,0) [lindex $viewmatrix 1]
    set viewpoints($viewname,$mol,1) [lindex $viewmatrix 0]
    set viewpoints($viewname,$mol,2) [lindex $viewmatrix 2]
    set viewpoints($viewname,$mol,3) [lindex $viewmatrix 3]
  }
}

proc colorByFile {molid rmsfFile cscale {column 1} {scaleMin -1} {scaleMax -1}} {
    # This function adds a NewCartoon representation with coloring according to RMSF
    #
    # molid    --> molecule ID
    # rmsfFile --> file with data to be imposed in structure
    # csale --> Color scale with 2 or 3 points
    # column --> Column in file with the desired data
    # scaleMin --> minimum in color scale
    # scaleMax --> max in color scale
    #
    # * setting scaleMin and scaleMax allows for consistant color scaling between
    #        different structures
    # delete all existing representations
    set numReps [molinfo $molid get numreps]
    for {set i 0} {$i < $numReps} {incr i} {
        mol delrep 0 $molid
    }
    # the minimum and maximum beta values that VMD will color
    set minVal 0
    set maxVal 0
    if {$scaleMin != -1 && $scaleMax != -1} {
        set val [expr ($scaleMax - $scaleMin) * 0.015]
        set minVal [expr $scaleMin + $val]
        set maxVal [expr $scaleMax - $val]
    }
    # read RMSF file
    puts "Reading File data..."
    set numAtoms 0
    set selText "serial"
    set numClipped 0
    set readFlag 0
    set inF [open $rmsfFile r]
    while { [gets $inF line] >= 0 } {
        set splitLine [split [string trim $line]]
        set atomNum($numAtoms) [lindex $splitLine 0]
        set rmsf($numAtoms) [lindex $splitLine $column]
        # if scaleMax and scaleMin are specified, make sure that the rmsf is
        #       in range
        if {$scaleMin != -1 && $scaleMax != -1} {
            if {$rmsf($numAtoms) < $minVal} {
                set rmsf($numAtoms) $minVal
                incr numClipped
                set selText "$selText $atomNum($numAtoms)"
            } elseif {$rmsf($numAtoms) > $maxVal} {
                set rmsf($numAtoms) $maxVal
                incr numClipped
                set selText "$selText $atomNum($numAtoms)"
            }
        }
        incr numAtoms
    }
    close $inF
    puts ""
    puts "$numClipped Column values were clipped to place them in the requested range"
    if {$numClipped > 0} {
        puts $selText
    }
    puts ""
    puts "Setting Column values..."
    set sel [atomselect $molid "all"]
    $sel set beta 0.0
    $sel delete
    for {set i 0} {$i < $numAtoms} {incr i} {
        set sel [atomselect $molid "residue $atomNum($i)"]
        $sel set beta $rmsf($i)
        $sel delete
    }
    mol color Beta
    mol selection "all"
    mol addrep $molid
    if {$cscale == 2} {
        bicolor_scale
    } else {
        tricolor_scale        
    }
    set repNum [expr [molinfo $molid get numreps] - 1]
    if {$scaleMin == -1 || $scaleMax == -1} {
        mol scaleminmax $molid $repNum auto 
    } else {
        mol scaleminmax $molid $repNum $scaleMin $scaleMax
    }
    return
}

proc colorByResid {molid cscale {scaleMin -1} {scaleMax -1}} {
    # This function adds a NewCartoon representation with coloring according to the resid
    #
    # molid    --> molecule ID
    # scaleMin --> minimum in color scale
    # scaleMax --> max in color scale
    #
    # * setting scaleMin and scaleMax allows for consistant color scaling between
    #        different structures
    # delete all existing representations
    set numReps [molinfo $molid get numreps]
    for {set i 0} {$i < $numReps} {incr i} {
        mol delrep 0 $molid
    }
    # the minimum and maximum beta values that VMD will color
    set minVal 0
    set maxVal 0
    if {$scaleMin != -1 && $scaleMax != -1} {
        set val [expr ($scaleMax - $scaleMin) * 0.015]
        set minVal [expr $scaleMin + $val]
        set maxVal [expr $scaleMax - $val]
    }
    # set beta value to Resid
    puts "Setting beta values..."
    set numResids 1900
    set sel [atomselect $molid "all"]
    $sel set beta 0.0
    $sel delete
    for {set i 1} {$i <= $numResids} {incr i} {
        set sel [atomselect $molid "resid $i"]
        $sel set beta $i
        $sel delete
    }
    mol color Beta
    mol representation NewCartoon 0.3 60 4.1 0
    mol addrep $molid
    if {$cscale == 2} {
        bicolor_scale
    } else {
        tricolor_scale        
    }
    set repNum [expr [molinfo $molid get numreps] - 1]
    if {$scaleMin == -1 || $scaleMax == -1} {
        mol scaleminmax $molid $repNum auto 
    } else {
        mol scaleminmax $molid $repNum $scaleMin $scaleMax
    }
    return
}

proc tricolor_scale {} {
  display update off
  set mincolorid [expr [colorinfo num] - 1]
  set maxcolorid [expr [colorinfo max] - 1]
  set colrange [expr $maxcolorid - $mincolorid]
  set colhalf [expr $colrange / 2]
  for {set i $mincolorid} {$i < $maxcolorid} {incr i} {
    set colpcnt [expr ($i - $mincolorid) / double($colrange)]

    # Orange --> Cyan --> Magenta
    set firstColor { 1.0 0.5 0.0 }
    set middleColor { 0.0 0.88 1.0 }
    set lastColor { 0.9 0.0 0.9 }

    # Green
    #set firstColor { 0.9 0.9 0.9 }
    #set middleColor { 0.604 0.929 0.529 }
    #set lastColor { 0.25 0.58 0.24 }

    if { $colpcnt < 0.5 } {
      set nc [lerpcolor $firstColor $middleColor [expr $colpcnt * 2.0]]
    } else {
      set nc [lerpcolor $middleColor $lastColor [expr ($colpcnt-0.5) * 2.0]]
    }

    foreach {r g b} $nc {}
    display update ui
    color change rgb $i $r $g $b
  }
  display update on
}


proc bicolor_scale {} {
  display update off
  set mincolorid [expr [colorinfo num] - 1]
  set maxcolorid [expr [colorinfo max] - 1]
  set colrange [expr $maxcolorid - $mincolorid - 1]
  for {set i $mincolorid} {$i < $maxcolorid} {incr i} {
    set colpcnt [expr ($i - $mincolorid) / double($colrange)]

    # Cyan --> Magenta
    set firstColor { 0.8 0.8 0.8 }
    set lastColor { 0.99 0.0 0.0 }

    set nc [lerpcolor $firstColor $lastColor $colpcnt]

    foreach {r g b} $nc {}
    display update ui
    color change rgb $i $r $g $b
  }
  display update on
}
#SCRIPTS FOR VIEWPOINTS
# view_change_render.tcl
#
# A script to save current viewpoints and animate
# a smooth 'camera move' between them,
# rendering each frame to a numbered .ppm file
#  (Can also do the 'camera moves' without
#   writing files.)
#
# version 1.1b4
# Barry Isralewitz, Jordi Cohen
# Oct 2003; updated Feb 2007 
# barryi@ks.uiuc.edu
#
# Usage:
# In the vmd console type 
#       save_vp 1
# to save your current viewpoint
#
# type
#       retrieve_vp 1  
# to retrieve that viewpoint  (You can replace '1' with an integer < 10000)
#
# After you've saved more than 1 viewpoint
#  move_vp_render 1 8 200 /tmp myMove 25 smooth
# will move from viewpoint 1 to viewpoint 8 smoothly, recording 25 frames 
# to /tmp/myMove####.ppm, with #### ranging from 0200 -- 0224. 
#
#       move_vp 1 43
# will retrieve viewpoint 1 then smoothly move to viewpoint 43.
# (move_vp does not render .ppm files, move_vp_render does) 
#  Note warning above.  Extreme moves that cause obvious protein distortion
# can be done in two or three steps.
#
# To specify animation frames used, use
#    move_vp 1 43 200
# will move from viewpoint 1 to 43 in 200 steps.  If this is not specified, a 
# default 50 frames is used.
#
# To specify smooth/jerky accelaration, use
#   move_vp 1 43 200 smooth
#   move_vp_render 1 8 200 /tmp myMove 25 smooth 
#   or
#   move_vp 1 43 200 sharp
#   move_vp_render 1 8 200 /tmp myMove 25 sharp 
#
# the 'smooth' option accelerates and deccelrates the transformation
# the 'sharp' option gives constant velocity
#
# Use 'here' in place of a viewpoint number to move from or to the currently 
# displayed view:
#   move_vp here 43
# will move from the current view to viewpoint 43    
#   move_vp_render 8 here 200 /tmp myMove 25 
# will move from viewpoint 8 to the current view and record the
# frames to .ppm files.
#
# To write viewpoints to a file, 
# write_vps my_vp_file.tcl
# 
# viewpoints with integer numbers 0-10000 are saved   
#
# To retrieve viewpoints from a file,
# source my_vp_file.tcl  
#

namespace eval ::VCR:: {}

proc scale_mat {mat scaling} {
  set bigger ""
  set outmat ""
  for {set i 0} {$i<=3} {incr i} {
    set r ""
    for {set j 0} {$j<=3} {incr j} {            
      lappend r  [expr $scaling * [lindex [lindex [lindex $mat 0] $i] $j] ]
    }
    lappend outmat  $r
  }
  lappend bigger $outmat
  return $bigger
}

proc div_mat {mat1 mat2} {
  set bigger ""
  set outmat ""
  for {set i 0} {$i<=3} {incr i} {
    set r ""
    for {set j 0} {$j<=3} {incr j} {            
      lappend r  [expr  (0.0 + [lindex [lindex [lindex $mat1 0] $i] $j]) / ( [lindex [lindex [lindex $mat2 0] $i] $j] )]

    }
    lappend outmat  $r
  }
  lappend bigger $outmat
  return $bigger
}

proc sub_mat {mat1 mat2} {
  set bigger ""
  set outmat ""
  for {set i 0} {$i<=3} {incr i} {
    set r ""
    for {set j 0} {$j<=3} {incr j} {            
      lappend r  [expr  (0.0 + [lindex [lindex [lindex $mat1 0] $i] $j]) - ( [lindex [lindex [lindex $mat2 0] $i] $j] )]

    }
    lappend outmat  $r
  }
  lappend bigger $outmat
  return $bigger
}

proc power_mat {mat thePower} {
  set bigger ""
  set outmat ""
  for {set i 0} {$i<=3} {incr i} {
    set r ""
    for {set j 0} {$j<=3} {incr j} {            
      lappend r  [expr pow( [lindex [lindex [lindex $mat 0] $i] $j], $thePower)]
    }
    lappend outmat  $r
  }
  lappend bigger $outmat
  return $bigger
}

proc mult_mat {mat1 mat2} {
  set bigger ""
  set outmat ""
  for {set i 0} {$i<=3} {incr i} {
    set r ""
    for {set j 0} {$j<=3} {incr j} {            
      lappend r  [expr  (0.0 + [lindex [lindex [lindex $mat1 0] $i] $j]) * [lindex [lindex [lindex $mat2 0] $i] $j] ]
    }
    lappend outmat  $r
  }
  lappend bigger $outmat
  return $bigger
}

proc add_mat {mat1 mat2} {
  set bigger ""
  set outmat ""
  for {set i 0} {$i<=3} {incr i} {
    set r ""
    for {set j 0} {$j<=3} {incr j} {            
      lappend r  [expr  (0.0 + [lindex [lindex [lindex $mat1 0] $i] $j]) + [lindex [lindex [lindex $mat2 0] $i] $j] ]
    }
    lappend outmat  $r
  }
  lappend bigger $outmat
  return $bigger
}


proc matrix_to_euler {mat} {
  set pi 3.1415926535
  set R31 [lindex $mat 0 2 0]
  
  if {$R31 == 1} {
    set phi1 0.
    set psi1 [expr atan2([lindex $mat 0 0 1],[lindex $mat 0 0 2]) ]
    set theta1 [expr -$pi/2]
  } elseif {$R31 == -1} {
    set phi1 0.
    set psi1 [expr atan2([lindex $mat 0 0 1],[lindex $mat 0 0 2]) ]
    set theta1 [expr $pi/2]
  } else {
    set theta1 [expr -asin($R31)]
    # Alternate correct solution with a different trajectory:
    # set theta1 [expr $pi + asin($R31)]
    set cosT [expr cos($theta1)]
    set psi1 [expr  atan2([lindex $mat 0 2 1]/$cosT,[lindex $mat 0 2 2]/$cosT) ]
    set phi1 [expr  atan2([lindex $mat 0 1 0]/$cosT,[lindex $mat 0 0 0]/$cosT) ]
  }

  return "$theta1 $phi1 $psi1"
}

proc euler_to_matrix {euler} {
  set theta [lindex $euler 0]
  set phi [lindex $euler 1]
  set psi [lindex $euler 2]
    
  set mat {}
  lappend mat [list [expr cos($theta)*cos($phi)] [expr sin($psi)*sin($theta)*cos($phi) - cos($psi)*sin($phi)] [expr cos($psi)*sin($theta)*cos($phi) + sin($psi)*sin($phi)] 0. ]

  lappend mat [list [expr cos($theta)*sin($phi)] [expr sin($psi)*sin($theta)*sin($phi) + cos($psi)*cos($phi)] [expr cos($psi)*sin($theta)*sin($phi) - sin($psi)*cos($phi)] 0. ]
  
  lappend mat [list [expr -sin($theta)] [expr sin($psi)*cos($theta)] [expr cos($psi)*cos($theta)] 0. ]
    
  lappend mat [list 0. 0. 0. 1. ]
       
  return [list $mat]
}

proc justify {justify_frame} {
  if { $justify_frame < 1 } { 
    set frametext "0000"
  } elseif { $justify_frame < 10 } {
    set frametext "000$justify_frame"
  } elseif {$justify_frame < 100} {
    set frametext "00$justify_frame"
  } elseif {$justify_frame <1000} {
    set frametext "0$justify_frame"
  }  else {
    set frametext $justify_frame
  }
  return $frametext 
}

# The first four helper functions were copied and/or adapted from the VMD User Forum
#  
proc lerpcolor { col1 col2 alpha } {
  set dc [vecsub $col2 $col1]
  set nc [vecadd $col1 [vecscale $dc $alpha]]
  return $nc
}

proc coltogs { col } {
  foreach {r g b} $col {}
  set gray [expr ($r + $g + $b) / 3.0]
  return [list $gray $gray $gray]
}

############################################
############################################
# END OF SUPPORT SCRIPTS
############################################
############################################
