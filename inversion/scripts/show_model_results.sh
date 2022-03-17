#!/bin/bash
gmtset PS_MEDIA a0

Forward_path="/u/moana/user/weng/Weng/2.5D_dynamic_inversion/forward/scripts/data/"

if [ x$1 = x-n ] && [ x$2 != x ] && [ x$3 != x ] ;
then
     model=$2
     ave_len=$3
else
    echo "wrong command parameters: must with -n and modelname"
    exit
fi
iteration=`gawk '{if(NR==1) print $1}' data/${model}-${ave_len}-input_record.dat`
#iteration=61
bin_n=`    gawk '{if(NR==1) print $2}' data/${model}-${ave_len}-input_record.dat`
P_num=`    gawk '{if(NR==1) print $3}' data/${model}-${ave_len}-input_record.dat`
grid_size=0.1

if [ x$4 = x ]  ;
then
   wid=`   gawk '{if(NR==2) print $0}' data/${model}-${ave_len}-input_record.dat| sed 's/\ /\n/g'|minmax -C|gawk '{print $2}'`
else
   wid=$4
fi
ite_list=`gawk '{if(NR==2) print $0}' data/${model}-${ave_len}-input_record.dat| sed 's/\ /\n/g'| gawk '{if($1=='"$wid"' && NR<'"${iteration}"')print NR}'`
pre_num=`echo $ite_list | gawk 'END{print NF}'`
echo 'Iteration:' ${iteration} 
echo 'Sliding win:' ${wid} 
echo 'Presenting list:' $ite_list 
echo 'Number:' $pre_num

vr_h=` gawk 'BEGIN{print 4}'`
gc_h=` gawk 'BEGIN{print 4+'"$bin_n"'}'`
tau_h=`gawk 'BEGIN{print 4+'"$bin_n"'*2}'`
Vr_h=` gawk 'BEGIN{print 4+'"$bin_n"'*2+'"$P_num"'}'`

makecpt -Cpolar  -T-${pre_num}/${pre_num}/1  > r.cpt

#########################################
###  Model input
#########################################
###  Distribution of Tau
psbasemap -R0/100/0/4 -JX4i/2i -B50f10/2f1:."Tau (MPa)":WSne  -K -Y38i -P > ps/${model}-${ave_len}-dynamic_results.eps
gawk '{print $1,$2/1e6}' ${Forward_path}/${model}-input.dat | psxy -R -J -O -K -Wthickest -P >> ps/${model}-${ave_len}-dynamic_results.eps
num=0
for ite in $ite_list
do
gawk '{if(NR>='"$tau_h"') print $('"$ite"')/1e6}' data/${model}-${ave_len}-input_record.dat| gawk 'BEGIN{print "> -Z"'"$num"'}{print (NR-1)*'"$grid_size"',$1}'| psxy -R -J -O -K -Wthickest -Cr.cpt -P >> ps/${model}-${ave_len}-dynamic_results.eps
num=$(($num+1))
done

###  Distribution of Vr
psbasemap -R0/100/0/2 -JX4i/2i -B50f10/2f1:."vr/vs (STF)":WSne -O -K -X5.5i -P >> ps/${model}-${ave_len}-dynamic_results.eps
gawk '{if(NR>='"$Vr_h"') print $1}' data/${model}-${ave_len}-input_record.dat| gawk '{print (NR-1)*'"$grid_size"',$1}'| psxy -R -J -O -K -Wthickest  -P >> ps/${model}-${ave_len}-dynamic_results.eps
#ite_last=`echo $ite_list | gawk '{print $NF}'`
#gawk '{if(NR>='"$Vr_h"') print $('"${ite_last}"')}' data/${model}-${ave_len}-input_record.dat| gawk '{print (NR-1)*'"$grid_size"',$1}'| psxy -R -J -O -K -Wthickest,red -P >> ps/${model}-${ave_len}-dynamic_results.eps
num=0
for ite in $ite_list
do
gawk '{if(NR>='"$Vr_h"') print $('"$ite"')}' data/${model}-${ave_len}-input_record.dat| gawk 'BEGIN{print "> -Z"'"$num"'}{print (NR-1)*'"$grid_size"',$1}'| psxy -R -J -O -K -Wthickest -Cr.cpt -P >> ps/${model}-${ave_len}-dynamic_results.eps
num=$(($num+1))
done


###  Distribution of Gc
psbasemap -R0/100/0/4 -JX4i/2i -B50f10/2f1:."Gc (MPam)":WSne -O -K -X5.5i -P >> ps/${model}-${ave_len}-dynamic_results.eps
gawk '{print $1,$3/1e6}' ${Forward_path}/${model}-input.dat | psxy -R -J -O -K -Wthickest -P >> ps/${model}-${ave_len}-dynamic_results.eps
num=0
for ite in $ite_list
do
gawk '{if(NR>='"$gc_h"' && NR<'"$tau_h"') print $('"$ite"')/1e6}' data/${model}-${ave_len}-input_record.dat | gawk '{print (NR-1)*('"$ave_len"'*20),$1,'"$num"'}'| psxy -R -J -O -K -Sc0.08i -Wthin -Cr.cpt -P >> ps/${model}-${ave_len}-dynamic_results.eps
num=$(($num+1))
done

###  Distribution of vr
psbasemap -R0/100/0/3 -JX4i/2i -B50f10/1f1:."vr/vs":WSne -O -K -X5.5i -P >> ps/${model}-${ave_len}-dynamic_results.eps
gawk '{if(NR>='"$Vr_h"') print $1}' data/${model}-${ave_len}-input_record.dat| gawk '{print (NR-1)*'"$grid_size"',$1}'| psxy -R -J -O -K -Wthickest  -P >> ps/${model}-${ave_len}-dynamic_results.eps
gawk '{if(NR>='"$vr_h"' && NR<'"$gc_h"') print $1}' data/${model}-${ave_len}-input_record.dat | gawk '{print NR*('"$ave_len"'*20),$1}' | psxy -R -J -O -K -St0.08i -Gpurple -P >> ps/${model}-${ave_len}-dynamic_results.eps
num=0
for ite in $ite_list
do
gawk '{if(NR>='"$vr_h"' && NR<'"$gc_h"') print $('"$ite"')}' data/${model}-${ave_len}-input_record.dat | gawk '{print NR*('"$ave_len"'*20),$1,'"$num"'}'| psxy -R -J -O -K -Sc0.03i -Wthinnest -Cr.cpt -P >> ps/${model}-${ave_len}-dynamic_results.eps
num=$(($num+1))
done

###  Convergence of Gc
num=0
rm -f data/gc-temp.dat
touch data/gc-temp.dat
for ite in $ite_list
do
gawk '{if(NR=='"$gc_h"'+('"$wid"')) print $0}' data/${model}-${ave_len}-input_record.dat| sed 's/\ /\n/g'| gawk '{if(NR=='"$ite"')print '"$num"',$1/1e6}' >> data/gc-temp.dat
num=$(($num+1))
done
temp=`echo $ite_list|gawk '{print $1}'`
gc0=` gawk '{if(NR=='"$gc_h"'+('"$wid"')) print $0}' data/${model}-${ave_len}-input_record.dat| sed 's/\ /\n/g'| gawk '{if(NR=='"$temp"')print $1/1e6}'`
gc_lower=`gmtinfo data/gc-temp.dat -C | gawk '{print $3-0.1}'`
gc_upper=`gmtinfo data/gc-temp.dat -C | gawk '{print $4+0.1}'`
gc_bound=`gmtinfo data/gc-temp.dat -C | gawk '{print $4-$3}'`
psbasemap -R0/${pre_num}/${gc_lower}/${gc_upper} -JX4i/2i -B5f1/0.2f0.1:."Gc (MPa m)":WSne  -O -K -X5.5i -P >> ps/${model}-${ave_len}-dynamic_results.eps
psxy data/gc-temp.dat -R -J -O -K -Sc0.08i -Wthin -Gblue -P >> ps/${model}-${ave_len}-dynamic_results.eps

###  Convergence of vr
num=0
rm -f data/vr-temp.dat
touch data/vr-temp.dat
for ite in $ite_list
do
gawk 'BEGIN{OFS="\n"}{if(NR=='"$vr_h"'+('"$wid"')) print $0}' data/${model}-${ave_len}-input_record.dat| sed 's/\ /\n/g'| gawk '{if(NR=='"$ite"')print '"$num"',$1}' >> data/vr-temp.dat
num=$(($num+1))
done
vr0=`gawk '{if(NR=='"$vr_h"'+('"$wid"')) print $1}' data/${model}-${ave_len}-input_record.dat`
vr_lower=`gmtinfo data/vr-temp.dat -C | gawk '{print $3-0.05}'`
vr_upper=`gmtinfo data/vr-temp.dat -C | gawk '{print $4+0.05}'`
vr_bound=`gmtinfo data/vr-temp.dat -C | gawk '{print $4-$3}'`
psbasemap -R0/${pre_num}/-0.5/0.5 -JX4i/2i -B5f1/0.1f0.1:."vr":WSne  -O -K -X5.5i -P >> ps/${model}-${ave_len}-dynamic_results.eps
gawk 'BEGIN{print 0,0,"\n",'"$pre_num"',0}' | psxy -R -J -O -K -Wthin -P >> ps/${model}-${ave_len}-dynamic_results.eps
gawk '{print $1,($2**2-'"$vr0"'**2)/'"$vr0"'**2}' data/vr-temp.dat | psxy -R -J -O -K -Sc0.08i -Gred -Wthin -P >> ps/${model}-${ave_len}-dynamic_results.eps


####   vr Gc slope
#psbasemap -R0/${pre_num}/-${vr_bound}/${vr_bound} -JX4i/2i -B5f1/${vr_bound}f${vr_bound}WS  -O -K -X5.5i -P >> ps/${model}-${ave_len}-dynamic_results.eps
#gawk '{if(NR>1) print $1,$2-'"$vr0"'}' data/vr-temp.dat | psxy -R -J -O -K -Sc0.08i -Gred -P >> ps/${model}-${ave_len}-dynamic_results.eps
#psbasemap -R0/${pre_num}/-${gc_bound}/${gc_bound} -JX4i/2i -B50f10/${gc_bound}f${gc_bound}NE  -O -K  -P >> ps/${model}-${ave_len}-dynamic_results.eps
#gawk '{if(NR==1) {print $1,$2-'"$gc0"';gc=$2} else print $1,$2-gc;gc=$2}' data/gc-temp.dat | psxy -R -J -O -K -Sc0.08i -Gblue -P >> ps/${model}-${ave_len}-dynamic_results.eps




#########################################
###  simulation output
#########################################
psbasemap -R0/100/0.0/1.0 -JX4i/2i -B50f10/0.2f0.1:."vr/vs":WSne -O -K -X-27.5i -Y-3i -P >> ps/${model}-${ave_len}-dynamic_results.eps
gawk '{print $1,$3/3330.0}' ${Forward_path}/${model}-along_strike_values.dat | psxy -R -J -O -K -Wthickest -P >> ps/${model}-${ave_len}-dynamic_results.eps
num=0
for ite in $ite_list
do
gawk 'BEGIN{print "> -Z"'"$num"'}{print $1,$3/3330.0}' data/${model}-${ave_len}-${ite}-along_strike_values.dat | psxy -R -J -O -K -Wthickest -Cr.cpt -P >> ps/${model}-${ave_len}-dynamic_results.eps
num=$(($num+1))
done

psbasemap -R0/100/0/8e18 -JX4i/2i -B50f10/1e19f1e18:."STF":WSne  -O -K -X5.5i -P >> ps/${model}-${ave_len}-dynamic_results.eps
gawk '{print $1,$2*20e3*30e9}' ${Forward_path}/${model}-STF.dat | psxy -R -J -O -K -Wthickest -P >> ps/${model}-${ave_len}-dynamic_results.eps
num=0
for ite in $ite_list
do
gawk 'BEGIN{print "> -Z"'"$num"'}{print $1,$2*20e3*30e9}' data/${model}-${ave_len}-${ite}-STF.dat | psxy -R -J -O -K -Wthickest -Cr.cpt -P >> ps/${model}-${ave_len}-dynamic_results.eps
num=$(($num+1))
done

psbasemap -R0/100/0/100 -JX4i/2i -B50f10/20f10:."Rupture time (s)":WSne -O  -K -X5.5i -P >> ps/${model}-${ave_len}-dynamic_results.eps
gawk '{print $1,$2}' ${Forward_path}/${model}-along_strike_values.dat | psxy -R -J -O -K -Wthickest -P >> ps/${model}-${ave_len}-dynamic_results.eps
num=0
for ite in $ite_list
do
gawk 'BEGIN{print "> -Z"'"$num"'}{print $1,$2}' data/${model}-${ave_len}-${ite}-along_strike_values.dat | psxy -R -J -O -K -Wthickest -Cr.cpt -P >> ps/${model}-${ave_len}-dynamic_results.eps
num=$(($num+1))
done

#########################################
### 
#########################################
psbasemap -R0/100/0/3 -JX4i/2i -B50f10/1f1:."Slip (m)":WSne  -O -K -X-11i -Y-3i -P >> ps/${model}-${ave_len}-dynamic_results.eps
gawk '{print $1,$5}' ${Forward_path}/${model}-along_strike_values.dat | psxy -R -J -O -K -Wthickest -P >> ps/${model}-${ave_len}-dynamic_results.eps
num=0
for ite in $ite_list
do
gawk 'BEGIN{print "> -Z"'"$num"'}{print $1,$5}' data/${model}-${ave_len}-${ite}-along_strike_values.dat | psxy -R -J -O -K -Wthickest -Cr.cpt -P >> ps/${model}-${ave_len}-dynamic_results.eps
num=$(($num+1))
done

psbasemap -R0/100/0/5 -JX4i/2i -B50f10/2f1:."Tau (MPa)":WSne  -O -K -X5.5i -P >> ps/${model}-${ave_len}-dynamic_results.eps
gawk '{print $1,$6/1e6}' ${Forward_path}/${model}-along_strike_values.dat | psxy -R -J -O -K -Wthickest -P >> ps/${model}-${ave_len}-dynamic_results.eps
num=0
for ite in $ite_list
do
gawk 'BEGIN{print "> -Z"'"$num"'}{print $1,$6/1e6}' data/${model}-${ave_len}-${ite}-along_strike_values.dat | psxy -R -J -O -K -Wthickest -Cr.cpt -P >> ps/${model}-${ave_len}-dynamic_results.eps
num=$(($num+1))
done

psbasemap -R0/100/0/4 -JX4i/2i -B50f10/2f1:."G0 (MPa m)":WSne  -O -K -X5.5i -P >> ps/${model}-${ave_len}-dynamic_results.eps
gawk '{print $1,$7/1e6}' ${Forward_path}/${model}-along_strike_values.dat | psxy -R -J -O -K -Wthickest -P >> ps/${model}-${ave_len}-dynamic_results.eps
num=0
for ite in $ite_list
do
gawk 'BEGIN{print "> -Z"'"$num"'}{print $1,$7/1e6}' data/${model}-${ave_len}-${ite}-along_strike_values.dat | psxy -R -J -O -K -Wthickest -Cr.cpt -P >> ps/${model}-${ave_len}-dynamic_results.eps
num=$(($num+1))
done

psbasemap -R0/100/0/5 -JX4i/2i -B50f10/2f1:."Gc (MPa m)":WSne  -O -K -X5.5i -P >> ps/${model}-${ave_len}-dynamic_results.eps
gawk '{print $1,$8/1e6}' ${Forward_path}/${model}-along_strike_values.dat | psxy -R -J -O -K -Wthickest -P >> ps/${model}-${ave_len}-dynamic_results.eps
num=0
for ite in $ite_list
do
gawk 'BEGIN{print "> -Z"'"$num"'}{print $1,$8/1e6}' data/${model}-${ave_len}-${ite}-along_strike_values.dat | psxy -R -J -O -K -Wthickest -Cr.cpt -P >> ps/${model}-${ave_len}-dynamic_results.eps
num=$(($num+1))
done

##########################################
####
##########################################
psbasemap -R0/${iteration}/0/1 -JX4i/2i -B50f10/2f1:."Misfit of STF":WSne  -O -K -X-16.5i -Y-3i -P >> ps/${model}-${ave_len}-dynamic_results.eps
gawk '{if($1>=0.0 && $1<100) print $1,$2}' ${Forward_path}/${model}-STF.dat > data/original_STF.dat
N_obs=`gawk 'BEGIN{sum=0.0;num=0.0}{sum=sum+($2-0)**2;num=num+1}END{print sum**0.5}' data/original_STF.dat`
for ite in `seq ${iteration}`
do
gawk '{if($1>=0.0 && $1<100) print $1,$2}' data/${model}-${ave_len}-${ite}-STF.dat > data/ite_STF.dat
paste data/original_STF.dat data/ite_STF.dat | gawk 'BEGIN{sum=0.0;num=0.0}{sum=sum+($2-$4)**2;num=num+1}END{print '"${ite}"',sum**0.5/'"$N_obs"'}' | psxy -R -J -O -K -Sc0.08i -Gred -P >> ps/${model}-${ave_len}-dynamic_results.eps
done

psbasemap -R0/${iteration}/0.001/1 -JX4i/2il -B50f10/2f1:."Misfit of Slip":WSne  -O -K -X5.5i -P >> ps/${model}-${ave_len}-dynamic_results.eps
gawk '{if($1>=0.0 && $1<100) print $1,$5}' ${Forward_path}/${model}-along_strike_values.dat > data/original_slip.dat
N_obs=`gawk 'BEGIN{sum=0.0;num=0.0}{sum=sum+($2-0)**2;num=num+1}END{print sum**0.5}' data/original_slip.dat`
for ite in `seq ${iteration}`
do
gawk '{if($1>=0.0 && $1<100) print $1,$5}' data/${model}-${ave_len}-${ite}-along_strike_values.dat > data/ite_slip.dat
paste data/original_slip.dat data/ite_slip.dat | gawk 'BEGIN{sum=0.0;num=0.0}{sum=sum+($2-$4)**2;num=num+1}END{print '"${ite}"',sum**0.5/'"$N_obs"'}' | psxy -R -J -O -K -Sc0.08i -Gred -P >> ps/${model}-${ave_len}-dynamic_results.eps
done

#psbasemap -R0/${iteration}/0/0.5 -JX4i/2i -B50f10/0.5f0.1:."Misfit of vr (inverted)":WSne  -O -K -X5.5i -P >> ps/${model}-${ave_len}-dynamic_results.eps
#for ite in `seq ${iteration}`
#do
#if [ $ite = 1 ] ; then
#continue
#fi
#gawk '{if($1>=0.0 && $1<100) print $1,$5/3330.0}' data/${model}-${ave_len}-1-input_record.dat > data/original_vr.dat
#gawk '{if($1>=0.0 && $1<100) print $1,$5/3330.0}' data/${model}-${ave_len}-${ite}-input_record.dat > data/ite_vr.dat
#paste data/original_vr.dat data/ite_vr.dat | gawk 'BEGIN{sum=0.0;num=0.0}{sum=sum+($2-$4)**2;num=num+1}END{print '"${ite}"',(sum/num)**0.5}' | psxy -R -J -O -K -Sc0.08i -Gred -P >> ps/${model}-${ave_len}-dynamic_results.eps
#done
#
#psbasemap -R0/${iteration}/0/0.5 -JX4i/2i -B50f10/0.5f0.1:."Misfit of vr":WSne  -O -K -X5.5i -P >> ps/${model}-${ave_len}-dynamic_results.eps
#for ite in `seq ${iteration}`
#do
#gawk '{if($1>=0.0 && $1<100) print $1,$3/3330.0}' ${Forward_path}/${model}-along_strike_values.dat > data/original_vr.dat
#gawk '{if($1>=0.0 && $1<100) print $1,$3/3330.0}' data/${model}-${ave_len}-${ite}-along_strike_values.dat > data/ite_vr.dat
#paste data/original_vr.dat data/ite_vr.dat | gawk 'BEGIN{sum=0.0;num=0.0}{sum=sum+($2-$4)**2;num=num+1}END{print '"${ite}"',sum**0.5}' | psxy -R -J -O -K -Sc0.08i -Gred -P >> ps/${model}-${ave_len}-dynamic_results.eps
#done




psbasemap  -R   -J -B -O  >> ps/${model}-${ave_len}-dynamic_results.eps

ps2pdf ps/${model}-${ave_len}-dynamic_results.eps ps/${model}-${ave_len}-dynamic_results.pdf
rm -f data.nc ps/${model}-${ave_len}-dynamic_results.eps *.cpt
