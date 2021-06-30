#!/bin/sh
#set -x
noise=noise.tmp
pil=`echo " 201.pick 202.pick 203.pick 204.pick 205.pick 206.pick 208.pick 209.pick 210.pick 211.pick 212.pick 213.pick 214.pick
216.pick 217.pick 218.pick 219.pick 220.pick 221.pick 222.pick 223.pick 224.pick 225.pick 226.pick
227.pick 228.pick 230.pick "`
####uncertainty limits
Nmin=0.010 ##minimum extra noise
N1max=0.020 #max noise of 1. phase
N2max=0.030 #max noise/uncertainty measure of 2. phase
N3max=0.040  #'---' of 3. phase
N4max=0.050 # '----' of 4. phase
N5max=0.070 # '---' of 5. phase
for i in $pil
do
picks=$i
outfile=noisy.$picks
tmpfile=extranoise.$picks
paste $picks > $tmpfile
##ctaegorising in regard of uncertainties and producing rand numbers within uncertainty range
N1=$(awk -v n=1 -v seed=$RANDOM 'BEGIN { srand(seed); for (i=0; i<n; ++i) printf("%.4f\n", rand()*('$N1max'-'$Nmin')+'$Nmin') }')
echo $N1
N2=$(awk -v n=1 -v seed=$RANDOM 'BEGIN { srand(seed); for (i=0; i<n; ++i) printf("%.4f\n", rand()*('$N2max'-'$Nmin')+'$Nmin') }')
echo $N2
N3=$(awk -v n=1 -v seed=$RANDOM 'BEGIN { srand(seed); for (i=0; i<n; ++i) printf("%.4f\n", rand()*('$N3max'-'$Nmin')+'$Nmin') }')
echo $N3
N4=$(awk -v n=1 -v seed=$RANDOM 'BEGIN { srand(seed); for (i=0; i<n; ++i) printf("%.4f\n", rand()*('$N4max'-'$Nmin')+'$Nmin') }')
echo $N4
N5=$(awk -v n=1 -v seed=$RANDOM 'BEGIN { srand(seed); for (i=0; i<n; ++i) printf("%.4f\n", rand()*('$N5max'-'$Nmin')+'$Nmin') }')
echo $N5
sed -i "/ $N1max/ s/$/ $N1/" $tmpfile
sed -i "/ $N2max/ s/$/ $N2/" $tmpfile
sed -i "/ $N3max/ s/$/ $N3/" $tmpfile
sed -i "/ $N4max/ s/$/ $N4/" $tmpfile
sed -i "/ $N5max/ s/$/ $N5/" $tmpfile
awk '{print $1, $2, ($3+$6), $4, $5}' $tmpfile > $outfile
done
rm $tmpfile
