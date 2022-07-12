#!/bin/bash
gmtset PS_MEDIA a1

if [ x$1 = x-n ] && [ x$2 != x ];
then
     model=$2
else
    echo "wrong command parameters: must with -n and modelname"
    exit
fi
if [ x$3 = x-a ]; then
  echo "Running python script"
  python post-process-fault.py -n $model
else
  if  [ ! -f data/${model}-along_strike_values.dat ] ; then
    echo "Post-processed file do not exist. Please run python script first !!!!!!!!"
    exit
  fi
fi


###  grid data: x  t0 vr acce D G0 Dtau Gc Vmax
psbasemap -R0/100/0/1 -JX4i/2i -B50f10/0.2f0.1:."vr/vs":WSne  -K -Y25i -P > ps/${model}-forward_results.eps
gawk '{print $1,$3/3330.0}' data/${model}-along_strike_values.dat | psxy -R -J -O -K -Wthickest,red -P >> ps/${model}-forward_results.eps

psbasemap -R0/120/0/1e19 -JX4i/2i -B50f10/1e18f1e18:."STF":WSne  -O -K -Y-3i -P >> ps/${model}-forward_results.eps
gawk '{print $1,$2*20e3*30e9}' data/${model}-STF.dat | psxy -R -J -O -K -Wthickest,red -P >> ps/${model}-forward_results.eps

psbasemap -R0/100/0/3 -JX4i/2i -B50f10/1f1:."Slip (m)":WSne  -O -K -Y-3i -P >> ps/${model}-forward_results.eps
gawk '{print $1,$5}' data/${model}-along_strike_values.dat | psxy -R -J -O -K -Wthickest,red -P >> ps/${model}-forward_results.eps

psbasemap -R0/100/0/4 -JX4i/2i -B50f10/2f1:."Tau (MPa)":WSne  -O -K -Y-3i -P >> ps/${model}-forward_results.eps
gawk '{print $1,$6/1e6}' data/${model}-along_strike_values.dat | psxy -R -J -O -K -Wthickest,red -P >> ps/${model}-forward_results.eps

psbasemap -R0/100/0/4 -JX4i/2i -B50f10/2f1:."Gc and G0 (MPa m)":WSne  -O -K -Y-3i -P >> ps/${model}-forward_results.eps
gawk '{print $1,$7/1e6}' data/${model}-along_strike_values.dat | psxy -R -J -O -K -Wthickest,red -P >> ps/${model}-forward_results.eps
gawk '{print $1,$8/1e6}' data/${model}-along_strike_values.dat | psxy -R -J -O -K -Wthickest,blue -P >> ps/${model}-forward_results.eps

psbasemap -R0/100/0/2 -JX4i/2i -B50f10/1f0.5:."Gc/G0":WSne  -O -K -Y-3i -P >> ps/${model}-forward_results.eps
gawk '{if($1>0 && $1<100) print $1,1 - $4*(20.0*1e3/3.14)/3330**2/(1-($3/3330.0)**2)**1.5}' data/${model}-along_strike_values.dat | psxy -R -J -O -K -Wthickest,purple -P >> ps/${model}-forward_results.eps
gawk '{if($1>0 && $1<100) print $1,$8/$7}' data/${model}-along_strike_values.dat | psxy -R -J -O -K -Wthickest,red -P >> ps/${model}-forward_results.eps
psxy -R -J -O -K -Wthin -P >> ps/${model}-forward_results.eps << END
0 0.6
100 0.6
END


psbasemap -R0.0/1/-0.6/0.6 -JX4i -B0.2f0.1:"V/Vs":/0.2f0.1:"Acceleration * width / VS**2":WSne -O -K -X6i -P >> ps/${model}-forward_results.eps
gawk '{if($1>30.0 && $1<90.0 && $7>0) print $3/3330.0,$4*(20.0*1e3)/3330**2}' data/${model}-along_strike_values.dat | psxy -R -J -O -K -Wthick,red -P  >> ps/${model}-forward_results.eps


psbasemap -R0.0/1/-4/4 -JX4i  -B0.2f0.1:"V/Vs":/1f0.1:"Normalized acceleration":WSne -O -K -X6i -P >>  ps/${model}-forward_results.eps
gawk '{if($1>30.0 && $1<90.0 && $7>0) print $3/3330.0,$4*(20.0*1e3)/3330**2/(1-0.6)}' data/${model}-along_strike_values.dat | psxy -R -J -O -K -Wthick,red -P  >> ps/${model}-forward_results.eps
gawk 'BEGIN{for(v=0.0;v<1;v=v+0.001) print v,3.14*(1-v**2)**1.5}' | psxy -R -J -O -K -Wthickest -P >> ps/${model}-forward_results.eps



psbasemap  -R   -J -B -O  >> ps/${model}-forward_results.eps

ps2pdf ps/${model}-forward_results.eps ps/${model}-forward_results.pdf
rm -f data.nc ps/${model}-forward_results.eps *.cpt
