#!/bin/sh
rays=rays.meanModel-1
grd_mean=tmp5.meanModel-1.grd
cpt=normalMean.cpt
grid_x_max=43.4
ps_file=normalMeanModel.ps 
grdarea=0/$grid_x_max/0/12
plotarea=0/43.0/2/10
scale=-JX18/-6
sources=stations.xz
whitebox=whitebox.dat
gmt gmtset LABEL_OFFSET 0.1i

gmt makecpt -Crainbow -T2.0/8.2/0.1 -V > $cpt

gmt grdmask $rays -R$grdarea -I0.05/0.05 -NNaN/NaN/1 -S0.3 -Gmask.normalaverage.grd
gmt grdmath $grd_mean mask.normalaverage.grd MUL = masked.normalmeanModel-1.grd
gmt grdimage masked.normalmeanModel-1.grd -K -Q -R$plotarea $scale -C$cpt > $ps_file
gmt grdcontour masked.normalmeanModel-1.grd -O -K -R -J -Gd4c -C0.5 -A1 >> $ps_file
gmt psxy $whitebox -R -JX -K -O -Gwhite >> $ps_file
gmt psxy $sources -R -JX -K -O -Si0.25 -G255/255/0 -W1 >> $ps_file
gmt gmtset LABEL_OFFSET -0.7i
gmt psscale -C$cpt -Dx18.5c/0c+w4c/0.5c+e/5/2.5/0.2c -G2/8 -B1:"vp [km/ s]": -O -K >> $ps_file
gmt gmtset LABEL_OFFSET 0.1i
gmt psbasemap -R -J -O -B4f2:"Distance [km]":/10f5:"Depth [km]":WeSn >> $ps_file

gv $ps_file&
gmt psconvert $ps_file -Tf
