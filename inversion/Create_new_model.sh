#!/bin/bash
ulimit -s unlimited

path="/u/moana/user/weng/Weng/2.5D_dynamic_inversion/inversion/"
model="cosine0.5"
Start=1
End=200
ave_len=0.1

########    Running parameter
L_left=-10
L_right=110
L=100
W=20
Vp=5770.0
Vs=3330.0
Rho=2705.0
TotalT=100
mu=30e9
lamda=4
grid=0.5
vnuc=0.1
lnuc=30e3

ndof=1       # 1 is anti-plane and 2 is in-plane
iexec=1      # 0 is check 1 is run
ngll=5
Courant=0.6
########    Domain parameters
xlim=`gawk 'BEGIN{OFS=""; print '"${L_left}"',"d3",",",'"${L_right}"',"d3"}'`
zlim=`gawk 'BEGIN{OFS=""; print "0d3,",'"$L_right"',"d3"}'`
nelem=`gawk 'BEGIN{OFS=","; print ('"$L_right"'-('"${L_left}"'))/'"$grid"',('"$L_right"')/'"$grid"'}'`

for iteration in `seq ${Start} ${End}`
do
echo $iteration

mkdir -p ${path}/simulations/${model}-${ave_len}-${iteration}
rm -rf ${path}/simulations/${model}-${ave_len}-${iteration}/*
cd ${path}/simulations/${model}-${ave_len}-${iteration}
#########   Slip-weakening parameters
Tn=50
Mud=0.54
V=`    gawk 'BEGIN{print '"$vnuc"'*'"$Vs"'}'`
Tnuc=`gawk 'BEGIN{print '"$lnuc"'/'"$V"'}'`
Nx=` ~/Weng/Software/miniconda3/bin/python ${path}/create_hete_input_files.py ${model} ${L} ${lamda} ${Tn} ${Mud} ${mu} ${W} ${Vs} ${iteration} ${ave_len} Nx`
X=`  ~/Weng/Software/miniconda3/bin/python ${path}/create_hete_input_files.py ${model} ${L} ${lamda} ${Tn} ${Mud} ${mu} ${W} ${Vs} ${iteration} ${ave_len} X  | gawk 'BEGIN{ORS=" "}{print $0}'`
Mus=`~/Weng/Software/miniconda3/bin/python ${path}/create_hete_input_files.py ${model} ${L} ${lamda} ${Tn} ${Mud} ${mu} ${W} ${Vs} ${iteration} ${ave_len} Mus| gawk 'BEGIN{ORS=" "}{print $0}'`
Tt=` ~/Weng/Software/miniconda3/bin/python ${path}/create_hete_input_files.py ${model} ${L} ${lamda} ${Tn} ${Mud} ${mu} ${W} ${Vs} ${iteration} ${ave_len} Tt | gawk 'BEGIN{ORS=" "}{print $0}'`
Dc=` ~/Weng/Software/miniconda3/bin/python ${path}/create_hete_input_files.py ${model} ${L} ${lamda} ${Tn} ${Mud} ${mu} ${W} ${Vs} ${iteration} ${ave_len} Dc | gawk 'BEGIN{ORS=" "}{print $0}'`


cat > Par.inp << END
#----- Some general parameters ----------------
&GENERAL iexec=${iexec}, ngll=${ngll}, fmax=3.d0 , W=${W}d3, ndof=${ndof} ,
  title = '${model}', verbose='1111' , ItInfo = 4000/ 

#----- Build the mesh ---------------------------
&MESH_DEF  method = 'CARTESIAN'/
&MESH_CART xlim=${xlim}, zlim=${zlim}, nelem=${nelem}/

#---- Material parameters --------------
&MATERIAL tag=1, kind='ELAST'  /
&MAT_ELASTIC rho=${Rho}, cp=${Vp}, cs=${Vs} /

#----- Boundary conditions ---------------------
&BC_DEF  tag = 1, kind = 'DYNFLT' /
&BC_DYNFLT friction='SWF','TWF', Tn=-${Tn}d6,TtH="ORDER0" /
&DIST_ORDER0 xn=${Nx},zn=1 /
${X}  
${Tt}
&BC_DYNFLT_SWF DcH="ORDER0", MusH="ORDER0", Mud=${Mud}d0 /
&DIST_ORDER0 xn=${Nx},zn=1 /
${X}  
${Dc}
&DIST_ORDER0 xn=${Nx},zn=1 /
${X}  
${Mus}
&BC_DYNFLT_TWF kind=1, Mus=0.63d0, Mud=${Mud}d0, Mu0=0.63d0, 
               X=0.d0, Z=0.d0, V=${V}d0, L=${lamda}d3, T=${Tnuc}d0 /

&BC_DEF  tag = 2 , kind = 'ABSORB' /
&BC_DEF  tag = 3 , kind = 'ABSORB' /
&BC_DEF  tag = 4 , kind = 'ABSORB' /

#---- Time scheme settings ----------------------
&TIME  TotalTime=${TotalT} , Courant=0.6d0, kind='newmark' /


#--------- Plots settings ----------------------
&SNAP_DEF itd=1000, fields ='DVS',bin=F,ps=F /
&SNAP_PS  vectors=F, interpol=F, DisplayPts=6, ScaleField=0d0   /
END


########################
###  Run models      ###
########################
/u/moana/user/weng/Weng/Software/sem2dpack/bin/sem2dsolve > info  &
wait
  echo "Finish one run of simulation: ${iteration}" 

########################
###  Run postscript  ###
########################

cd ${path}/scripts
python post-process-fault.py -n ${model}-${ave_len}-${iteration}
  echo "Finish one run of postscript: ${iteration}" 

#################################
###  Delete the model output  ###
#################################
rm -rf ${path}/simulations/${model}-${ave_len}-${iteration}
  echo "Delete the model output: ${iteration}" 

done
