import sys
import numpy as np
from scipy.interpolate import griddata


model  =   sys.argv[1]
L      =   float(sys.argv[2])
lamda  =   float(sys.argv[3])
Tn     =   float(sys.argv[4])
Mud    =   float(sys.argv[5])
mu     =   float(sys.argv[6])
W      =   float(sys.argv[7])
flag   =   sys.argv[8]

L     = L*1e3
C     = np.pi/8
W     = W*1e3
lamda = lamda*1e3
Tn    = Tn*1e6

X    = np.linspace(0,L,1001)
Dtau = np.zeros((X.shape[0]))
GcG0 = np.zeros((X.shape[0]))
Gc   = np.zeros((X.shape[0]))

for i in range(X.shape[0]):
    if(X[i]<20e3):
        Dtau[i] = 2.12078e6
        GcG0[i] = 0.8
        Gc[i]   = 1.9e6 * GcG0[i]
    else:
        ### sine 5
        if(model=="sine5"):
            Dtau[i] = 2.12078e6 * (1+0.2*np.sin(((X[i]-20e3)/5.0/W)*2*np.pi))
            GcG0[i] = 0.8       * (1-0.5*np.sin(((X[i]-20e3)/5.0/W)*2*np.pi))
            Gc[i]   = 1.9e6     * GcG0[i]
        ### sine 1
        if(model=="sine1"):
            Dtau[i] = 2.12078e6 * (1+0.2*np.sin(((X[i]-20e3)/1.0/W)*2*np.pi))
            GcG0[i] = 0.8       * (1-0.4*np.sin(((X[i]-20e3)/1.0/W)*2*np.pi))
            Gc[i]   = 1.9e6     * GcG0[i]
        ### sine 0.5
        if(model=="sine0.5"):
            Dtau[i] = 2.12078e6 * (1+0.2*np.sin(((X[i]-20e3)/0.5/W)*2*np.pi))
            GcG0[i] = 0.8       * (1-0.3*np.sin(((X[i]-20e3)/0.5/W)*2*np.pi))
            Gc[i]   = 1.9e6     * GcG0[i]

### step and box
#Dtau[:] = 2.12078e6
#GcG0[:] = 0.6
#GcG0[np.where(X>40e3)] = 1.1
#GcG0[np.where(X>60e3)] = 0.8

Nx   = X.shape[0] 
Tt   = Dtau + Tn*Mud 
Mus  = (2*Gc*mu/lamda)**0.5/Tn + Mud
Dc   = (2*Gc*lamda/mu)**0.5

#for i in range(Dtau.shape[0]):
#    print X[i]/1e3,Dtau[i]/1e6,Gc[i]/1e6,GcG0[i]
#exit()

Tt[0]  = 0.0
Mus[0] = 1000000.0

if(flag == "Nx"):
   print(Nx+1)
elif(flag == "X"):
   for i in range(Nx):
       print(X[i])
elif(flag == "Tt"):
   for i in range(Nx):
       print(Tt[i])
   print(Tn*Mud)
elif(flag == "Mus"):
   for i in range(Nx):
       print(Mus[i])
   print(1000000.0)
elif(flag == "Dc"):
   for i in range(Nx):
       print(Dc[i])
   print(1)
elif(flag == "save"):
   for i in range(Nx):
       print X[i]/1e3,Dtau[i],Gc[i],GcG0[i]

