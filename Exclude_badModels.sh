Iteration=$2
headersize=8
nmodels=$1
smeshList=smeshList.dat
Loglist=LogfileList.dat
iModelList=IniModelList.dat
max_chi=2.5
rm $smeshList
rm $Loglist
rm $iModelList
if [ $nmodels -lt 9 ]
then
	for i in $(seq $nmodels)
	do 
	   logfile=logfiles/log_all.m0$i
	   chi=$(awk 'NR == (('$Iteration' + '$headersize')) {print $5}' $logfile)
	   if [ 1 -eq "$(echo "${chi} < ${max_chi}" | bc)" ]
	   then
	   echo 'out_m0'"$i"'.smesh.5.1' >> $smeshList
	   echo 'log_all.m0'$i >> $Loglist
	   echo 'smesh-start.dat'.$i >> $iModelList
	   fi
	done
	   
elif [[ $nmodels -gt 9  && $nmodels -lt 99 ]]
then
	for i in $(seq 9)
	do
	   logfile=logfiles/log_all.m0$i
	   chi=$(awk 'NR == (('$Iteration' + '$headersize')) {print $5}' $logfile)
	   if [ 1 -eq "$(echo "${chi} < ${max_chi}" | bc)" ]
	   then
	   echo 'out_m0'"$i"'.smesh.5.1' >> $smeshList
	   echo 'log_all.m0'$i >> $Loglist
	   echo 'smesh-start.dat'.$i >> $iModelList
	   fi
	done
	
	for i in $(seq 10 $nmodels)
	do
	   logfile=logfiles/log_all.m$i
	   chi=$(awk 'NR == (('$Iteration' + '$headersize')) {print $5}' $logfile)
	   if [ 1 -eq "$(echo "${chi} < ${max_chi}" | bc)" ]
	   then
	   echo 'out_m'"$i"'.smesh.5.1' >> $smeshList
	   echo 'log_all.m'$i >> $Loglist
	   echo 'smesh-start.dat'.$i >> $iModelList
	   fi
	done
elif [ $nmodels -gt 99 ]
then
	for i in $(seq 9)
	do 
	   logfile=logfiles/log_all.m00$i
	   chi=$(awk 'NR == (('$Iteration' + '$headersize')) {print $5}' $logfile)
	   if [ 1 -eq "$(echo "${chi} < ${max_chi}" | bc)" ]
	   then
	   echo 'out_m00'"$i"'.smesh.5.1' >> $smeshList
	   echo 'log_all.m00'$i >> $Loglist
	   echo 'smesh-start.dat'.$i >> $iModelList
	   fi
	done
	
	for i in $(seq 10 99)
	do
	   logfile=logfiles/log_all.m0$i
	   chi=$(awk 'NR == (('$Iteration' + '$headersize')) {print $5}' $logfile)
	   if [ 1 -eq "$(echo "${chi} < ${max_chi}" | bc)" ]
	   then
	   echo 'out_m0'"$i"'.smesh.5.1' >> $smeshList
	   echo 'log_all.m0'$i >> $Loglist
	   echo 'smesh-start.dat'.$i >> $iModelList
	   fi
	done
	
	for i in $(seq 100 $nmodels)
	do
           logfile=logfiles/log_all.m$i
	   chi=$(awk 'NR == (('$Iteration' + '$headersize')) {print $5}' $logfile)
	   if [ 1 -eq "$(echo "${chi} < ${max_chi}" | bc)" ]
	   then
	   echo 'out_m'"$i"'.smesh.5.1' >> $smeshList
	   echo 'log_all.m'$i >> $Loglist
	   echo 'smesh-start.dat'.$i >> $iModelList
	   fi
	done
	
fi
