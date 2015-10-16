#!/usr/bin/env python

import os,sys
import matplotlib

# Order matters here, we want to render graphs to .png
matplotlib.use("agg")
import matplotlib.pyplot as plt
from pylab import *
import numpy as np



def main():
    """docstring for main"""
    filename = 'ICMP_raw.dat'
    with open(filename) as f:
        header = f.readline()
        data = f.read()
    print header
    labels = header.split()

    numCols = len(labels)
    datasets = {}
    for datatype in labels: 
        datasets[datatype] = []

    data = data.split('\n')
    for row in data:
        temp = row.split()
        if (len(temp)>0 and temp[0].isdigit()): 
            for i in range(0,4):
                datasets[labels[i]].append(float(temp[i]))
    #for datatype in labels: 
    #    datasets[datatype] = np.array(datasets[datatype])
    #    figure()
    #    boxplot(datasets[datatype])
    #    title(datatype)
    alldata = []
    titlestr = ''
    for column in datasets.iteritems():
        alldata.append(column[1])
        titlestr = titlestr + ' ' + column[0]
    print alldata
    fig = figure()
    boxplot(alldata)
    xlabel("System type")
    ylabel("Latency (us)")
    title("ICMP latency for various systems")
    show()
    image_name = os.path.basename(filename).replace(".", "_") + ".png"
    fig.savefig(image_name)


#    return data

if __name__ == '__main__':
    main()
