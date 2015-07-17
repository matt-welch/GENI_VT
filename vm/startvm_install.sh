CPUTYPE="host,level=9"
NAME="node1_vm"

sudo taskset 0x2 qemu-system-x86_64 \
    -boot once=d \
    -cdrom ubuntu-14.04.2-server-amd64.iso \
    -enable-kvm \
    -name $NAME \
    -cpu $CPUTYPE \
    -smp 4 \
    -m 4096 \
    -hda ubuntu.img \
    -net nic -net user \
    -no-reboot \
    -no-hpet \
    -nographic \
    -vnc :1 \
    -serial stdio
