#!/usr/bin/python
# file: run_netperf.py
# desc: script launches netperf and records output data.  
#

import os,sys,imp
from subprocess import Popen, PIPE, STDOUT
import time
from datetime import datetime, timedelta
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
vtType = "vm_rt_br-pf"
numReps = 20
serverPort = 65432
localhost="127.0.0.1"
bridgedIP = "192.168.2.21"
directPyhsIP = "192.168.3.21"
directVFIP = "192.168.4.21"
interfaceList = [bridgedIP, directPyhsIP] # [bridgedIP, directPyhsIP]
testList = ["UDP_RR", "UDP_STREAM", "TCP_RR", "TCP_STREAM"] # 
keyStr = pexpect.EOF
confidenceInterval = "-I 99,5"
# "-l 1" # "-l 10" # 10 seconds is standard, use 1 for quick debugging 
TEST_DURATION = 10
testDuration = "-l " + str(TEST_DURATION) 

if FASTMODE: 
    numReps=2
    TEST_DURATION=1
    testDuration="-l " + str(TEST_DURATION)
    interfaceList = [bridgedIP, directPyhsIP] 
    testList = ["UDP_STREAM"] # "UDP_STREAM",


def multiPrint(thisString, level=0): 
    if VERBOSITY > level: 
        print(thisString)
    if WRITE_OUTPUT: 
        fHandle.write(thisString+"\n")
    return

if WRITE_OUTPUT: 
    timestamp = datetime.now().strftime("%Y%m%d_%H%M")
    outputFile = (outputDir + vtType + "_" + timestamp + ".dat")
    fHandle = open(outputFile, 'w')
    multiPrint("Writing data to {0} ".format(outputFile),0)

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
        command=buildRRCmd(serverIP, serverPort, "TCP")
    elif (test == "TCP_RR_CI"): 
        command=buildRRCmd(serverIP, serverPort, "TCP", confidenceInterval)
    elif (test == "TCP_STREAM"): 
        command=buildStreamCmd(serverIP, serverPort, "TCP")
    elif (test == "TCP_STREAM_CI"): 
        command=buildStreamCmd(serverIP, serverPort, "TCP", confidenceInterval)
    elif( test == "UDP_RR"): 
        command=buildRRCmd(serverIP, serverPort, "UDP")
    elif (test == "UDP_RR_CI"): 
        command=buildRRCmd(serverIP, serverPort, "UDP", confidenceInterval)
    elif (test == "UDP_STREAM"): 
        command=buildStreamCmd(serverIP, serverPort, "UDP")
    elif (test == "UDP_STREAM_CI"): 
        command=buildStreamCmd(serverIP, serverPort, "UDP", confidenceInterval)
    return command

def buildStreamCmd(serverIP, serverPort, transport, CI=""):
    #  ./netperf -H 192.168.42.242 -p 65432 -v 2 -t TCP_STREAM
    verbosity="-v 2"
    test="-t " + transport + "_STREAM"
    netperfCmd = ("./netperf {0} {1} -H {2} -p {3} {4} {5}").format(test, 
            testDuration, serverIP, serverPort, verbosity, CI)
    return netperfCmd

def buildRRCmd(serverIP, serverPort, transport, CI=""):
    #  ./netperf -H 192.168.42.242 -p 65432 -v 4 -t TCP_RR -- -r 1,1
    verbosity="-v 4"
    if transport == "UDP": 
        verbosity="-v 2"
    test="-t " + transport + "_RR"
    rr_size="-r 1,1"
    netperfCmd = ("./netperf {0} {1} -H {2} -p {3} {4} {5} -- {6} ").format(test,
            testDuration, serverIP, serverPort, verbosity, CI, rr_size )
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

def debugPrintRows(rowList): 
    if DEBUGMODE: 
        print("Printing data contents")
        for ix,row in enumerate(rowList): 
            print ix,row 

def parseTCPStream(inputData): 
    bwList=[]
    for datum in inputData.rawdata: 
        rowList = datum.split("\r\n")
        debugPrintRows(rowList)
        row = rowList[6].split()
        bwList.append(float(row[4]))
    return bwList, mean(bwList), stddev(bwList)

def parseTCPRR(inputData):
    if len(inputData.rawdata) > 1: 
        latList=[]
        for datum in inputData.rawdata: 
            rowList = datum.split("\r\n")
            debugPrintRows(rowList)
            row = rowList[4].split()
            latList.append(float(row[4]))
    else: 
        datum=inputData.rawdata
        rowList = datum.split("\r\n")
        debugPrintRows(rowList)
        latList=[1,1]
    return latList, mean(latList), stddev(latList)

def parseUDPStream(inputData): 
    bwList=[]
    for datum in inputData.rawdata: 
        rowList = datum.split("\r\n")
        debugPrintRows(rowList)
        if "error" in rowList[1]: 
            # UDP_STREAM fails over bridge for some reason
            # set values to -1 
            row = [-1,-1,-1,-1,-1,-1]
        else: 
            row = rowList[5].split()
        bwList.append(float(row[5]))
    return bwList, mean(bwList), stddev(bwList)

def parseUDPRR(inputData):
    if len(inputData.rawdata) > 1: 
        latList=[]
        for datum in inputData.rawdata: 
            rowList = datum.split("\r\n")
            debugPrintRows(rowList)
            row = rowList[6].split()
            latency = 1.0 / float(row[5]) * 1000000 
            # row[5] is transactions per second, latency is period for 1 transaction
            latList.append(latency)
    else: 
        datum=inputData.rawdata
        rowList = datum.split("\r\n")
        debugPrintRows(rowList)
        latList=[1,1]
    return latList, mean(latList), stddev(latList)


def showResult(data): 
    multiPrint("\nvtType: {0}, IP: {1}:{2}, {3} @ {4} ".format(data.vtType, data.nettype, serverPort, data.test, data.timestamp), 0)
    if data.test == "TCP_STREAM": 
        bandwidth, avg, std = parseTCPStream(data)
        multiPrint("Count={0}, Mean={1}, stddev={2}".format(len(bandwidth), avg, std), 0)
        multiPrint(str(bandwidth), 1)
    elif data.test == "TCP_RR": 
        latency, avg, std = parseTCPRR(data)
        multiPrint("Count={0}, Mean={1}, stddev={2}".format(len(latency), avg, std), 0)
        multiPrint(str(latency), 1)
    elif data.test == "UDP_STREAM":
        bandwidth, avg, std = parseUDPStream(data)
        multiPrint("Count={0}, Mean={1}, stddev={2}".format(len(bandwidth), avg, std), 0)
        multiPrint(str(bandwidth), 1)
    elif data.test == "UDP_RR":
        latency, avg, std = parseUDPRR(data)
        multiPrint("Count={0}, Mean={1}, stddev={2}".format(len(latency), avg, std), 0)
        multiPrint(str(latency), 1)



def main(): 
    def showETC():
        # show Estimated Time to Completion
        global testsRemaining, timeRemaining
        testsRemaining -= 1
        timeRemaining = testsRemaining * TEST_DURATION + 1.1
        # additional second is because the tests take a little longer 
        completionTime = datetime.now() + timedelta(hours=0, minutes=0, seconds=timeRemaining)
        print("Estimated completion @ {0} : {1} tests, {2} s, {3:0.2f} min".format(completionTime, 
            testsRemaining, timeRemaining, timeRemaining / 60.0))

    results = []
    # TODO Add ability to hava a pool of threads running netperf client 
    print("")
    global testsRemaining 
    testsRemaining = len(interfaceList) * len(testList) * numReps
    global timeRemaining 
    timeRemaining = testsRemaining * TEST_DURATION
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    multiPrint("Beginning testing at {0}.  {1} tests to run, estimated time={2} s".format(timestamp, testsRemaining, timeRemaining), 0)
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
                showETC()
                
            results.append(Dataset(vtType, interfaceIP, test, command, rawdata, timestamp ) )
            showResult(results[-1]) 
    
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
    
    # write results summary to screen only - don't bother with file
    WRITE_OUTPUT=False
    print("\n\nResults Summary: ")
    for data in results: 
        showResult(data)
    WRITE_OUTPUT=True
    
    if "vm" in vtType: 
        # show interface info from guest
        command=("ssh root@" + interfaceIP + " \"/root/show_if_info.sh\" ")
        interfaceInfo = runCommand(command, keyStr)
        multiPrint("\n\nGuest interfaces: ",0)
        multiPrint(interfaceInfo, 0)

    multiPrint("\nTesting complete at {0} for {1}, ".format(datetime.now().strftime("%Y-%m-%d %H:%M:%S"), vtType), 0)
    multiPrint("Data written to {0}".format(outputFile), 0 )
    print("")
    
    if WRITE_OUTPUT:
        fHandle.close

# end main()

if __name__ == '__main__':
    multiPrint("command line arguments: "+str(sys.argv), 3)
    main()

