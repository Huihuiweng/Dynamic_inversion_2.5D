import numpy as np
import scipy
from   scipy import fftpack
import scipy.ndimage.filters as filters

forward_path   = "/u/moana/user/weng/Weng/2.5D_dynamic_inversion/forward/scripts/data/"
inversion_path = "/u/moana/user/weng/Weng/2.5D_dynamic_inversion/inversion/scripts/data/"

def read_slip(model,ave_len,iteration):
    if(iteration==0):
       filename = forward_path+model+"-along_strike_values.dat"
    else:
       filename = inversion_path+model+"-"+str(ave_len)+"-"+str(iteration)+"-along_strike_values.dat"
    data=[]
    with open(filename, 'r') as myfile:
        for line in myfile:
            data.append(line.rstrip().split())
    data = np.array(data)
    data = data.astype(float)
    X     = data[:,0]
    f_ind = np.where((X>=0) & (X<=100))
    X    = np.squeeze(data[f_ind,0])
    slip = np.squeeze(data[f_ind,4])
    RupT = np.squeeze(data[f_ind,1])
    vr   = np.squeeze(data[f_ind,2])
    output = np.column_stack((X,slip,RupT,vr))
    return output

def read_STF(model,ave_len,iteration):
    if(iteration==0):
       filename = forward_path+model+"-STF.dat"
    else:
       filename = inversion_path+model+"-"+str(ave_len)+"-"+str(iteration)+"-STF.dat"
    data=[]
    with open(filename, 'r') as myfile:
        for line in myfile:
            data.append(line.rstrip().split())
    data = np.array(data)
    data = data.astype(float)
    T    = np.squeeze(data[:,0])
    STF  = np.squeeze(data[:,1])
    M0   = np.squeeze(data[:,2])
    output = np.column_stack((T,STF,M0))
    return output

def read_record(model,ave_len):
    filename = inversion_path+model+"-"+str(ave_len)+"-input_record.dat"
    data=[]
    with open(filename, 'r') as myfile:
        for line in myfile:
            data.append(line.rstrip().split())
    iteration  = int(data[0][0])
    bin_n   = int(data[0][1])
    P_num   = int(data[0][2])
  
    win  = np.array(data[1])
    amp  = np.array(data[2])
    vr2  = np.array(data[3:bin_n+3])
    gc   = np.array(data[bin_n+3:2*bin_n+3])
    Dtau = np.array(data[2*bin_n+3:2*bin_n+3+P_num])
    Vr   = np.array(data[2*bin_n+3+P_num:2*bin_n+3+2*P_num])
    RupT = np.array(data[2*bin_n+3+2*P_num::])
    win     = win.astype(int)
    amp     = amp.astype(float)
    vr2     = vr2.astype(float)
    gc      = gc.astype(float)
    Dtau    = Dtau.astype(float)
    Vr      = Vr.astype(float)
    RupT    = RupT.astype(float)
    return iteration,bin_n,win,amp,vr2,gc,Dtau,Vr,RupT

def save_record(model,ave_len,iteration,bin_n,P_num,win,amp,vr2,gc,Dtau,Vr,RupT):
    filename = inversion_path+model+"-"+str(ave_len)+"-input_record.dat"
    output= open(filename,"w")
    output.writelines(str(iteration))
    output.writelines(" ")
    output.writelines(str(bin_n))
    output.writelines(" ")
    output.writelines(str(P_num))
    output.writelines("\n")
    for i in range(win.shape[0]):
        output.writelines(str(win[i]))
        output.writelines(" ")
    output.writelines("\n")
    for i in range(amp.shape[0]):
        output.writelines(str(amp[i]))
        output.writelines(" ")
    output.writelines("\n")
    for i in range(vr2.shape[0]):
        for j in range(vr2.shape[1]):
            output.writelines(str(vr2[i,j]))
            output.writelines(" ")
        output.writelines("\n")
    for i in range(gc.shape[0]):
        for j in range(gc.shape[1]):
            output.writelines(str(gc[i,j]))
            output.writelines(" ")
        output.writelines("\n")
    for i in range(Dtau.shape[0]):
        for j in range(Dtau.shape[1]):
            output.writelines(str(Dtau[i,j]))
            output.writelines(" ")
        output.writelines("\n")
    for i in range(Vr.shape[0]):
        for j in range(Vr.shape[1]):
            output.writelines(str(Vr[i,j]))
            output.writelines(" ")
        output.writelines("\n")
    for i in range(RupT.shape[0]):
        for j in range(RupT.shape[1]):
            output.writelines(str(RupT[i,j]))
            output.writelines(" ")
        output.writelines("\n")
    output.close()
    return 


def dynamic_time_warping(slip,STF,X0,T0,Vr0):
    X    = slip[:,0]
    D    = slip[:,1]
    T    = STF[:,0]
    dM0  = STF[:,1]
    M0   = STF[:,2]

    grid_size = (X[1]-X[0])*1e3
    X_num = X.shape[0]
    T_num = T.shape[0]
    vr    = np.zeros((X_num))
    RupT  = np.zeros((X_num))

    Archoring_X = int(np.where(X==X0)[0])
    Archoring_T = np.where(T<T0)[0][-1]
    vr[0:Archoring_X+1] = Vr0

    for i in range(Archoring_X+1):
        RupT[i] = T[Archoring_T]/float(Archoring_X)*i
    
    temp_t   = T[Archoring_T]
    temp_dM0 = dM0[Archoring_T]
    for i in range(Archoring_X,X_num-1):
        if(vr[i]==0.0): break
        dt = grid_size / vr[i]
        temp_t = temp_t + dt
        RupT[i+1] = temp_t
        for t in range(Archoring_T,T_num-1):
            if(temp_t>=T[t] and temp_t<T[t+1]):
                new_dM0 = dM0[t] + (dM0[t+1]-dM0[t])*(temp_t-T[t])/(T[t+1]-T[t])
                vr[i+1] = new_dM0 / D[i]
                break
    return vr,RupT


def checkpoints(vr,bin_p,win,offset,Delta_X,Vs):
    P_num = vr.shape[0]
    bin_n = int(P_num/bin_p)
    vr2   = np.zeros((bin_n))
    for i in range(bin_n):
        if(i==bin_n-1):
           vr2[i]    = vr[bin_n-1]
        else:
           if(i<win):
               vr2[i]    = np.nanmean(vr[(i+1)*bin_p-5:(i+1)*bin_p+5])
           else:
               p_offset  = int(offset*vr[win*bin_p]*Vs/Delta_X)
               if(p_offset+5>bin_p):
                   p_offset = bin_p - 5
               vr2[i]    = np.nanmean(vr[(i+1)*bin_p+p_offset-5:(i+1)*bin_p+p_offset+5])
    return vr2

def interpolation(value,W,P_num):
    bin_n   = value.shape[0]
    bin_p   = int(P_num/bin_n)
    value_s = np.zeros((P_num))
    for i in range(bin_n):
        value_s[i*bin_p:(i+1)*bin_p] = value[i]
    value_s[P_num-1] = value_s[P_num-2]
    return value_s

def ave_bins(value,W,bin_p):
    P_num   = value.shape[0]
    bin_n   = int(P_num/bin_p)
    value_s = np.zeros((bin_n))
    for i in range(bin_n):
        value_s[i] = np.nanmean(value[i*bin_p:(i+1)*bin_p])
    return value_s

def check_str_excess(Dtau,Gc,mu,lamda,min_excess):
    P_num    = Dtau.shape[0]
    Str_drop = np.zeros((P_num))
    for i in range(P_num):
        if(Gc[i]<0.0):
             print("There are negative Gc")
             exit()
        Str_drop[i] = (2*Gc[i]*mu/lamda)**0.5
        if(Str_drop[i]<(1+min_excess)*Dtau[i]):
             Gc[i] = max(((1+min_excess)*Dtau[i])**2.0*(lamda/mu/2.0),0.5e6)
    return Gc

def slip2tau(X,D,W,mu):
    dx  =  (X[1]- X[0])*1e3
    D_l =  np.concatenate((np.zeros((D.shape)),D,np.zeros((D.shape))))

    points =  D_l.shape[0]
    kw     =  np.pi/W/2.0
    omega  =  fftpack.fftfreq(points,dx) * 2*np.pi
    U      =  fftpack.fft(D_l)
    TAU    =  -0.5 * mu * np.sqrt(omega**2+kw**2) * U
    Dtau_l =  np.real(fftpack.ifft(TAU))
    Dtau   =  - Dtau_l[D.shape[0]:2*D.shape[0]]

    Dtau[0]  = Dtau[1]
    Dtau[-1] = Dtau[-2]
    Dtau[np.where(Dtau>4e6)] = 4e6   ###  Limit the untrue maximum stress drop
    return Dtau

def Adjust_gc(vr2_0,vr2_1,vr_ite,g0,ave_len,win_old,amp_old,trapped,Accuracy):
    A           =  1
    gamma       =  1/np.pi
    Jacobian    =  2*A*ave_len/gamma
    step_length =  1.0
    update      =  (vr2_1**2-vr2_0**2)/Jacobian * step_length * amp_old

    ##  Convergence condition
    fitting =  abs(vr2_1**2-vr2_0**2)

    if(len(np.where(fitting[win_old::]>Accuracy)[0])==0): ## Finish
         return 0.0,fitting.shape[0]-1,0.0

    if(fitting[win_old]<=Accuracy):
        win_new  =  win_old + np.where(fitting[win_old::]>Accuracy)[0][0]
        if(vr_ite[win_new-1]>=1):  # To avoid the numerical error of vr>1
            amp_new = 50.0
        else:
            amp_new = 1.0/(1-(vr_ite[win_new-1])**2)**1.5
    else:
        win_new     =  win_old
        if(trapped):
           amp_new  =  amp_old / 2.0
        else:
           amp_new  =  amp_old

    if(vr_ite[min(win_new+1,vr_ite.shape[0])]<0.1 and vr2_1[win_new]>vr2_0[win_new]):  # If the rupture arrests at the next bin and vr2_1 is still vr2_0, skip this bin
        win_new  =  win_new + 1
        amp_new  =  1.0

    update       =  (vr2_1**2-vr2_0**2)/Jacobian * step_length * amp_new
    Delta_gc     =  update[win_new]*g0[win_new]
    if(abs(Delta_gc)/g0[win_new]>0.1):
        amp_new  =  amp_new  / float(int(abs(Delta_gc)/g0[win_new]/0.1)+1)
        Delta_gc =  Delta_gc / float(int(abs(Delta_gc)/g0[win_new]/0.1)+1)

    return Delta_gc,win_new,amp_new

def Adjust_Dtau(slip_0,slip_n1,Dtau,tip,W,Accuracy):
    X         = slip_0[:,0]
    D_0       = slip_0[:,1]
    D_n1      = slip_n1[:,1]
    Adj_Dtau  = np.zeros((Dtau.shape[0]))

    for i in range(X.shape[0]):
        if(abs(D_0[i]-D_n1[i])<Accuracy*D_n1[i] or i<tip):
            Adj_Dtau[i] = 0.0
        else:
            Adj_Dtau[i] = np.pi/4.0*30e9*(D_0[i]-D_n1[i])/W
    smooth_sigma = 0.1 * W/(X[1]-X[0])/1e3
    Adj_Dtau = filters.gaussian_filter1d(Adj_Dtau,  smooth_sigma, mode='nearest')
    Adj_Dtau = Adj_Dtau + Dtau
    return Adj_Dtau

def set_para(model,iteration,W,Vs,ave_len,lamda,debug):
    slip_cutoff    = 0.003
    update_cutoff  = 0.005
    min_excess     = 0.1
    mu             = 30e9

    slip_0 = read_slip(model,ave_len,0)
    STF_0  = read_STF(model,ave_len,0)
    X      = slip_0[:,0]
    D_0    = slip_0[:,1]
    Dtau_0 = slip2tau(X,D_0,W,mu)
    P_num  = X.shape[0]
    DeltaX = (X[1]-X[0])*1e3
    bin_p  = int(ave_len*W/DeltaX)
    bin_n  = int(P_num/bin_p)
    g0_0   = ave_bins(0.5*D_0*Dtau_0,W,bin_p)

    X0          = 20.0
    T0          = slip_0[int(np.where(X==X0)[0]),2]
    Vr_0,RupT_0 = dynamic_time_warping(slip_0,STF_0,X0,T0,0.1*Vs)
    Vr_0   = Vr_0 / Vs

    gc_0   = np.zeros((bin_n))
    gc_0[:]= 1.9e6 * 0.8
    Gc_0   = interpolation(gc_0,W,P_num)
    Gc_0   = check_str_excess(Dtau_0,Gc_0,mu,lamda,min_excess)

#    ###   Keep the nucleation condition the same
    nuc_end = int(np.where(X==W/1e3)[0])
    Dtau_0[0:nuc_end] = 2.12078e6

    if(iteration==1):
        vr2_0   = checkpoints(Vr_0,bin_p,0,0,DeltaX,Vs) 
        win     = np.array([int(1/ave_len)])
        amp     = np.array([1.0])
        vr2     = np.reshape(vr2_0, (bin_n,1))
        gc      = np.reshape(gc_0,  (bin_n,1))
        Dtau    = np.reshape(Dtau_0,(P_num,1))
        Vr      = np.reshape(Vr_0,  (P_num,1))
        RupT    = np.reshape(RupT_0,  (P_num,1))
        if(debug):
            print("X    vr2  Gc")
            for i in range(bin_n):
                print(i,'{:.4f}'.format(vr2_0[i]),'{:.4f}'.format(Gc_0[i]/1e6))
            return
        else:
            save_record(model,ave_len,iteration,bin_n,P_num,win,amp,vr2,gc,Dtau,Vr,RupT)
        return X,Dtau_0,Gc_0
    else:
        last_ite,bin_n,win,amp,vr2,gc,Dtau,Vr,RupT  = read_record(model,ave_len)

        slip_1   = read_slip(model,ave_len,iteration-1)
        STF_1    = read_STF(model,ave_len,iteration-1)
#        T0       = slip_1[int(np.where(X==X0)[0]),2]
        Vr_1,RupT_1  = dynamic_time_warping(slip_0,STF_1,X0,T0,0.1*Vs)
        Vr_1     = Vr_1 / Vs
        RupT_syn = slip_1[:,2]
        vr_ite   = ave_bins(slip_1[:,3]/Vs,W,bin_p)
        rup_stop = np.where(vr_ite>0.001)[0][-1]<bin_n-1

        if(win[iteration-2]<=1):
            offset = 0.0
        else:
            offset = RupT_syn[bin_p*(win[iteration-2]-1)]-RupT_1[bin_p*(win[iteration-2]-1)]
            if(offset<0): offset = 0.0
        vr2_0    = checkpoints(Vr_0,bin_p,win[iteration-2],offset,DeltaX,Vs) 
        vr2_1    = checkpoints(Vr_1,bin_p,win[iteration-2],offset,DeltaX,Vs)
        vr2[win[iteration-2]::,0] = vr2_0[win[iteration-2]::]

        Dtau_1   = Dtau[:,iteration-2]     # Shear stress for the last iteration
        if(not rup_stop):              # Only update the complete rupture
            Adj_Dtau = Adjust_Dtau(slip_0,slip_1,Dtau_1,bin_p*(win[iteration-2]),W,slip_cutoff)   # Lock the stress of previous faults
        else:
            Adj_Dtau = Dtau_1 

        gc_1     = gc[:,iteration-2]       # Gc for the last iteration
        if(len(np.where(win[0:iteration-1]==win[iteration-2])[0])<5):
            trapped = False
        else:
            if((gc[win[iteration-2],iteration-2]-gc[win[iteration-2],iteration-3])*(gc[win[iteration-2],iteration-3]-gc[win[iteration-2],iteration-4])<0):
                trapped = True
            else:
                trapped = False
        delta_gc,win_new,amp_new = Adjust_gc(vr2_0,vr2_1,vr_ite,g0_0,ave_len,win[iteration-2],amp[iteration-2],trapped,update_cutoff)
        adj_gc                   = np.copy(gc_1)
        adj_gc[win_new::]        = adj_gc[win_new::] + delta_gc    # Keep all the last bins the same as the sliding one
        Adj_Gc                   = interpolation(adj_gc,W,P_num)
        Adj_Gc                   = check_str_excess(Adj_Dtau,Adj_Gc,mu,lamda,min_excess)

###   Keep the nucleation condition the same
        Adj_Dtau[0:nuc_end] = 2.12078e6
        Adj_Gc[0:nuc_end]   = 1.9e6 * 0.8

        if(debug):
            adj_dtau        = ave_bins(Adj_Dtau,W,bin_p)
            dtau            = ave_bins(Dtau_1,W,bin_p)
            lorentz         = 1/(1-(vr_ite/Vs)**2)**1.5
            print("Bin_num   vr2_0  vr_1  vr_ite Delta_gc Delta_dtau")
            for i in range(bin_n):
                if(i>win_new+2): continue
                if(i==win_new):
                    print(i,'{:.4f}'.format(vr2_0[i]),'{:.8f}'.format(vr2_1[i]),\
                            '{:.8f}'.format(vr_ite[i]),'{:.8f}'.format((adj_gc[i]-gc_1[i])/1e6),\
                            '{:.4f}'.format((adj_dtau[i]-dtau[i])/adj_dtau[i]),'{:.8f}'.format(((adj_gc[i]-gc_1[i])/gc_1[i])/((vr2_1[i]-vr2_0[i])/vr2_0[i])))
                else:
                    print(i,'{:.4f}'.format(vr2_0[i]),'{:.8f}'.format(vr2_1[i]),\
                            '{:.8f}'.format(vr_ite[i]),'{:.8f}'.format((adj_gc[i]-gc_1[i])/1e6),\
                            '{:.4f}'.format((adj_dtau[i]-dtau[i])/adj_dtau[i]))
            print(amp_new)
            print(offset)
        else:
            if(win.shape[0]>iteration-1):
                win = win[0:iteration-1]
                amp = amp[0:iteration-1]
                vr2 = vr2[:,0:iteration-1]
                gc  = gc[:,0:iteration-1]
                Dtau= Dtau[:,0:iteration-1]
                Vr  = Vr[:,0:iteration-1]
                RupT= RupT[:,0:iteration-1]
            win     = np.hstack((win, np.array([win_new])))
            amp     = np.hstack((amp, np.array([amp_new])))
            vr2     = np.column_stack((vr2, vr2_1))
            gc      = np.column_stack((gc, adj_gc)) 
            Dtau    = np.column_stack((Dtau, Adj_Dtau)) 
            Vr      = np.column_stack((Vr, Vr_1)) 
            RupT    = np.column_stack((RupT, RupT_1)) 

            save_record(model,ave_len,iteration,bin_n,P_num,win,amp,vr2,gc,Dtau,Vr,RupT)
        return X,Adj_Dtau,Adj_Gc
    

if __name__ == '__main__':
    import sys
    W  = 20e3
    Vs = 3330.0
    lamda   = 4e3
    model     = sys.argv[1]
    ave_len   = float(sys.argv[2])
    iteration = int(sys.argv[3])

    set_para(model,iteration,W,Vs,ave_len,lamda,True)

