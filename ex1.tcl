
set arg [lindex $argv 0]
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            CMUPriQueue 		   ; #Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             $arg                        ;# number of mobilenodes
set val(rp)             DSR                       ;# routing protocol dsdv or dsr

#set val(cp)             /home/brijesh/wireless/gap/cbr-3-test           ;       #"../mobility/scene/cbr-3-test" 
set val(sc)             /home/brijesh/wireless/Testing/mob10_750_0-30       ;       #"../mobility/scene/scen-3-test" 




# ======================================================================
# Main Program
# ======================================================================


#
# Initialize Global Variables
#
set ns_		[new Simulator]

$ns_ use-newtrace

set tracefd     [open ex1.tr w]
$ns_ trace-all $tracefd

# set up topography object
set topo       [new Topography]

$topo load_flatgrid 750 750

# For network animation
set namtrace    [open ex1.nam w]
$ns_ namtrace-all-wireless $namtrace 750 750

#
# Create God
#
set god_ [create-god $val(nn)]

#
#  Create the specified number of mobilenodes [$val(nn)] and "attach" them
#  to the channel. 
#  Here two nodes are created : node(0) and node(1)

# configure node

        $ns_ node-config -adhocRouting $val(rp) \
			 -llType $val(ll) \
			 -macType $val(mac) \
			 -ifqType $val(ifq) \
			 -ifqLen $val(ifqlen) \
			 -antType $val(ant) \
			 -propType $val(prop) \
			 -phyType $val(netif) \
			 -channelType $val(chan) \
			 -topoInstance $topo \
			 -agentTrace ON \
			 -routerTrace ON \
			 -macTrace OFF \
			 -movementTrace OFF			
			 
	
	
#===================Creating nodes=======================	
	for {set i 0} {$i < $val(nn) } {incr i} {
		set node_($i) [$ns_ node]	
		$node_($i) random-motion 0		;# disable random motion
	}
#=====================done================================
#set rng [new RNG]
#$rng seed next-substream

#for {set i 0} {$i < $val(nn)} {incr i} {
 #   set n($i) [$ns_ node]
  #  $n($i) set X_ [$rng uniform 0.0 500.0]
   # $n($i) set Y_ [$rng uniform 0.0 500.0]
    #$n($i) set Z_ 0.0 
    #$ns_ initial_node_pos $n($i) 20


#
# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
#
#set max 100
#set min 50
#set r [new RandomVariable/Normal]
#$r set max_ $max
#$r set min_ $min
#==========================Randomization=========================

#for {set i 0} {$i < $val(nn)} {incr i} {
#	set value1 [expr int(rand()*50+rand()*100+rand()*25)]
#	set value2 [expr int(rand()*50+rand()*100+rand()*25)]	
#	$node_($i) set X_ $value1
#	$node_($i) set Y_ $value2
#	$node_($i) set Z_ 0.0
#}

# another method

set unif [new RandomVariable/Uniform]
$unif set min_ 0.0
$unif set max_ 750.0

#for {set i 0} {$i < $val(nn) } {incr i} {
#set node_($i) [$ns_ node]	
#	$node_($i) random-motion 0		;# disable random motion
#	set value1 [$unif value]
#	set value2 [$unif value]
#	$node_($i) set X_ $value1
#	$node_($i) set Y_ $value2
#	$node_($i) set Z_ 0.0
#}

#==============================done=================================
#set value1 [expr int(rand()*100)+100]
#set value2 [expr int(rand()*200)+50]
#$node_(0) set X_ $value1
#$node_(0) set Y_ $value2
#$node_(0) set Z_ 0.0

#
# Now produce some simple node movements
# Node_(1) starts to move towards node_(0)
#
#$ns_ at 50.0 "$node_(1) setdest 70.0 30.0 15.0"
#$ns_ at 10.0 "$node_(0) setdest 20.0 18.0 1.0"
#$ns_ at 50.0 "$node_(2) setdest 100.0 30.0 15.0"
#$ns_ at 50.0 "$node_(3) setdest 56.0 67.0 15.0"
# Node_(1) then starts to move away from node_(0)
#$ns_ at 100.0 "$node_(1) setdest 90.0 80.0 15.0" 


source $val(sc)




# Setup traffic flow between nodes

# TCP connections between node_(0) and node_(1)
for {set i 0} {$i < $val(nn)} {incr i} {
set udp_($i) [new Agent/UDP]
$ns_ attach-agent $node_($i) $udp_($i)
incr i
set Null_($i) [new Agent/Null]
$ns_ attach-agent $node_($i) $Null_($i)
#$ns_ connect $udp_($i) $Null_($j)
}

for {set i 0} {$i< $val(nn)} {incr i} {
set j [expr {$i+1}]
$ns_ connect $udp_($i) $Null_($j)
incr i
}


for {set i 0} {$i < $val(nn)} {incr i} {
set cbr_($i) [new Application/Traffic/CBR]
$cbr_($i) set packetSize_ 512 
$cbr_($i) set rate_ 600Kb
$cbr_($i) attach-agent $udp_($i)
$ns_ at 4.0 "$cbr_($i) start"
incr i
}


# defines the node size in nam
for {set i 0} {$i < $val(nn)} {incr i} {
	$ns_ initial_node_pos $node_($i) 1
}

#
# Tell nodes when the simulation ends
#
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at 150.0 "$node_($i) reset";
}
$ns_ at 150.0 "stop"
$ns_ at 150.01 "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd namtrace
    $ns_ flush-trace
    close $tracefd
    close $namtrace
    exec nam ex1.nam &
    exit 0
}

puts "Starting Simulation..."
$ns_ run
