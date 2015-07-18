#!/bin/bash
AGG="utahddc-ig"
SLICE="1RawNode"
#1. In order to capture the Image running on our node we must determine the URN for the host1 device by getting a sliver status: 
omni sliverstatus -a $AGG $SLICE -o 

# 2. Look at the content of the sliver status output file (lntest-sliverstatus-instageni-gpolab-bbn-com.json) and search for host1 and find its sliver_id . Below is an excerpt of the sliver status output file that show information required:
#
#$ grep urn 1RawNode-sliverstatus-utahddc-geniracks-net.json
#  [No write since last change]
#        "urn": "urn:publicid:IDN+ch.geni.net+user+mattwel",
#        "urn": "urn:publicid:IDN+ch.geni.net+user+syrotiuk",
#    "geni_urn": "urn:publicid:IDN+ch.geni.net:Experimentation-on-GENI+slice+1RawNode",
#        "geni_urn": "urn:publicid:IDN+utahddc.geniracks.net+sliver+51940",

