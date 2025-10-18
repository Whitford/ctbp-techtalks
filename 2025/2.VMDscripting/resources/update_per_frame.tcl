proc enabletrace {} { 
  global vmd_frame; 
  trace variable vmd_frame([molinfo top]) w drawcallback 
} 
proc disabletrace {} { 
  global vmd_frame; 
  trace vdelete vmd_frame([molinfo top]) w drawcallback 
} 
proc drawcallback { name element op } { 
  global vmd_frame; 
  set i $vmd_frame([molinfo top])

  puts "callback!"
  # Here you can add code to update the VMD display based on the new frame index $i
} 