CPUTYPE="host,level=9"
NAME="node1_vm"

sudo taskset 0x2 qemu-system-x86_64 \
    -enable-kvm \
    -name $NAME \
    -cpu $CPUTYPE \
    -smp 4 \
    -boot once=d \
    -m 4096 \
    -hda ubuntu.img \
    -cdrom ubuntu-14.04.2-server-amd64.iso \
    -net nic -net user \
    -no-reboot \
    -no-hpet \
    -nographic \
    -monitor stdio \
    -vnc :1

reset
#    -serial stdio \
