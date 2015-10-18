#!/usr/bin/env python

import os,sys
import matplotlib

# Order matters here, we want to render graphs to .png
matplotlib.use("agg")
import matplotlib.pyplot as plt
from pylab import *
import numpy as np
import arguments as args


def main():
    """docstring for main"""
    varargin, nargin = args.getArgs()
    if nargin > 1 : 
        filename = varargin[1]
    else: 
        filename = args.selectFile('.column')  # 'ICMP_raw.dat'

    with open(filename) as f:
        header = f.readline()
        data = f.read()
    labels = header.split()

    numCols = len(labels)
    print("{0} columns found: {1}".format(numCols, labels))
    
    datasets = {}
    for datatype in labels: 
        datasets[datatype] = []

    data = data.split('\n')
    print("{0} data points found".format(len(data)))
    for row in data:
        temp = row.split()
        if (len(temp)>0 ):
            if (temp[0][0].isdigit()): 
                for i in range(0,numCols):
                    datasets[labels[i]].append(float(temp[i]))
            else: 
                print("{0} <{1}>, digit: {2}, type={3}".format(temp[0], temp[0][0], 
                    temp[0].isdigit(), type(temp[0])))
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
    ylabel("Latency (ms)")
    title("ICMP latency for various systems")
    legend(labels)
    ax = fig.gca()
    ax.set_ylim(0,0.2)
    show()
    image_name = os.path.basename(filename).replace(".", "_") + ".png"
    fig.savefig(image_name)


#    return data

if __name__ == '__main__':
    main()
