![openembedded](https://www.openembedded.org/images/logo.png "openembedded")

# setup

### setup the toolchain:

    $ git clone https://github.com/fnordpipe/meta-fnordpipe.git
    $ bash ./env.sh <container>

### update the toolchain:

    $ bash ./env.sh <container>

### run the build:

    $ lxc-attach -n <container> -- /bin/su -l user
    $ cd oe && . ./oe-init-build-env
    $ bitbake <target>

# supported hardware

* x86_64
  * HP DL120G6 (dl120g6)

# installation

## local

    $ # key for locky (luks remote decryption)
    $ openssl genrsa -out private.key.pem 4096
    $ openssl rsa -in private.key.pem -pubout -out public.key.pem
    $
    $ # key for root user ssh access
    $ ssh-keygen -t ed25519 -f root.key -C root@<yourhost>

## remote

    $ wget https://github.com/fnordpipe/meta-fnordpipe/releases/download/v${VERSION}/dom0-installer-${MACHINE}-${DATE}.img.xz
    $ unxz dom0-installer-${MACHINE}-${DATE}.img.xz
    $ dd if=dom0-installer-${MACHINE}-${DATE}.img of=/dev/sda
    $
    $ #partprobe
    $ mount /dev/sda1 /mnt
    $
    $ vim /mnt/config/install.env
    DEV_LIST="/dev/sda /dev/sdb /dev/sdc /dev/sdd"
    LUKS_KEY="<password>"
    LUKS_NAME="luks0"
    VG_NAME="luks0vg0"
    LV_NAME="system"
    HOST_NAME="<yourhost>"
    $
    $ vim /mnt/config/network/25-public.network
    [Match]
    Name=enp1s0

    [Network]
    Address=<a.b.c.d/X>
    Gateway=<a.b.c.e>
    $
    $ cat > /mnt/config/public.key.pem
    $ cat > /mnt/config/root.key.pub
    $
    $ reboot

host will come up and start installer automatically. The host will reboot again after installation.
