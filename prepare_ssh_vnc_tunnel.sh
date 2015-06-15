# change the NODE variable below to select node 1 or 2 (from nodes.lst)
# ref: http://www.cyberciti.biz/tips/tunneling-vnc-connections-over-ssh-howto.html
NODE=1
VNCPORT=5901
USER=mattwel
ssh -L $VNCPORT:localhost:$VNCPORT -N -f -l $USER $(cat nodes.lst | cut -d ' ' -f $NODE)
