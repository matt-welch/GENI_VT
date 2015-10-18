#!/usr/bin/python
'''
File: simplePlotsModule.py
Author: Matt Welch
Description: This module uses the matplotlib, pyplot, and numpy libraries to make simple plots
'''

# import OS module for file handling
import os
import sys
# import csv module for parsing data from csv's
import csv
import arguments as args
#  libraries for plotting: 
import numpy as np
import matplotlib
# Order matters here, we want to render graphs to .png
if os.environ.get('DISPLAY') == None:
    # use the Anti-Grain Geometry (agg) backend if no display set, i.e. on ssh terminal
    matplotlib.use("agg")

import matplotlib.pyplot as plt

nFigures=0
DEBUG_MODE = False

########################################

def seriesGraph(valueList, ylabel='', suffix='', infile='data'):
    # Uses matplotlib to plot a time-series plot of  a list of data
    # global: infile (data filename), nFigures (number of plotted figures)
    # input: 
    #   valueList: list of data to plot
    #   ylabel: should be the units of the data (e.g. 'Latency (us)')
    #   suffix: a string to place in the filename (potentially describing the plotted data)
    #   infile: the name of the input datafile (e.g. 'somedata.dat')

    global nFigures
    nFigures += 1
    if len(suffix)>0:
        suffix = "_" + suffix
    data = np.array(valueList)
    fig = plt.figure(nFigures)
    plt.plot(data,'bo-')
    plt.ylabel(ylabel)
    plt.xlabel('#')
    image_name = os.path.basename(infile).replace(".", "_") + suffix + ".png"
    plt.show(block=False)
    fig.savefig(image_name)
    print "Wrote " + image_name

########################################

def scatterGraph(xVals, yVals, xlabel='', ylabel='', suffix='', infile='data'):
    # Uses matplotlib to make a scatter plot of a pair-wise list of data
    # global: infile (data filename), nFigures (number of plotted figures)
    # input: 
    #   xVals: list of x-values data to plot
    #   yVals: list of y-values data to plot
    #   xlabel: should be the units of the x-data (e.g. 'Timestamp (s)')
    #   ylabel: should be the units of the y-data (e.g. 'Latency (us)')
    #   suffix: a string to place in the filename (potentially describing the plotted data)
    #   infile: the name of the input datafile (e.g. 'somedata.dat')

    global nFigures
    nFigures += 1
    if len(suffix)>0:
        suffix = "_" + suffix
    if len(yVals) == 0:
        # no yData was supplied, assume it to be monotonic and just use the index
        yData = range(1,len(xData))

    xData = np.array(xVals)
    yData = np.array(yVals)
    fig = plt.figure(nFigures)
    # print len(xData), len(yData)
    plt.plot(xData,yData,'bo-')
    plt.xlabel(xlabel)
    plt.ylabel(ylabel)
    plt.xlabel('#')
    image_name = os.path.basename(infile).replace(".", "_") + suffix + ".png"
    plt.show(block=False)
    fig.savefig(image_name)
    print "Wrote " + image_name

########################################
def calcStats(data):
    # assume data is a np.array
    # returns set of statistics 
    count = len(data)
    if DEBUG_MODE:
        print(  "{0}::{1}():: data = {2}".format(__name__, sys._getframe().f_code.co_name, data) )
    (lmax, lmin, lmean) = (np.max(data), np.min(data), np.mean(data))
    lmed = np.median(data)
    p_9999, p_99999, p_999999 = np.percentile(data, [99.99, 99.999, 99.9999])
    return count,lmin,lmed,lmean,lmax,p_9999,p_99999,p_999999


########################################
def histogram(valueList, xlabel='', suffix='', logPlot=False , infile='data'):
    # Uses matplotlib and numpy to calculate a histogram of a list of data
    # input: 
    #   valueList: list of data to plot
    #   xlabel: should be the units of the data (e.g. 'Latency (us)')
    #   suffix: a string to place in the filename (potentially describing the plotted data)
    #   logPlot: determines if the y-axis of the histpgram will be log(T) or linear(F)
    #   infile: the name of the input datafile (e.g. 'somedata.dat')

    global DEBUG_MODE
    if len(suffix)>0:
        suffix = "_" + suffix

    global nFigures
    nFigures += 1
    if DEBUG_MODE: 
        print "Infile = \'{0}\'".format(infile)

    data = np.array(valueList)
    comment = ""

    count,lmin,lmed,lmean,lmax,p_9999,p_99999,p_999999 = calcStats(data)
    # create histogram
    fig = plt.figure(nFigures)
    if ( comment != None ):
        comment += (" 99.99=%.1f, 99.999=%.1f, 99.9999=%.1f" % (p_9999, p_99999, p_999999))
        fig.add_axes((.1,.2,.8,.7))   # l,b,w,h
        fig.text(.1, .1, comment)
    num_bins = min(np.unique(data).size, 100)

    n, bins, patches = plt.hist(data, num_bins, facecolor="blue",
        edgecolor="grey", log=logPlot)
       # histtype="stepfilled", log=True) 

    # color bars by percentile
    for patch, right, left in zip(patches, bins[1:], bins[:-1]) :
        if right < p_9999 :
            patch.set_facecolor('red')
        elif right < p_99999 :
            patch.set_facecolor('green')

    plt.xlabel(xlabel)
    plt.ylabel("Num samples")
    plt.title("N=%d, avg %1.2f, med %1.2f, min %1.2f, max %1.2f"
        % (len(data), lmean, lmed, lmin, lmax))
    plt.grid(True)
    plt.show(block=False)
    image_name = os.path.basename(infile).replace(".", "_") + suffix + ".png"
    
    fig.savefig(image_name)
    print "Wrote " + image_name
    return count,lmin,lmed,lmean,lmax,p_9999,p_99999,p_999999

def extractDataFromFile(infilename):
    '''
    File: simplePlotsModule.py
    Author: Matt Welch
    Description: attempts to extract columnar data from file
    '''
    if "csv" in infilename: # TODO: coarse selection - could be smarter
        data = columnFromCSV(infilename)
    else: 
        data = columnFromDAT(infilename)

    return data
    # end extractDataFromFile() definition

def columnFromDAT(infilename):
    '''
    File: simplePlotsModule.py
    Author: Matt Welch
    Description: assumes two-column file, returns second column
    '''
    data=[]
    with open(infilename, 'rb') as infile:
        for row in infile: 
            #print("row:  {0}".format(row))
            #print(" row[1]: {0}".format(row.split()[1])) 
            data.append(float(row.split()[1]))
    return data
    # end columnFromDAT() definition

def columnFromCSV(infilename, columnName='trange', dtype='i'):
    '''
    File: simplePlotsModule.py
    Author: Matt Welch
    Description: assumes csv has one-row header
    '''
    data=[]

    with open(infilename, 'rb') as infile:
        if dtype == 'i':
            for row in csv.DictReader(infile):
                data.append(int(row[columnName]))
        elif dtype == 'f':
            for row in csv.DictReader(infile):
                data.append(float(row[columnName]))
        else: 
            assert (dtype == 'i' or dtype == 'f'), "Data Type specified ('{0}') is not valid".format(dtype)
    if DEBUG_MODE:
        print(  "{0}::{1}():: data = {2}".format(__name__, sys._getframe().f_code.co_name, data) )
    return data

def deleteHeaderLines(infilename):
    fn = infilename
    f = open(fn)
    output = []
    for line in f:
        if (line[0] == ' ' or line[0].isdigit() ) :
            # only retain lines of the file that begin with a space
            output.append(line)
    f.close()
    newfname = fn + '.csv'
    print("Saving '{0}' as '{1}'".format(fn, newfname))
    fcsv = open(newfname, 'w')
    fcsv.writelines(output)
    fcsv.close()

def removeHighValues(data, limit=1000000):
    initCount = len(data)
    data = [x for x in data if x < limit] # list comprehension 
    finalCount = len(data)
    numRemoved = initCount - finalCount
    pctRemoved = float(numRemoved) / float(initCount) * 100
    print "{0} values ({2:2.1f}%) removed above {1}".format(numRemoved, limit, pctRemoved)
    return data

def removeValues(data, indices):
    #print "typeof indices = ", type(indices)
    #print indices[0]
    if indices!=None and len(indices) > 0 :
        #print "removing values"
        for i in sorted(indices, reverse=True):
            #print type(i), i
            del(data[i])
    return data

def removeSpikes(xdata, limit, ydata=[]):
    initCount = len(xdata)
    indices = findSpikes(xdata, limit)
    xdata = removeValues(xdata, indices)
    if len(ydata) > 0:
        ydata = removeValues(ydata, indices)
    numRemoved = len(indices)
    pctRemoved = float(numRemoved) / float(initCount) * 100
    print "{0} values ({2:2.1f}%) removed above {1}".format(numRemoved, limit, pctRemoved)
    return xdata, ydata

def removeLowValues(xdata, limit=0):
    if DEBUG_MODE:
        print(  "{0}::{1}():: xdata = {2}".format(__name__, sys._getframe().f_code.co_name, xdata) )
    initCount = len(xdata)
    xdata = [x for x in xdata if x >= limit] # list comprehension 
    finalCount = len(xdata)
    print "{0} values removed below {1}".format(initCount-finalCount, limit)
    if DEBUG_MODE:
        print(  "{0}::{1}():: xdata = {2}".format(__name__, sys._getframe().f_code.co_name, xdata) )
    return xdata

def gte(value,limit): return value >= limit

def lte(value,limit): return value <= limit

def gt(value, limit): return value > limit

def lt(value, limit): return value < limit

def findSpikes(data, limit=0):
    spikes=[]
    indices = []
    for i in range(0,len(data)): 
        item = data[i]
        if item > limit: 
            spikes.append(item)
            indices.append(i)
    #print "findSpikes:: typeof(indices) = ",type(indices)
    #print "findSpikes:: typeof(spikes) = ",type(spikes)
    return indices, spikes

def findLows(data, limit=0):
    lows=[]
    indices = []
    for i in range(0,len(data)): 
        item = data[i]
        if item < limit: 
            lows.append(item)
            indices.append(i)
    #print "findLows:: typeof(indices) = ",type(indices)
    #print "findLows:: typeof(lows) = ",type(lows)
    return indices, lows

def firstDiff(data):
    if DEBUG_MODE:
        print(  "{0}::{1}():: data = {2}".format(__name__, sys._getframe().f_code.co_name, data) )
    if len(data) < 2:
        print("Error: in firstDiff(): data list is too short to calculate 1st diff")
        return 0
    diffs = []
    for i in range(1,len(data)):
        diffs.append(data[i] - data[i-1])
    return diffs

def secondDiff(data):
    if len(data) < 3:
        print("Error: in secondDiff(): data list is too short to calculate 2nd diff")
        return 0
    diff1 = firstDiff(data)
    diff2 = firstDiff(diff1)
    return diff2

def add(x,y): return x+y

def sum(data):
    if DEBUG_MODE:
        print(  "{0}::{1}():: data = {2}".format(__name__, sys._getframe().f_code.co_name, data) )
    total = reduce(add, data)
    # print("Sum = {0:0.3f}".format(total))
    return total

def mean(data):
    myMean = float(sum(data)) / float(len(data))
    return myMean

def main():
    """This main function plots a series graph and a histogram of a vector"""
    dataLabel = "values"
    FILTER_FLAG = False
    varargin, nargin = args.getArgs()
    if nargin > 1:
        infilename = varargin[1]
    else: 
        infilename = args.selectFile('.dat')

    print("Extracting data from '{0}'...".format(infilename))
    data = extractDataFromFile(infilename)
    print("Data extraction complete.")


    if FILTER_FLAG: 
        limit = 200
        print("Removing values above {0}".format(limit))
        data = removeHighValues(data, limit)

    if len(data) < 100000: 
        seriesGraph(data, dataLabel, 'series', infilename)


    histogram(data, dataLabel, 'hist', True, infilename)


if __name__ == "__main__":
   main() 
   
  
  
