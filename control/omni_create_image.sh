#!/bin/bash
# note, first run omni_sliver_status.sh to get the urn for your slice 
# grep the out of omni_sliver_status.sh (name varies by slice) for the 
#   slice urn like : 
#$ grep urn 1RawNode-sliverstatus-utahddc-geniracks-net.json
#  [No write since last change]
#        "urn": "urn:publicid:IDN+ch.geni.net+user+mattwel",
#        "urn": "urn:publicid:IDN+ch.geni.net+user+syrotiuk",
#    "geni_urn": "urn:publicid:IDN+ch.geni.net:Experimentation-on-GENI+slice+1RawNode",
#        "geni_urn": "urn:publicid:IDN+utahddc.geniracks.net+sliver+51940",

AGG="utahddc-ig"
SLICE="1RawNode"
IMAGENAME="Ubuntu1404PreemptRT"
URN="$1"

if [[ -z $URN ]] ; then 
    #URN="urn:publicid:IDN+utahddc.geniracks.net+sliver+51940"
    echo "ERROR: you must pass a sliver URN to $0"
fi

omni createimage -a $AGG $SLICE $IMAGENAME -u $URN 

# Notice the Result Summary includes the information that you need to use the image: creating public image ['urn:publicid:IDN+instageni.gpolab.bbn.com+image+ch-geni-net:Icreatedthisimage', 'https://boss.instageni.gpolab.bbn.com/image_metadata.php?uuid=ef4340a8-4017-11e3-9226-029e26f15299']. The new custom image URN and URL can be used for other nodes to load the image. 

 
