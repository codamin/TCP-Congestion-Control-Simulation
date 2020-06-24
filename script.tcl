#Create a simulator object
set ns [new Simulator]

#Define different colors for data flows (for NAM)
$ns color 1 Blue
$ns color 2 Red

#Open the NAM trace file
set namName [lindex $argv 1]
set namfile [open $namName w]
$ns namtrace-all $namfile

set traceName [lindex $argv 2]
set tracefile [open $traceName w]

#Define a 'finish' procedure
proc finish {} {
    global ns namfile tracefile
    $ns flush-trace
    #Close the NAM trace file
    close $namfile
    close $tracefile
    #Execute NAM on the trace file
    # exec nam out/out101.nam &
    exit 0
}

# generate random integer number in the range [0,max]
proc rand {min max} {
    return [expr {$min + int(rand()*(($max-$min)+1))}]
}

# set min and max random delay
set min_delay 5
set max_delay 25

#Create six nodes
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]

#Create links between the nodes
$ns duplex-link $n1 $n3 100Mb 5ms DropTail
$ns duplex-link $n2 $n3 100Mb [rand $min_delay $max_delay]ms DropTail
$ns duplex-link $n3 $n4 0.1Mb 1ms DropTail
$ns duplex-link $n4 $n5 100Mb 5ms DropTail
$ns duplex-link $n4 $n6 100Mb [rand $min_delay $max_delay]ms DropTail

#Set Queue Size of links
$ns queue-limit $n3 $n4 10
$ns queue-limit $n4 $n5 10
$ns queue-limit $n4 $n6 10


#Give node position (for NAM)
$ns duplex-link-op $n1 $n3 orient right-down
$ns duplex-link-op $n2 $n3 orient right-up 
$ns duplex-link-op $n3 $n4 orient right
$ns duplex-link-op $n4 $n5 orient right-up
$ns duplex-link-op $n4 $n6 orient right-down

#Monitor the queue for link (n2-n3). (for NAM)
$ns duplex-link-op $n2 $n3 queuePos 0.5

#Setup a TCP connection:
set tcpNum [lindex $argv 0]
set tcpConType Agent/TCP/Reno
if {$tcpNum == 1} {
    set tcpConType Agent/TCP/Newreno
} elseif {$tcpNum == 2} {
    set tcpConType Agent/TCP
} elseif {$tcpNum == 3} {
    set tcpConType Agent/TCP/Vegas
}
puts $tcpConType
#create tcp source1
set tcp_src1 [new $tcpConType]
$tcp_src1 set ttl_ 64
$tcp_src1 set fid_ 1
$ns attach-agent $n1 $tcp_src1

#create tcp sink1
set tcp_sink1 [new Agent/TCPSink]
$ns attach-agent $n5 $tcp_sink1
$tcp_sink1 set fid_ 1

#connect source to sink
$ns connect $tcp_src1 $tcp_sink1

#create tcp source2
set tcp_src2 [new $tcpConType]
$tcp_src2 set ttl_ 64
$tcp_src2 set fid_ 2
$ns attach-agent $n2 $tcp_src2

#create tcp sink2
set tcp_sink2 [new Agent/TCPSink]
$ns attach-agent $n6 $tcp_sink2
$tcp_sink2 set fid_ 2

#connect source to sink
$ns connect $tcp_src2 $tcp_sink2

# Setup an FTP over both TCP connections 
set ftp_traffic1 [new Application/FTP] 
set ftp_traffic2 [new Application/FTP]
$ftp_traffic1 set type_ FTP 
$ftp_traffic2 set type_ FTP 
$ftp_traffic1 attach-agent $tcp_src1
$ftp_traffic2 attach-agent $tcp_src2

# Detach tcp and sink agents (not really necessary)
# $ns at 4.5 "$ns detach-agent $n0 $tcp ; $ns detach-agent $n3 $sink"

# Let's trace some variables

proc traceVars {outfile} {
global ns tcp_src1 tcp_src2 tcp_sink1 tcp_sink2
set now [$ns now]				        ;# Read current time
set nbytes1 [$tcp_sink1 set bytes_]		;# Read number of bytes
set nbytes2 [$tcp_sink2 set bytes_]		;# Read number of bytes

$tcp_sink1 set bytes_ 0			        ;# Reset for next epoch
$tcp_sink2 set bytes_ 0			        ;# Reset for next epoch


set cwnd1 [$tcp_src1 set cwnd_]
set cwnd2 [$tcp_src2 set cwnd_]

set rtt1 [$tcp_src1 set rtt_]
set rtt2 [$tcp_src2 set rtt_]

set time_incr 0.1

### Prints "TIME throughput" in Mb/sec units to output file
set goodput1 [expr ($nbytes1 * 8.0 / 1000000) / $time_incr]
set goodput2 [expr ($nbytes2 * 8.0 / 1000000) / $time_incr]
puts  $outfile  "$now,$goodput1,$goodput2,$cwnd1,$cwnd2,$rtt1,$rtt2"

### Schedule yourself:
$ns at [expr $now+$time_incr] "traceVars  $outfile"
}

traceVars $tracefile

$ns at 0.0 "$ftp_traffic1 start"
$ns at 0.0 "$ftp_traffic2 start"
$ns at 1000.0 "$ftp_traffic1 stop"
$ns at 1000.0 "$ftp_traffic2 stop"

#Call the finish procedure after 5 seconds of simulation time
$ns at 1000.0 "finish"

#Run the simulation
$ns run