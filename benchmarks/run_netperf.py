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

#import pexpect (assumes pexpecf.py is in the same directory as script
scriptPath = os.path.abspath(sys.argv[0])
scriptName = scriptPath.split("/")[-1]
scriptDirectory = scriptPath.split(scriptName)[0]
imp.load_source('pexpect', '../util/pexpect-2.4/pexpect.py')
import pexpect

DEBUGMODE=False
DRYRUN=False

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
        command=buildRRCommand(serverIP, serverPort, "-I 99,5")
    elif (test == "TCP_STREAM_CI"): 
        command=buildStreamCommand(serverIP, serverPort, "-I 99,5")
    return command

def buildStreamCommand(serverIP, serverPort, CI=""):
    #  ./netperf -H 192.168.42.242 -p 65432 -v 2 -t TCP_STREAM
    verbosity="-v 2"
    test="-t TCP_STREAM"
    netperfCmd = ("./netperf -l 1 -H {0} -p {1} {2} {3} {4}").format(serverIP, 
            serverPort, verbosity, CI, test)
    return netperfCmd

def buildRRCommand(serverIP, serverPort, CI=""):
    #  ./netperf -H 192.168.42.242 -p 65432 -v 4 -t TCP_RR -- -r 1,1
    verbosity="-v 4"
    test="-t TCP_RR"
    rr_size="-r 1,1"
    netperfCmd = ("./netperf -l 1 -H {0} -p {1} {2} {3} {4} -- {5} ").format(serverIP, 
            serverPort, verbosity, CI, test, rr_size )
    return netperfCmd

def runCommand(command, keyStr, timeOut=30): 
    output=[command]
    if not(DRYRUN): 
        localThread = pexpect.spawn(command)
        localThread.expect(keyStr, timeout=timeOut)
        output = localThread.before + "\n" + "Complete at " + str(datetime.now())
    return output

def parseStream(data): 
    print ("\n{0}\n".format(data.rawdata))
    return 0 

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

def calcStats(data):
    return mean(data), stddev(data)


def parseRR(intputData):
    latency=[]
    for datum in intputData.rawdata: 
        rows = datum.split("\r\n")
        #for ix,row in enumerate(rows): 
        #    print ix,row 
        raw = rows[4].split()
        latency.append(float(raw[4]))
    avg,std = calcStats(latency)
    return latency, avg, std


serverPort = 65432
bridgedIP = "192.168.42.242"
directPyhsIP = "192.168.3.1"
keyStr = pexpect.EOF

#command = buildStreamCommand(bridgedIP, serverPort)
#print(runCommand(command, keyStr) + "\n" )
#command = buildRRCommand(bridgedIP, serverPort)
#print(runCommand(command, keyStr) + "\n" )
#command = buildStreamCommand(directPyhsIP, serverPort)
#print(runCommand(command, keyStr) + "\n" )
#command = buildRRCommand(directPyhsIP, serverPort)
#print(runCommand(command, keyStr) + "\n" )

interfaceList = [bridgedIP] #, directPyhsIP]
testList = [ "TCP_RR"] #, "TCP_STREAM"]
vtType = "docker"
numReps = 4
results = []
for interfaceIP in interfaceList:
    for test in testList: 
        command = buildNetperfCommand(interfaceIP, serverPort, test)
        # run each test 20 times
        rawdata = []
        for rep in range(numReps): 
            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            print("{0}: Running test: {1}, {2}, rep {3}/{4}".format(timestamp, interfaceIP, test, rep+1, numReps))
            print(command)
            rawdata.append( runCommand(command, keyStr) )
            time.sleep(0.1) 
            print(rawdata[-1])
        results.append(Dataset(vtType, interfaceIP, test, command, rawdata, timestamp ) )

#        # run CI-tests
#        command = buildNetperfCommand(interfaceIP, serverPort, test+"_CI")
#        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
#        print("{0}: Running test: {1}, {2}, rep {3}/{4}".format(timestamp, interfaceIP, test+"_CI", 1, 1))
#        print(command )
#        rawdata.append( runCommand(command, keyStr, 120) )
#        time.sleep(0.1) 
#        print(rawdata[-1] )
#        results.append(Dataset(vtType, interfaceIP, test+"_CI", command, rawdata, timestamp ) )

print(len(results))
for data in results: 
    print("vtType: {0}, IP: {1}:{2}, {3} @ {4} ".format(data.vtType, data.nettype, serverPort, data.test, data.timestamp))
    if data.test == "TCP_STREAM": 
        parseStream(data)
    elif data.test == "TCP_RR": 
        latency, avg, std = parseRR(data)
        print("Mean={0}, stddev={1}".format(avg, std))


    

# TODO Add ability to hava a pool of threads running netperf client 

