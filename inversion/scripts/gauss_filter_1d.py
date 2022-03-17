import fileinput
import numpy
from scipy.interpolate import griddata
import scipy.ndimage.filters


lines=[]
for line in fileinput.input():
	lines.append(line.rstrip().split(" "))

data = numpy.array(lines)
data = data.astype(numpy.float)

smooth_data = scipy.ndimage.filters.gaussian_filter1d(data[:,1], sigma = 48)
for i in range(data.shape[0]):
    print data[i,0],smooth_data[i]
