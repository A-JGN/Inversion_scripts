#!/bin/sh
#set -x
###November 2019 by Anna Jegen
## change velocity nodes of a given v.in and leave depth nodes as they are. To sample the solution space
## velocity models have to be 1d--> only 2 velocoty nodes one at x=0 and one at x=X_max
vin_list=MII_vin_list
rm $vin_list
nmodels=5 ##new 
mmodels=5
lmodels=8 ##number of distinct depth node distributions (v.ins)
vins=(D1v.in D2v.in D3v.in D4v.in D5v.in D6v.in D7v.in D8v.in)
delta_d=100
L1new_vtop=(2.01 3.11 2.61 2.51 2.95)  ##velocities used at top boundary of layer1
L2new_vtop=(6.61 4.55 6.0 5.45 5.81)  ##velocities used at top boundary of layer2
L2new_vbot=(7.11 7.11 7.11 7.11 7.11) ##velocities used at bottom boundary of layer2
X_max=185.00 ##extent of profile in x
n1layer=3 ### layer ID of layer1
n2layer=4 ### layer IB#D of layer 2
idx=1

tbfile=tmp
modelfile=v.in
dfile=deletefile.tmp
dfile2=deletefile2.tmp
rm vin_list
  m=$(( $mmodels - 1 ))
  n=$(( $nmodels - 1 ))
  l=$(( $lmodels - 1 ))
for i in $(seq 0 $l)
   do
   input=${vins[$l]}
   echo 'velocity file is ' ${vins[$l]}
   echo 'velocity file is ' $input
   ##Determin rows (top and end) where velocity nodes are defined 
   sed -n "/$n1layer    0.00 $X_max/=" $input >$tbfile
   top_vn=$(awk 'NR == 1 { print ($1)}' $tbfile)
   bottom_vn=$(awk 'NR == 2 { print $1+2}' $tbfile)
   echo '##top row of layers velocity information= '"$top_vn ##"
   echo '##bottom row of velocity information= '"$bottom_vn m##"

   ##Determin rows (top and end) where velocity nodes are defined of the 2. layer 
   sed -n "/$n2layer    0.00 $X_max/=" $input >>$tbfile
   L2top_vn=$(awk 'NR == 3 { print ($1)}' $tbfile)
   L2bottom_vn=$(awk 'NR == 4 { print $1+2}' $tbfile)
   echo '##' "$n2layer"'. Layer:top row of velocity information= '"$L2top_vn ##"
   echo '##' "$n2layer"'. Layer: bottom row of velocity information= '"$L2bottom_vn m##"
   ##stepwise creation of new model changing the velocities of given layers
   
     for i in $(seq 0 $n)
     do 
     nvtop_c=${L1new_vtop[$i]}
     nvbot_c=${L2new_vtop[$i]}
     echo 'model' $idx': velocities of layer' $n1layer' changed to' $nvtop_c'-'$nvbot_c 'km/s'
     ##copy some unchanged parts of old model (depth nodes) and determine region in v.in that needs change
     sed -n "1,$top_vn p" $input > $modelfile 
     c_top=$(( $top_vn + 1)) ##copy boundaries to avoid doubling rows
     c_bot=$(( $bottom_vn + 1))
     sed -n "$c_top, $bottom_vn p" $input | awk 'NR==1{$2=$3='$nvtop_c'} {print}' | awk 'NR==4{$2=$3='$nvbot_c'} {print}'  | cat >> $modelfile
     sed -n "$c_bot,$ p" $input | cat >> $modelfile
	
	 for j in $(seq 0 $m)
	    do
	    nvtop_c=${L2new_vtop[$i]}
	    nvbot_c=${L2new_vbot[$j]}
	    echo 'model' $idx': velocities of layer' $n2layer' changed to' $nvtop_c'-'$nvbot_c 'km/s'
	    ##copy some unchanged parts of old model (depth nodes) and determine region in v.in that needs change
            sed -n "1,$L2top_vn p" $modelfile > $dfile 
            c_top=$(( $L2top_vn + 1)) ##copy boundaries to avoid doubling rows
            c_bot=$(( $L2bottom_vn + 1))
            sed -n "$c_top, $L2bottom_vn p" $modelfile | awk 'NR==1{$2=$3='$nvtop_c'} {print}' | awk 'NR==4{$2=$3='$nvbot_c'} {print}'  | cat >> $dfile
            sed -n "$c_bot,$ p" $modelfile | cat >> $dfile
	    
	    mv $dfile MII"$idx"_$modelfile
	    echo 'just wrote model ' $idx
	    echo MII"$idx"_$modelfile log_all.MII"$idx" >> $vin_list
	    idx=$(( $idx + 1 ))
	    done
     done
   done
./run_multp_models.sh $idx 	
	
	

	exit
