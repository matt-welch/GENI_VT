ssh -L 5901:localhost:5901 -N -f -l mattwel $(cat nodes.lst | cut -d ' ' -f 1)
