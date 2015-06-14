# GENI_VT
1) Run the bootstrap_control.sh script from your local host first to copy images to the test nodes

2) SSH to the node

3) Run bootstrap_node.sh on the test-node to make directories and clone the GENI_VT repository

4) Run GENI_VT/install_script.sh

5) Verify that the interface names in the startbr.sh are correct 
#   This is where it currently doesn't work.  The bridging seems to work.
# I'm not sure how to connect to the VM now without being able to specify its IP address via kernel command line params

6) Verify settings in startvm.sh are correct

7) cd ~/images

8) Run startvm.sh

