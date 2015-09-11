#!/usr/bin/python
# file: run_netperf.py
# desc: script launches netperf and records output data.  
#

import os,sys,imp
from subprocess import Popen, PIPE, STDOUT
import time
from datetime import datetime
import threading
from math import sqrt

#import pexpect (assumes pexpect.py is in the same directory as script
scriptPath = os.path.abspath(sys.argv[0])
scriptName = scriptPath.split("/")[-1]
scriptDirectory = scriptPath.split(scriptName)[0]
outputDir = "/root/results/"
imp.load_source('pexpect', '../util/pexpect-2.4/pexpect.py')
import pexpect

# control/output globals 
DEBUGMODE=False
DRYRUN=False
VERBOSITY=2
WRITE_OUTPUT=True
FASTMODE=False


# netperf variables: 
vtType = "docker"
numReps = 20
serverPort = 65432
bridgedIP = "192.168.42.242"
directPyhsIP = "192.168.3.1"
interfaceList = [bridgedIP, directPyhsIP]
testList = [ "TCP_RR", "TCP_STREAM"]# [ "TCP_RR", "TCP_STREAM"]
keyStr = pexpect.EOF
confidenceInterval = "-I 99,5"
testDuration = "" # "-l 1" # "-l 10" # 10 seconds is standard, use 1 for quick debugging 
if FASTMODE: 
    numReps=2
    testDuration="-l 1"
    interfaceList = [bridgedIP] 
    testList = ["TCP_RR"]


if WRITE_OUTPUT: 
    timestamp = datetime.now().strftime("%Y%m%d_%H%M")
    outputFile = (outputDir + vtType + "_" + timestamp + ".dat")
    fHandle = open(outputFile, 'w')

class Dataset(object):
    def __init__(self, vtType=None, nettype=None, test=None, command=None, rawdata=[], timestamp=None):
        self.vtType = vtType 
        self.nettype = nettype
        self.test = test
        self.command = command
        self.rawdata = rawdata
        self.timestamp = timestamp

def buildNetperfCommand(serverIP, serverPort, test): 
    command=""
    if( test == "TCP_RR"): 
        command=buildRRCommand(serverIP, serverPort)
    elif (test == "TCP_STREAM"): 
        command=buildStreamCommand(serverIP, serverPort)
    elif (test == "TCP_RR_CI"): 
        command=buildRRCommand(serverIP, serverPort, confidenceInterval)
    elif (test == "TCP_STREAM_CI"): 
        command=buildStreamCommand(serverIP, serverPort, confidenceInterval)
    return command

def buildStreamCommand(serverIP, serverPort, CI=""):
    #  ./netperf -H 192.168.42.242 -p 65432 -v 2 -t TCP_STREAM
    verbosity="-v 2"
    test="-t TCP_STREAM"
    netperfCmd = ("./netperf {0} -H {1} -p {2} {3} {4} {5}").format(testDuration, 
            serverIP, serverPort, verbosity, CI, test)
    return netperfCmd

def buildRRCommand(serverIP, serverPort, CI=""):
    #  ./netperf -H 192.168.42.242 -p 65432 -v 4 -t TCP_RR -- -r 1,1
    verbosity="-v 4"
    test="-t TCP_RR"
    rr_size="-r 1,1"
    netperfCmd = ("./netperf {0} -H {1} -p {2} {3} {4} {5} -- {6} ").format(testDuration, 
            serverIP, serverPort, verbosity, CI, test, rr_size )
    return netperfCmd

def runCommand(command, keyStr, timeOut=30): 
    output=[command]
    if not(DRYRUN): 
        localThread = pexpect.spawn(command)
        localThread.expect(keyStr, timeout=timeOut)
        if VERBOSITY > 1: 
            output = localThread.before + "\n" + "Complete at " + str(datetime.now()) + "\n"
    return output

def getKernelInfo():
    command = "uname -a"
    multiPrint(runCommand(command, pexpect.EOF), 1) 
    command = "cat /proc/cmdline" 
    multiPrint(runCommand(command, pexpect.EOF), 1) 
    return

def mean(data): 
    sum=0.0
    for item in data: 
        sum += item 
    return (sum/len(data))

def stddev(data): 
    avg=mean(data)
    sumres=0
    for item in data: 
        resid = (item - avg)
        sumres+=(resid * resid)
    return sqrt(sumres / ((len(data)*1.0) - 1.0) )

def parseStream(inputData): 
    bwList=[]
    for datum in inputData.rawdata: 
        rows = datum.split("\r\n")
        #for ix,row in enumerate(rows): 
        #    print ix,row 
        raw = rows[6].split()
        bwList.append(float(raw[4]))
    return bwList, mean(bwList), stddev(bwList)

def parseRR(inputData):
    if len(inputData.rawdata) > 1: 
        latList=[]
        for datum in inputData.rawdata: 
            rows = datum.split("\r\n")
            #for ix,row in enumerate(rows): 
            #    print ix,row 
            raw = rows[4].split()
            latList.append(float(raw[4]))
    else: 
        datum=inputData.rawdata
        rows = datum.split("\r\n")
        for ix,row in enumerate(rows): 
            print ix,row 
        latList=[1,1]
    return latList, mean(latList), stddev(latList)

def multiPrint(thisString, level=0): 
    if VERBOSITY > level: 
        print(thisString)
    if WRITE_OUTPUT: 
        fHandle.write(thisString+"\n")
    return


def main(): 
    # TODO this needs to run on the remote host : getKernelInfo()
    results = []
    # TODO Add ability to hava a pool of threads running netperf client 
    for interfaceIP in interfaceList:
        for test in testList: 
            command = buildNetperfCommand(interfaceIP, serverPort, test)
            # run each test 20 times
            rawdata = []
            for rep in range(numReps): 
                timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                multiPrint("{0}: Running test: {1}, {2}, rep {3}/{4}".format(timestamp, interfaceIP, test, rep+1, numReps), 0)
                multiPrint(command, 1)
                rawdata.append( runCommand(command, keyStr) )
                time.sleep(1) 
                multiPrint(rawdata[-1], 2)
            results.append(Dataset(vtType, interfaceIP, test, command, rawdata, timestamp ) )
    
# TODO: need a better parser to handle CI-variants
#            # run CI-tests
#            command = buildNetperfCommand(interfaceIP, serverPort, test+"_CI")
#            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
#            multiPrint("{0}: Running test: {1}, {2}, rep {3}/{4}".format(timestamp, interfaceIP, test+"_CI", 1, 1), 0)
#            multiPrint(command, 1)
#            rawdata.append( runCommand(command, keyStr, 120) )
#            time.sleep(1) 
#            multiPrint(rawdata[-1], 2)
#            results.append(Dataset(vtType, interfaceIP, test+"_CI", command, rawdata, timestamp ) )
    
    print("\n\nResults Summary: ")
    for data in results: 
        multiPrint("\nvtType: {0}, IP: {1}:{2}, {3} @ {4} ".format(data.vtType, data.nettype, serverPort, data.test, data.timestamp), 0)
        if data.test == "TCP_STREAM": 
            bandwidth, avg, std = parseStream(data)
            multiPrint("Count={0}, Mean={1}, stddev={2}".format(len(bandwidth), avg, std), 0)
            multiPrint(str(bandwidth), 1)
        elif data.test == "TCP_RR": 
            latency, avg, std = parseRR(data)
            multiPrint("Count={0}, Mean={1}, stddev={2}".format(len(latency), avg, std), 0)
            multiPrint(str(latency), 1)
    
    multiPrint("\nTesting complete at {0} for {1}, ".format(datetime.now().strftime("%Y-%m-%d %H:%M:%S"), vtType), 0)
    multiPrint("Data written to {0}".format(outputFile), 0 )
    print("")

    if WRITE_OUTPUT:
        fHandle.close
    
# end main()

if __name__ == '__main__':
    multiPrint("command line arguments: "+str(sys.argv), 3)
    main()

