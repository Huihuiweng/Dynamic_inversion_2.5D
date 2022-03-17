from sem2d_read_fault import sem2d_read_fault
import sys
import numpy as np
from scipy.interpolate import griddata
import scipy.ndimage.filters as filters


# get the modelname from shell
model_flag=0
for i in range(len(sys.argv)):
  if (sys.argv[i].find("-n")==0):
    model_name=sys.argv[i+1]
    model_flag=model_flag+1
if(model_flag!=1):
  print("Model name is needed. Such as: python post-process-fault.py -n ssr")
  exit()

result_path = "/u/moana/user/weng/Weng/2.5D_dynamic_inversion/inversion/simulations/" + model_name 
print(result_path)
fault_name  = "Flt01"
data = sem2d_read_fault(result_path,fault_name)

nx = data['nx']
nt = data['nt']
dt = data['dt']
nodes_x = data['x']
v       = data['v']
d       = data['d']
st      = data['st']
sn      = data['sn']
mu      = data['mu']
st0     = data['st0']
sn0     = data['sn0']
mu0     = data['mu0']


Rup_t    = np.zeros((nx))
Rup_id   = np.zeros((nx))
#Vmax     = np.zeros((nx))
Gc       = np.zeros((nx))
G0       = np.zeros((nx))
Slip     = np.zeros((nx))
Dtau     = np.zeros((nx))
#tau0     = np.zeros((nx))
#taus     = np.zeros((nx))
M0       = np.zeros((nt))
STF      = np.zeros((nt))


if(nt > v.shape[0]+1):
    print("Data steps is less than nt... Model is:",model_name, nt,v.shape[0])
    nt = v.shape[0]+1

V_critical = 0.001

# Get rupture time for each grid
for x in range(nx):
    for i in range(nt-2):
        if(v[i,x]<V_critical and v[i+1,x]>=V_critical):
            Rup_t[x]  = i * dt
            Rup_id[x] = i
            break

# Get energies for each grid
for x in range(nx):
    for i in range(nt-2):
        if(i < Rup_id[x] or i==0): continue
        sliprate = v[i,x]
        tau      = st[i,x]
        Gc[x] = Gc[x] + dt * sliprate * tau
#        if(sliprate > Vmax[x]): Vmax[x] = sliprate
    Gc[x] = Gc[x] - st[-1,x] * d[-1,x]
    G0[x] = 0.5 * d[-1,x] * (st[0,x] - st[-1,x])
    Slip[x] = d[-1,x]
    Dtau[x] = st[0,x] - st[-1,x]
#    if(x<mu0.shape[0]-1):
#        tau0[x] = st0[x] - 27e6
#        taus[x] = mu0[x]*50e6 - 27e6

for t in range(nt):
    for x in range(nx):
        if(x==0): continue
        M0[t] = M0[t] + d[t,x]*(nodes_x[x]-nodes_x[x-1])
for t in range(nt):
    if(t==0): continue
    STF[t] = (M0[t]-M0[t-1])/dt

grid_size = 100.0

X_lower  = np.min(nodes_x)
X_upper  = np.max(nodes_x)
X_dim    = int((X_upper-X_lower)/grid_size+1)

grid_x = np.mgrid[X_lower:X_upper:X_dim*1j]
Init_t0  = griddata(nodes_x, Rup_t, grid_x, method='linear')
grid_Gc  = griddata(nodes_x,    Gc, grid_x, method='linear')
grid_G0  = griddata(nodes_x,    G0, grid_x, method='linear')
#grid_Vmax= griddata(nodes_x,  Vmax, grid_x, method='linear')
grid_Slip= griddata(nodes_x,  Slip, grid_x, method='linear')
grid_Dtau= griddata(nodes_x,  Dtau, grid_x, method='linear')
#grid_tau0= griddata(nodes_x,  tau0, grid_x, method='linear')
#grid_taus= griddata(nodes_x,  taus, grid_x, method='linear')

vr       = np.zeros((X_dim))
acce     = np.zeros((X_dim))

for i in range(X_dim):
    if(Init_t0[i]==0.0 or i==0 or i==X_dim-1): continue
    if (Init_t0[i+1]-Init_t0[i-1] != 0.0):
        if(grid_x[i]>0):
            vr[i] =  (2*grid_size) / (Init_t0[i+1]-Init_t0[i-1])
        else:
            vr[i] = -(2*grid_size) / (Init_t0[i+1]-Init_t0[i-1])

vr = filters.gaussian_filter1d(vr,  3, mode='nearest')
#grid_Vmax = filters.gaussian_filter1d(grid_Vmax,  3, mode='nearest')

for i in range(X_dim):
    if(i<10 or i>X_dim-12 or vr[i]==0): continue
    acce[i] =  (vr[i+1] - vr[i-1]) / (2*grid_size) * vr[i]

###  grid data: x  t0 vr acce D G0 Dtau Gc Vmax
output= open("data/"+model_name+"-along_strike_values.dat","w")
for i in range(X_dim):
    output.writelines(str(grid_x[i]/1e3))
    output.writelines("  ")
    output.writelines(str(Init_t0[i]))
    output.writelines("  ")
    output.writelines(str(vr[i]))
    output.writelines("  ")
    output.writelines(str(acce[i]))
    output.writelines("  ")
    output.writelines(str(grid_Slip[i]))
    output.writelines("  ")
    output.writelines(str(grid_Dtau[i]))
    output.writelines("  ")
    output.writelines(str(grid_G0[i]))
    output.writelines("  ")
    output.writelines(str(grid_Gc[i]))
#    output.writelines("  ")
#    output.writelines(str(grid_Vmax[i]))
#    output.writelines("  ")
#    output.writelines(str(grid_tau0[i]))
#    output.writelines("  ")
#    output.writelines(str(grid_taus[i]))
    output.writelines("\n")
output.close()

output= open("data/"+model_name+"-STF.dat","w")
for i in range(nt):
    output.writelines(str(i * dt))
    output.writelines("  ")
    output.writelines(str(STF[i]))
    output.writelines("  ")
    output.writelines(str(M0[i]))
    output.writelines("\n")
output.close()
