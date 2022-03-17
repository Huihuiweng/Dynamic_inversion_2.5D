import sys
import numpy as np
import scipy.ndimage.filters as filters
from scipy.interpolate   import griddata
import estimates_GcG0

model  =   sys.argv[1]
L      =   float(sys.argv[2])
lamda  =   float(sys.argv[3])
Tn     =   float(sys.argv[4])
Mud    =   float(sys.argv[5])
mu     =   float(sys.argv[6])
W      =   float(sys.argv[7])
Vs     =   float(sys.argv[8])
ite    =   int(sys.argv[9])
ave_len=   float(sys.argv[10])
flag   =   sys.argv[11]

L     = L*1e3
C     = np.pi/8
W     = W*1e3
lamda = lamda*1e3
Tn    = Tn*1e6

X,Dtau,Gc = estimates_GcG0.set_para(model,ite,W,Vs,ave_len,lamda,False)

### Parameters for sem2dpack
X    = X*1e3
Nx   = X.shape[0] 
Tt   = Dtau + Tn*Mud 
Mus  = (2*Gc*mu/lamda)**0.5/Tn + Mud
Dc   = (2*Gc*lamda/mu)**0.5

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


