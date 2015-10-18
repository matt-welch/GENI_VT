#!/usr/bin/python
'''
File: arguments.py
Author: Matt Welch
Description: implified functionality for getting arguments (Matlab style) and 
            selecting files
'''
import sys
import os # file select dialog

DEBUG_MODE = False

def getArgs():
    # gets command line arguments & count Matlab style
    nargin = len(sys.argv)
    varargin = sys.argv
    if DEBUG_MODE:
        print('Number of arguments: {0}'.format(nargin))
        print('Argument List: {0}'.format(varargin))
    return varargin, nargin
    
def selectFile(extension='.dat'):
    # selects a file matching the extension from the current directory
    files = [f for f in os.listdir('.') if (os.path.isfile(f) and f.endswith(extension))]
    files.sort(reverse=True) # sort files in descending order
    count=1
    print("Which '{0}' file from the current directory would you like to load?".format(extension))
    for f in files:
        print("[{0}] {1}".format(count, f))
        count +=1
    default_ans = '0'
    user_answer = raw_input("Enter the number of the file to load (0 exits): (default=%s): " % default_ans) or default_ans
    user_answer = int(user_answer)
    if user_answer == 0:
        print("User selected '0', Exiting...")
        exit(1)
    infile = files[user_answer-1]
    print("User selected file number {0}: {1}".format(user_answer, infile))
    return infile


    
