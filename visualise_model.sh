#!/bin/sh
#set -x
grid=tmp5.harmean-Model-1.grd
istd_grd=std_ini.harmean-Model-1.grd
fstd_grd=std_fin.harmean-Model-1.grd
rays=rays.harmean-Model-1
tt_calc_fin=ttcalc_fin.harmean-Model-1.dat
id=harmean-Model-1
cpt_modell=avmodel_plot.cpt
cpt_std=harmean_std.cpt
icpt_std=harmean_ini_std.cpt
ps_file=harmean-Model-run1_p02.ps
zoffset=7
grid_x_max=43.3
grid_z_max=12
grid_dx=0.05
grid_dz=0.05
grdsize=0/43.4/0/12
sources=stations.xz
whitebox=whitebox.dat
###################

####average model plot######
##################################model cpt#########
#gmt makecpt -Ccubhelix -I -T2.0/8.2/0.1 -V > $cpt_modell
plotarea=0/$grid_x_max/2/10
gmt gmtset LABEL_OFFSET 0.1i

###################################actual model############
######################################################mask model###
gmt grdmask $rays -R$grdsize -I0.05/0.05 -NNaN/NaN/1 -S0.3 -Gmask.$id
gmt grdmath $grid mask.$id MUL = masked_model.grd
gmt grdimage masked_model.grd -R$plotarea -JX17/-5 -C$cpt_modell -K -V -B4f2:"Distance [km]":/2f1:"Depth [km]":WeSn > $ps_file
gmt psxy ../seafloor.xz -R -JX -O -K -W1 >>$ps_file
gmt grdcontour masked_model.grd -O -K -R -J -Gd4c -C0.5 -A1 -S -V >> $ps_file
gmt psxy $whitebox -R -JX -K -O -Gwhite >> $ps_file
gmt psxy $sources -R -JX -K -O -Si0.25 -G255/255/0 -W1 >> $ps_file
gmt gmtset LABEL_OFFSET -0.6i
gmt psscale -C$cpt_modell -Dx11.5c/1c+w4c/0.25c+h+e -G2/8 -B1:"vp [km/ s]": -O -K >> $ps_file
gmt gmtset LABEL_OFFSET 0.1i
gmt psbasemap -R -J -O -B4f2:"Distance [km]":/10f5:"Depth [km]":WeSn -K >> $ps_file


####std harmonic mean plot###################
gmt makecpt -Csealand -T0/1.0/0.001 -V >$icpt_std
gmt gmtset LABEL_OFFSET 0.1i

#####################################plot std distribution#################
gmt grdmath $istd_grd ABS = $istd_grd
gmt grdmath $istd_grd mask.$id MUL = masked_istd.grd
gmt grdimage masked_istd.grd -R$plotarea -JX17/-5 -C$icpt_std -K -V -B4f2:"Distance [km]":/2f1:"Depth [km]":WeSn -O -Y$zoffset >> $ps_file
gmt psxy ../seafloor.xz -R -JX -O -K -W1 >>$ps_file
gmt grdcontour masked_istd.grd -O -K -R -J -Gd4c -C0.2 -A0.2 -S -V >> $ps_file
gmt psxy $whitebox -R -JX -K -O -Gwhite >> $ps_file
gmt psxy $sources -R -JX -K -O -Si0.25 -G255/255/0 -W1 >> $ps_file
gmt gmtset LABEL_OFFSET -0.6i
gmt psscale -C$icpt_std -Dx11.5c/1c+w4c/0.25c+h+e -B0.25:"std [km/ s]": -O -K >> $ps_file
gmt gmtset LABEL_OFFSET 0.1i
gmt psbasemap -R -J -O -B4f2:"Distance [km]":/10f5:"Depth [km]":WeSn -K >> $ps_file

#####################################plot std distribution final#################
#gmt makecpt -Csealand -T0/0.6/0.001 -V >$cpt_std
gmt gmtset LABEL_OFFSET 0.1i

gmt grdmath $fstd_grd ABS = $fstd_grd
gmt grdmath $fstd_grd mask.$id MUL = masked_fstd.grd
gmt grdimage masked_fstd.grd -R$plotarea -JX17/-5 -C$cpt_std -K -V -B4f2:"Distance [km]":/2f1:"Depth [km]":WeSn -O -Y$zoffset >> $ps_file
gmt psxy ../seafloor.xz -R -JX -O -K -W1 >>$ps_file
gmt grdcontour masked_fstd.grd -O -K -R -J -Gd4c -C0.1 -A0.1 -S -V >> $ps_file
gmt psxy $whitebox -R -JX -K -O -Gwhite >> $ps_file
gmt psxy $sources -R -JX -K -O -Si0.25 -G255/255/0 -W1 >> $ps_file
gmt gmtset LABEL_OFFSET -0.6i
gmt psscale -C$cpt_std -Dx11.5c/1c+w4c/0.25c+h+e -B0.25:"std [km/ s]": -O -K >> $ps_file
gmt gmtset LABEL_OFFSET 0.1i
gmt psbasemap -R -J -O -B4f2:"Distance [km]":/10f5:"Depth [km]":WeSn >> $ps_file

gv $ps_file&
gmt psconvert $ps_file -Tf

