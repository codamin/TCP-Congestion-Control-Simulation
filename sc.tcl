set var [lindex $argv 1]
for {set i 0} {$i < $var } {incr i} {
  puts i
  puts $i
}


#Open the NAM trace file
#set namfile [open out.nam w]
#$ns namtrace-all $namfile
#set tracefile [open out.tr w]
#$ns trace-all $tracefile

#set nmFile [lindex $argv 0]
set nmFile out.nam
#set namfile [open [subst $nmFile] w]
set namfile [open out.nam w]
$ns nametrace-all $namfile

#set trFile [lindex $argv 1]
set trFile out.tr
set tracefile [open $trFile w]
$ns trace-all $tracefile
