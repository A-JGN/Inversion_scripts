#!/bin/sh
#set -x
outfile=new_modell_profile.vz
inputprofile=stoch_modell_profile.vz ##of the form $1== depth nodules and $2== *$Layerindex i.e 0 *1 \n 5 *2 ...
nlayers=3
nmodels=250
smesh=smesh-start.dat
basement=basement.xz

vL1min=2.95
vL1max=3.3
vL2min=5.2                                  
vL2max=5.7
vL3min=7.4
vL3max=7.9
#vL4min=7.9
#vL4max=8.1
for i in $(seq 1 $nmodels)
	do echo initiating modell "$i"
	paste $inputprofile > $outfile."$i" #inititate new vprofiles file
	
	##changing velocity of layer1 of tomographic model,
	vL1=$(awk -v n=1 -v seed=$RANDOM 'BEGIN { srand(seed); for (i=0; i<n; ++i) printf("%.4f\n", rand()*('$vL1max'-'$vL1min')+'$vL1min') }')
	echo 'newvelocity of Layer 1  is '$vL1 'in generated model ' $i
	sed -i "s/*1/$vL1/" $outfile."$i" #replace place holder with semi stochastic velocity
	##changing velocity of layer2, here upper crust
	vL2=$(awk -v n=1 -v seed=$RANDOM 'BEGIN { srand(seed); for (i=0; i<n; ++i) printf("%.4f\n", rand()*('$vL2max'-'$vL2min')+'$vL2min') }')
	echo 'new velocity of Layer 2 is '$vL2 'in generated model ' $i
	sed -i "s/*2/$vL2/" $outfile."$i" #replace place holder with semi stochastic velocity 
	##changing velocity of layer3, here lower crust
	vL3=$(awk -v n=1 -v seed=$RANDOM 'BEGIN { srand(seed); for (i=0; i<n; ++i) printf("%.4f\n", rand()*('$vL3max'-'$vL3min')+'$vL3min') }')
	echo 'new velocity of Layer 3 is '$vL3 'in generated model ' $i
	sed -i "s/*3/$vL3/" $outfile."$i" #replace place holder with semi stochastic velocity 
	###changing velocity of layer4, here mantle
	#vL4=$(awk -v n=1 -v seed=$RANDOM 'BEGIN { srand(seed); for (i=0; i<n; ++i) printf("%.4f\n", rand()*('$vL4max'-'$vL4min')+'$vL4min') }')
	#echo 'new velocity of Layer 4 is '$vL4 'in generated model ' $i
	#sed -i "s/*4/$vL4/" $outfile."$i" #replace place holder with semi stochastic velocity
	
	##edit  base smesh according to the newly created, semi stochastic velocity profiles
	edit_smesh $smesh -CP$outfile."$i" -U$basement > gen_models/$smesh."$i"
	echo 'created smesh' $smesh."$i"
	sleep 13s
done
mv smesh-start.dat.* gen_models/
mv new_modell_profile.vz.* gen_models/VZ_prof/
cd ../
./run_monte_inv $nmodels
#rm $noise."$i"
