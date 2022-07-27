#!/bin/sh
#set -x
logList=Mean-model-run-1/LogfileList.dat
smeshList=Mean-model-run-1/smeshList.dat
megaList=harmonic_mean/List_log_smeshs.dat
headersize=8
Iteration=3

id=harmean-Model-1
wifile=weights.dat
ref_smesh=harmonic_mean/smesh-start.dat
seafloor=seafloor.xz
wi_smesh=weighted_smesh.tmp
sum_v_values=sum_weighted_smeshs.dat
harmean_smesh=harmonic_mean/harmean_average_smesh.dat
model_path=Mean-model-run-1
iModelList=IniModelList.dat

harmean_path=harmonic_mean
##grid params
x_max=43.4
z_max=12
dx=0.05

rm $harmean_smesh
###initiate sum_v_values with zeros
edit_smesh $ref_smesh -Cm0.0/seafloor.xz >tmp0
awk 'NR>4 {print $0}' tmp0 >$sum_v_values
###determine nu,ber of depth nodes:
N_znodes=$(awk '{if (NR==4) print NF}' $ref_smesh)

##geometrie of smeshes is already copied to final smesh file
awk 'NR<=4 {print $0}' $ref_smesh >$harmean_smesh

##combine both lists in order to loop over them simultaneously
paste $smeshList $logList > $megaList

### determine weighting factor:
IFS=$'\n'
set -f
for j in $(cat <$megaList);
do
	echo $j>tmp
	logfile=$(awk '{print $2}' tmp)
	smeshfile=$(awk '{print $1}' tmp)
	##calc RMS weight of current inversion run
	w=$(awk 'NR == (('$Iteration' + '$headersize')) {print 1/$4}' $model_path/logfiles/$logfile)
	echo '******************************'$w
	###create wi/weight smesh
	edit_smesh $ref_smesh -Cm$w/$seafloor >$wi_smesh
	
	## calculate wi/final vel. smesh, beware geometrie rows (1-4) not copied, but added to file later
	awk 'NR>4 {print '$w'/$1,'$w'/$2, '$w'/$3, '$w'/$4, '$w'/$5, '$w'/$6, '$w'/$7, '$w'/$8, '$w'/$9, '$w'/$10, '$w'/$11, '$w'/$12}' $model_path/$smeshfile >velocity-values.dat
	###add current wi/smesh to rolling sum:
	paste $sum_v_values velocity-values.dat >tmp1
	awk '{print $1+$(1+'$N_znodes'), $2+$(2+'$N_znodes'), $3+$(3+'$N_znodes'), $4+$(4+'$N_znodes'), $5+$(5+'$N_znodes'), $6+$(6+'$N_znodes'), $7+$(7+'$N_znodes'), $8+$(8+'$N_znodes'), $9+$(9+'$N_znodes'), $10+$(10+'$N_znodes'), $11+$(11+'$N_znodes'), $12+$(12+'$N_znodes')}' tmp1 > $sum_v_values
	 echo $w>> $wifile
done

 
###Calculate the sum of all weights
sum_w=$(awk '{s+=$1} END {print s}' $wifile)
	 echo 'sum of weights = '$sum_w
	 
#awk '{print '$sum_w'/$0}' $sum_v_values >> $harmean_smesh
awk 'NR>4 {print '$sum_w'/$1,'$sum_w'/$2, '$sum_w'/$3, '$sum_w'/$4, '$sum_w'/$5, '$sum_w'/$6, '$sum_w'/$7, '$sum_w'/$8, '$sum_w'/$9, '$sum_w'/$10, '$sum_w'/$11, '$sum_w'/$12}' $sum_v_values >> $harmean_smesh

rm $wifile

rm tmp
rm tmp0
rm tmp1
rm weighted_smesh.tmp
cp $smeshList $harmean_path/
cd $harmean_path/

tt_forward -Mharmean_average_smesh.dat -V0 -Gtt.dat -N5/10/1/8/1e-4/1e-5 -Rrays.$id -Itmp_$id.v5 >ttcalc_fin.$id.dat
cd ../Mean-model-run-1/
stat_smesh -L$iModelList -Cr../$harmean_path/harmean_average_smesh.dat -V >../$harmean_path/std_smesh_ini.$id.dat
stat_smesh -LsmeshList.dat -Cr../$harmean_path/harmean_average_smesh.dat -V >../$harmean_path/std_smesh_fin.$id.dat
cd ../$harmean_path/
tt_forward -Mstd_smesh_ini.$id.dat -V0 -Gtt.dat -N5/10/1/8/1e-4/1e-5 -Rrays.std.$id -Istd_$id.v1 >ttcalc_std_ini.$id.dat
tt_forward -Mstd_smesh_fin.$id.dat -V0 -Gtt.dat -N5/10/1/8/1e-4/1e-5 -Rrays.std.$id -Istd_$id.v5 >ttcalc_std_fin.$id.dat

./togrid.sh tmp_$id.v5 0 $x_max 0 $z_max $dx $dx tmp5.$id.grd
./togrid.sh std_$id.v1 0 $x_max 0 $z_max $dx $dx std_ini.$id.grd
./togrid.sh std_$id.v5 0 $x_max 0 $z_max $dx $dx std_fin.$id.grd
./visualise_model.sh

####geometrie does not change during inversion
