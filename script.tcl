#Create a simulator object
set ns [new Simulator]

#Define different colors for data flows (for NAM)
$ns color 1 Blue
$ns color 2 Red

#Open the NAM trace file
set nf [open out.nam w]
$ns namtrace-all $nf

#Define a 'finish' procedure
proc finish {} {
    global ns nf
    $ns flush-trace
    #Close the NAM trace file
    close $nf
    #Execute NAM on the trace file
    exec nam out.nam &
    exit 0
}

# generate random integer number in the range [0,max]
proc rand {min max} {
    return [expr {$min + int(rand()*($max+1))}]
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

# $ns at 0.0 "$n1 label 1"
# $ns at 0.0 "$n2 label 2"
# $ns at 0.0 "$n3 label 3"
# $ns at 0.0 "$n4 label 4"
# $ns at 0.0 "$n5 label 5"
# $ns at 0.0 "$n6 label 6"

#Create links between the nodes
$ns duplex-link $n1 $n3 100Mb 5ms DropTail
$ns duplex-link $n2 $n3 100Mb [rand $min_delay $max_delay]ms DropTail
$ns duplex-link $n3 $n4 0.1Mb 1ms DropTail
$ns duplex-link $n4 $n5 100Mb 5ms DropTail
$ns duplex-link $n4 $n6 100Mb [rand $min_delay $max_delay]ms DropTail

#Set Queue Size of links
$ns queue-limit $n1 $n3 10
$ns queue-limit $n2 $n3 10
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

#Setup a TCP connection
#create tcp source
set tcp_src1 [new Agent/TCP]
$tcp_src1 set fid_ 1
$ns attach-agent $n1 $tcp_src1
#create tcp sink
set tcp_sink1 [new Agent/TCPSink]
$ns attach-agent $n5 $tcp_sink1
$tcp_sink1 set fid_ 1
#connect source to sink
$ns connect $tcp_src1 $tcp_sink1

#Setup a FTP over TCP connection
set ftp [new Application/FTP]
$ftp attach-agent $tcp_src1
$ftp set type_ FTP

$ns at 1.0 "$ftp start"
$ns at 4.0 "$ftp stop"


# #Setup a TCP connection
# set tcp [new Agent/TCP]
# $tcp set class_ 2
# $ns attach-agent $n2 $tcp

# set sink [new Agent/TCPSink]
# $ns attach-agent $n6 $sink
# $ns connect $tcp $sink
# $tcp set fid_ 1


#Detach tcp and sink agents (not really necessary)
# $ns at 4.5 "$ns detach-agent $n0 $tcp ; $ns detach-agent $n3 $sink"

#Call the finish procedure after 5 seconds of simulation time
$ns at 5.0 "finish"

#Print CBR packet size and interval
# puts "CBR packet size = [$cbr set packet_size_]"
# puts "CBR interval = [$cbr set interval_]"

#Run the simulation
$ns run