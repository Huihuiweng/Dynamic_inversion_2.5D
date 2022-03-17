#!/bin/bash
gmtset PS_MEDIA a1

Forward_path="/u/moana/user/weng/Weng/2.5D_dynamic_inversion/forward/scripts/data/"

model=sine5
ave_len=0.2
ite1=11
ite2=12

#########################################
###  Model input
#########################################
psbasemap -R0/100/0/6 -JX4i/2i -B50f10/2f1:."Tau (MPa)":WSne  -K -Y30i -P > ps/compare-models.eps
gawk '{print $1,$2/1e6}' ${Forward_path}/${model}-input.dat | psxy -R -J -O -K -Wthickest -P >> ps/compare-models.eps
gawk '{print $1,$2/1e6}' data/${model}-${ave_len}-${ite1}-input_record.dat | psxy -R -J -O -K -Wthickest,blue -P >> ps/compare-models.eps
gawk '{print $1,$2/1e6}' data/${model}-${ave_len}-${ite2}-input_record.dat | psxy -R -J -O -K -Wthickest,red -P >> ps/compare-models.eps

psbasemap -R0/100/0/4 -JX4i/2i -B50f10/2f1:."Gc (MPa m)":WSne  -O -K -X5.5i -P >> ps/compare-models.eps
gawk '{print $1,$3/1e6}' ${Forward_path}/${model}-input.dat | psxy -R -J -O -K -Wthickest -P >> ps/compare-models.eps
gawk '{print $1,$3/1e6}' data/${model}-${ave_len}-${ite1}-input_record.dat | psxy -R -J -O -K -Wthickest,blue -P >> ps/compare-models.eps
gawk '{print $1,$3/1e6}' data/${model}-${ave_len}-${ite2}-input_record.dat | psxy -R -J -O -K -Wthickest,red -P >> ps/compare-models.eps

psbasemap -R0/100/0.2/1.8 -JX4i/2i -B50f10/0.2f0.1:."Gc/G0 (guess)":WSne  -O -K -X5.5i -P >> ps/compare-models.eps
gawk '{print $1,$4}' ${Forward_path}/${model}-input.dat | psxy -R -J -O -K -Wthickest -P >> ps/compare-models.eps
gawk '{print $1,$4}' data/${model}-${ave_len}-${ite1}-input_record.dat | psxy -R -J -O -K -Wthickest,blue -P >> ps/compare-models.eps
gawk '{print $1,$4}' data/${model}-${ave_len}-${ite2}-input_record.dat | psxy -R -J -O -K -Wthickest,red -P >> ps/compare-models.eps

psbasemap -R0/100/-0.2/0.2 -JX4i/2i -B50f10/0.1f0.02g0.02:."Delta Gc/G0":WSne  -O -K -X5.5i -P >> ps/compare-models.eps
gawk 'BEGIN{print 0,0,"\n",100,0}' | psxy -R -J -O -K -Wthin -P >> ps/compare-models.eps

#########################################
###  simulation output
#########################################
psbasemap -R0/100/0.0/1.0 -JX4i/2i -B50f10/0.2f0.1:."vr/vs":WSne -O -K -X-16.5i -Y-3i -P >> ps/compare-models.eps
gawk '{print $1,$3/3330.0}' ${Forward_path}/${model}-along_strike_values.dat | psxy -R -J -O -K -Wthickest -P >> ps/compare-models.eps
gawk '{print $1,$3/3330.0}' data/${model}-${ave_len}-${ite1}-along_strike_values.dat | psxy -R -J -O -K -Wthickest,blue -P >> ps/compare-models.eps
gawk '{print $1,$3/3330.0}' data/${model}-${ave_len}-${ite2}-along_strike_values.dat | psxy -R -J -O -K -Wthickest,red -P >> ps/compare-models.eps

psbasemap -R0/100/0/2.0 -JX4i/2i -B50f10/0.2f0.2:."vr/vs (STF inverted)":WSne -O  -K -X5.5i -P >> ps/compare-models.eps
gawk '{print $1,$5/3330.0}' data/${model}-${ave_len}-1-input_record.dat | psxy -R -J -O -K -W3p -P >> ps/compare-models.eps
gawk '{print $1,$5/3330.0}' data/${model}-${ave_len}-${ite1}-input_record.dat | psxy -R -J -O -K -Wthickest,blue -P >> ps/compare-models.eps
gawk '{print $1,$5/3330.0}' data/${model}-${ave_len}-${ite2}-input_record.dat | psxy -R -J -O -K -Wthickest,red  -P >> ps/compare-models.eps

psbasemap -R0/120/0/1e19 -JX4i/2i -B50f10/1e19f1e18:."STF":WSne  -O -K -X5.5i -P >> ps/compare-models.eps
gawk '{print $1,$2*20e3*30e9}' ${Forward_path}/${model}-STF.dat | psxy -R -J -O -K -Wthickest -P >> ps/compare-models.eps
gawk '{print $1,$2*20e3*30e9}' data/${model}-${ave_len}-${ite1}-STF.dat | psxy -R -J -O -K -Wthickest,blue -P >> ps/compare-models.eps
gawk '{print $1,$2*20e3*30e9}' data/${model}-${ave_len}-${ite2}-STF.dat | psxy -R -J -O -K -Wthickest,red -P >> ps/compare-models.eps

psbasemap -R0/100/0/100 -JX4i/2i -B50f10/20f10:."Rupture time (s)":WSne -O  -K -X5.5i -P >> ps/compare-models.eps
gawk '{print $1,$2}' ${Forward_path}/${model}-along_strike_values.dat | psxy -R -J -O -K -Wthickest -P >> ps/compare-models.eps
gawk '{print $1,$2}' data/${model}-${ave_len}-${ite1}-along_strike_values.dat | psxy -R -J -O -K -Wthickest,blue -P >> ps/compare-models.eps
gawk '{print $1,$2}' data/${model}-${ave_len}-${ite2}-along_strike_values.dat | psxy -R -J -O -K -Wthickest,red -P >> ps/compare-models.eps

#########################################
### 
#########################################
psbasemap -R0/100/0/3 -JX4i/2i -B50f10/1f1:."Slip (m)":WSne  -O -K -X-16.5i -Y-3i -P >> ps/compare-models.eps
gawk '{print $1,$5}' ${Forward_path}/${model}-along_strike_values.dat | psxy -R -J -O -K -Wthickest -P >> ps/compare-models.eps
gawk '{print $1,$5}' data/${model}-${ave_len}-${ite1}-along_strike_values.dat | psxy -R -J -O -K -Wthickest,blue -P >> ps/compare-models.eps
gawk '{print $1,$5}' data/${model}-${ave_len}-${ite1}-along_strike_values.dat | psxy -R -J -O -K -Wthickest,red -P >> ps/compare-models.eps

psbasemap -R0/100/0/5 -JX4i/2i -B50f10/2f1:."Tau (MPa)":WSne  -O -K -X5.5i -P >> ps/compare-models.eps
gawk '{print $1,$6/1e6}' ${Forward_path}/${model}-along_strike_values.dat | psxy -R -J -O -K -Wthickest -P >> ps/compare-models.eps
gawk '{print $1,$6/1e6}' data/${model}-${ave_len}-${ite1}-along_strike_values.dat | psxy -R -J -O -K -Wthickest,blue -P >> ps/compare-models.eps
gawk '{print $1,$6/1e6}' data/${model}-${ave_len}-${ite2}-along_strike_values.dat | psxy -R -J -O -K -Wthickest,red -P >> ps/compare-models.eps

psbasemap -R0/100/0/4 -JX4i/2i -B50f10/2f1:."G0 (MPa m)":WSne  -O -K -X5.5i -P >> ps/compare-models.eps
gawk '{print $1,$7/1e6}' ${Forward_path}/${model}-along_strike_values.dat | psxy -R -J -O -K -Wthickest -P >> ps/compare-models.eps
gawk '{print $1,$7/1e6}' data/${model}-${ave_len}-${ite1}-along_strike_values.dat | psxy -R -J -O -K -Wthickest,blue -P >> ps/compare-models.eps
gawk '{print $1,$7/1e6}' data/${model}-${ave_len}-${ite2}-along_strike_values.dat | psxy -R -J -O -K -Wthickest,red -P >> ps/compare-models.eps

psbasemap -R0/100/0/5 -JX4i/2i -B50f10/2f1:."Gc (MPa m)":WSne  -O -K -X5.5i -P >> ps/compare-models.eps
gawk '{print $1,$8/1e6}' ${Forward_path}/${model}-along_strike_values.dat | psxy -R -J -O -K -Wthickest -P >> ps/compare-models.eps
gawk '{print $1,$8/1e6}' data/${model}-${ave_len}-${ite1}-along_strike_values.dat | psxy -R -J -O -K -Wthickest,blue -P >> ps/compare-models.eps
gawk '{print $1,$8/1e6}' data/${model}-${ave_len}-${ite2}-along_strike_values.dat | psxy -R -J -O -K -Wthickest,red -P >> ps/compare-models.eps

##########################################
####
##########################################
#psbasemap -R0/${iteration}/0/1 -JX4i/2i -B5f1/2f1:."Misfit of STF":WSne  -O -K -X-16.5i -Y-3i -P >> ps/compare-models.eps
#gawk '{if($1>=0.0 && $1<100) print $1,$2}' ${Forward_path}/${model}-STF.dat > data/original_STF.dat
#N_obs=`gawk 'BEGIN{sum=0.0;num=0.0}{sum=sum+($2-0)**2;num=num+1}END{print sum**0.5}' data/original_STF.dat`
#for ite in `seq ${iteration}`
#do
#gawk '{if($1>=0.0 && $1<100) print $1,$2}' data/${model}-${ave_len}-${ite}-STF.dat > data/ite_STF.dat
#paste data/original_STF.dat data/ite_STF.dat | gawk 'BEGIN{sum=0.0;num=0.0}{sum=sum+($2-$4)**2;num=num+1}END{print '"${ite}"',sum**0.5/'"$N_obs"'}' | psxy -R -J -O -K -Sc0.08i -Gred -P >> ps/compare-models.eps
#done
#
#psbasemap -R0/${iteration}/0.001/1 -JX4i/2il -B5f1/2f1:."Misfit of Slip":WSne  -O -K -X5.5i -P >> ps/compare-models.eps
#gawk '{if($1>=0.0 && $1<100) print $1,$5}' ${Forward_path}/${model}-along_strike_values.dat > data/original_slip.dat
#N_obs=`gawk 'BEGIN{sum=0.0;num=0.0}{sum=sum+($2-0)**2;num=num+1}END{print sum**0.5}' data/original_slip.dat`
#for ite in `seq ${iteration}`
#do
#gawk '{if($1>=0.0 && $1<100) print $1,$5}' data/${model}-${ave_len}-${ite}-along_strike_values.dat > data/ite_slip.dat
#paste data/original_slip.dat data/ite_slip.dat | gawk 'BEGIN{sum=0.0;num=0.0}{sum=sum+($2-$4)**2;num=num+1}END{print '"${ite}"',sum**0.5/'"$N_obs"'}' | psxy -R -J -O -K -Sc0.08i -Gred -P >> ps/compare-models.eps
#done
#
#psbasemap -R0/${iteration}/0/0.5 -JX4i/2i -B5f1/0.5f0.1:."Misfit of vr (inverted)":WSne  -O -K -X5.5i -P >> ps/compare-models.eps
#for ite in `seq ${iteration}`
#do
#if [ $ite = 1 ] ; then
#continue
#fi
#gawk '{if($1>=0.0 && $1<100) print $1,$5/3330.0}' data/${model}-${ave_len}-1-input_record.dat > data/original_vr.dat
#gawk '{if($1>=0.0 && $1<100) print $1,$5/3330.0}' data/${model}-${ave_len}-${ite}-input_record.dat > data/ite_vr.dat
#paste data/original_vr.dat data/ite_vr.dat | gawk 'BEGIN{sum=0.0;num=0.0}{sum=sum+($2-$4)**2;num=num+1}END{print '"${ite}"',(sum/num)**0.5}' | psxy -R -J -O -K -Sc0.08i -Gred -P >> ps/compare-models.eps
#done
#
#psbasemap -R0/${iteration}/0/0.5 -JX4i/2i -B5f1/0.5f0.1:."Misfit of vr":WSne  -O -K -X5.5i -P >> ps/compare-models.eps
#for ite in `seq ${iteration}`
#do
#gawk '{if($1>=0.0 && $1<100) print $1,$3/3330.0}' ${Forward_path}/${model}-along_strike_values.dat > data/original_vr.dat
#gawk '{if($1>=0.0 && $1<100) print $1,$3/3330.0}' data/${model}-${ave_len}-${ite}-along_strike_values.dat > data/ite_vr.dat
#paste data/original_vr.dat data/ite_vr.dat | gawk 'BEGIN{sum=0.0;num=0.0}{sum=sum+($2-$4)**2;num=num+1}END{print '"${ite}"',sum**0.5}' | psxy -R -J -O -K -Sc0.08i -Gred -P >> ps/compare-models.eps
#done
#
#
##########################################
####
##########################################
#psbasemap -R0/${iteration}/-4/0.1 -JX4i/16i -B50f10/0.1f0.1g0.1:."Delta Gc/G0":Wsne  -O -K -X-16.5i -Y-17i -P >> ps/compare-models.eps
#for ite in `seq ${iteration}`
#do
#if [ $ite = 1 ] ; then
#continue
#fi
#com1=$((ite-1))
#paste data/${model}-${ave_len}-${ite}-input_record.dat data/${model}-${ave_len}-${com1}-input_record.dat > data/temp.dat 
#gawk '{if($1==22.0) print '"$ite"',$4-$9-0.0}' data/temp.dat | psxy -R -J -O -K -Sc0.08i -Gred -P >> ps/compare-models.eps
#gawk '{if($1==26.0) print '"$ite"',$4-$9-0.2}' data/temp.dat | psxy -R -J -O -K -Sc0.08i -Gred -P >> ps/compare-models.eps
#gawk '{if($1==30.0) print '"$ite"',$4-$9-0.4}' data/temp.dat | psxy -R -J -O -K -Sc0.08i -Gred -P >> ps/compare-models.eps
#gawk '{if($1==34.0) print '"$ite"',$4-$9-0.6}' data/temp.dat | psxy -R -J -O -K -Sc0.08i -Gred -P >> ps/compare-models.eps
#gawk '{if($1==38.0) print '"$ite"',$4-$9-0.8}' data/temp.dat | psxy -R -J -O -K -Sc0.08i -Gred -P >> ps/compare-models.eps
#gawk '{if($1==42.0) print '"$ite"',$4-$9-1.0}' data/temp.dat | psxy -R -J -O -K -Sc0.08i -Gred -P >> ps/compare-models.eps
#gawk '{if($1==46.0) print '"$ite"',$4-$9-1.2}' data/temp.dat | psxy -R -J -O -K -Sc0.08i -Gred -P >> ps/compare-models.eps
#gawk '{if($1==50.0) print '"$ite"',$4-$9-1.4}' data/temp.dat | psxy -R -J -O -K -Sc0.08i -Gred -P >> ps/compare-models.eps
#gawk '{if($1==54.0) print '"$ite"',$4-$9-1.6}' data/temp.dat | psxy -R -J -O -K -Sc0.08i -Gred -P >> ps/compare-models.eps
#gawk '{if($1==58.0) print '"$ite"',$4-$9-1.8}' data/temp.dat | psxy -R -J -O -K -Sc0.08i -Gred -P >> ps/compare-models.eps
#gawk '{if($1==62.0) print '"$ite"',$4-$9-2.0}' data/temp.dat | psxy -R -J -O -K -Sc0.08i -Gred -P >> ps/compare-models.eps
#gawk '{if($1==66.0) print '"$ite"',$4-$9-2.2}' data/temp.dat | psxy -R -J -O -K -Sc0.08i -Gred -P >> ps/compare-models.eps
#gawk '{if($1==70.0) print '"$ite"',$4-$9-2.4}' data/temp.dat | psxy -R -J -O -K -Sc0.08i -Gred -P >> ps/compare-models.eps
#gawk '{if($1==74.0) print '"$ite"',$4-$9-2.6}' data/temp.dat | psxy -R -J -O -K -Sc0.08i -Gred -P >> ps/compare-models.eps
#gawk '{if($1==78.0) print '"$ite"',$4-$9-2.8}' data/temp.dat | psxy -R -J -O -K -Sc0.08i -Gred -P >> ps/compare-models.eps
#gawk '{if($1==82.0) print '"$ite"',$4-$9-3.0}' data/temp.dat | psxy -R -J -O -K -Sc0.08i -Gred -P >> ps/compare-models.eps
#gawk '{if($1==86.0) print '"$ite"',$4-$9-3.2}' data/temp.dat | psxy -R -J -O -K -Sc0.08i -Gred -P >> ps/compare-models.eps
#gawk '{if($1==90.0) print '"$ite"',$4-$9-3.4}' data/temp.dat | psxy -R -J -O -K -Sc0.08i -Gred -P >> ps/compare-models.eps
#gawk '{if($1==94.0) print '"$ite"',$4-$9-3.6}' data/temp.dat | psxy -R -J -O -K -Sc0.08i -Gred -P >> ps/compare-models.eps
#gawk '{if($1==98.0) print '"$ite"',$4-$9-3.8}' data/temp.dat | psxy -R -J -O -K -Sc0.08i -Gred -P >> ps/compare-models.eps
#done
#
#
##psbasemap -R0/${iteration}/0.2/1.6 -JX4i/2i -B5f1/0.2f0.1:."Gc/G0 (points)":Wsne  -O -K -X-16.5i -Y-3i -P >> ps/compare-models.eps
##gawk '{if($1==25) print 0,$4,"\n",'"$iteration"',$4}' ${Forward_path}/${model}-input.dat | psxy -R -J -O -K -Wthick -P >> ps/compare-models.eps
##for ite in `seq ${iteration}`
##do
##gawk '{if($1==25) print '"$ite"',$4}' data/${model}-${ave_len}-${ite}-input_record.dat | psxy -R -J -O -K -Sc0.08i -Gred -P >> ps/compare-models.eps
##done
##psbasemap -R0/${iteration}/0.2/1.6 -JX4i/2i -B5f1/0.2f0.1Wsne  -O -K -Y-2i -P >> ps/compare-models.eps
##gawk '{if($1==35) print 0,$4,"\n",'"$iteration"',$4}' ${Forward_path}/${model}-input.dat | psxy -R -J -O -K -Wthick -P >> ps/compare-models.eps
##for ite in `seq ${iteration}`
##do
##gawk '{if($1==35) print '"$ite"',$4}' data/${model}-${ave_len}-${ite}-input_record.dat | psxy -R -J -O -K -Sc0.08i -Gred -P >> ps/compare-models.eps
##done
##psbasemap -R0/${iteration}/0.2/1.6 -JX4i/2i -B5f1/0.2f0.1Wsne  -O -K -Y-2i -P >> ps/compare-models.eps
##gawk '{if($1==45) print 0,$4,"\n",'"$iteration"',$4}' ${Forward_path}/${model}-input.dat | psxy -R -J -O -K -Wthick -P >> ps/compare-models.eps
##for ite in `seq ${iteration}`
##do
##gawk '{if($1==45) print '"$ite"',$4}' data/${model}-${ave_len}-${ite}-input_record.dat | psxy -R -J -O -K -Sc0.08i -Gred -P >> ps/compare-models.eps
##done
##psbasemap -R0/${iteration}/0.2/1.6 -JX4i/2i -B5f1/0.2f0.1Wsne  -O -K -Y-2i -P >> ps/compare-models.eps
##gawk '{if($1==55) print 0,$4,"\n",'"$iteration"',$4}' ${Forward_path}/${model}-input.dat | psxy -R -J -O -K -Wthick -P >> ps/compare-models.eps
##for ite in `seq ${iteration}`
##do
##gawk '{if($1==55) print '"$ite"',$4}' data/${model}-${ave_len}-${ite}-input_record.dat | psxy -R -J -O -K -Sc0.08i -Gred -P >> ps/compare-models.eps
##done
##psbasemap -R0/${iteration}/0.2/1.6 -JX4i/2i -B5f1/0.2f0.1Wsne  -O -K -Y-2i -P >> ps/compare-models.eps
##gawk '{if($1==65) print 0,$4,"\n",'"$iteration"',$4}' ${Forward_path}/${model}-input.dat | psxy -R -J -O -K -Wthick -P >> ps/compare-models.eps
##for ite in `seq ${iteration}`
##do
##gawk '{if($1==65) print '"$ite"',$4}' data/${model}-${ave_len}-${ite}-input_record.dat | psxy -R -J -O -K -Sc0.08i -Gred -P >> ps/compare-models.eps
##done
##psbasemap -R0/${iteration}/0.2/1.6 -JX4i/2i -B5f1/0.2f0.1Wsne  -O -K -Y-2i -P >> ps/compare-models.eps
##gawk '{if($1==75) print 0,$4,"\n",'"$iteration"',$4}' ${Forward_path}/${model}-input.dat | psxy -R -J -O -K -Wthick -P >> ps/compare-models.eps
##for ite in `seq ${iteration}`
##do
##gawk '{if($1==75) print '"$ite"',$4}' data/${model}-${ave_len}-${ite}-input_record.dat | psxy -R -J -O -K -Sc0.08i -Gred -P >> ps/compare-models.eps
##done
#

psbasemap  -R   -J -B -O  >> ps/compare-models.eps

ps2pdf ps/compare-models.eps ps/compare-models.pdf
rm -f data.nc ps/compare-models.eps *.cpt
