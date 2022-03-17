#!/bin/bash
gmtset PS_MEDIA a1

if [ x$1 = x-n ] && [ x$2 != x ];
then
     model=$2
else
    echo "wrong command parameters: must with -n and modelname"
    exit
fi

iteration=2

psbasemap -R0/100/0/2 -JX4i/2i -B50f10/2f1:."Gc/G0":WSne  -K -Y25i -P > ps/${model}-input_GcG0_checking.eps
psxy -R -J -O -K -Wthick -P >> ps/${model}-input_GcG0_checking.eps << END
0 0.6
50 0.6
50 1.1
100 1.1
END
gawk '{print $1,$8/$7}' /u/moana/user/weng/Weng/2.5D_dynamic_inversion/forward/scripts/data/${model}-along_strike_values.dat | psxy -R -J -O -K -Wthickest -P >> ps/${model}-input_GcG0_checking.eps
python ../estimates_GcG0.py ${model} ${iteration} | gawk '{print $1,$3}' | psxy -R -J -O -K -Wthickest,red -P >> ps/${model}-input_GcG0_checking.eps
python ../estimates_GcG0.py ${model} ${iteration} | gawk '{print $1,$4}' | psxy -R -J -O -K -Wthickest,purple -P >> ps/${model}-input_GcG0_checking.eps

psbasemap -R0/100/0/4 -JX4i/2i -B50f10/2f1:."Tau (MPa)":WSne  -O -K -Y-3i -P >>  ps/${model}-input_GcG0_checking.eps
gawk '{print $1,$6/1e6}' /u/moana/user/weng/Weng/2.5D_dynamic_inversion/forward/scripts/data/${model}-along_strike_values.dat | psxy -R -J -O -K -Wthickest -P >> ps/${model}-input_GcG0_checking.eps
python ../estimates_GcG0.py ${model} ${iteration}  | gawk '{print $1,$2/1e6}' | psxy -R -J -O -K -Wthickest,red -P >> ps/${model}-input_GcG0_checking.eps

psbasemap  -R   -J -B -O  >> ps/${model}-input_GcG0_checking.eps

ps2pdf ps/${model}-input_GcG0_checking.eps ps/${model}-input_GcG0_checking.pdf
rm -f data.nc ps/${model}-input_GcG0_checking.eps *.cpt
