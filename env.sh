#!/bin/bash -e

die() {
  echo "${1}" && exit 1
}

lxccfg() {
  echo "lxc.network.type = none" >> ${1}
  echo "lxc.mount.entry=${DEVDIR} usr/local/development none bind,create=dir 0 0" >> ${1}
}

lxcrun() {
  lxc-attach -n "${INSTANCE}" -v "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" -- /bin/bash -c "${1}"
}

if [ "${EUID}" -ne 0 ]; then
  if which sudo &> /dev/null; then
    sudo ${0} ${@}
    exit
  else
    die "you must be root!"
  fi
fi

if [ "${1}" = "" ]; then
  die "USAGE: ${0} <instance> [<devdir>]"
else
  INSTANCE=${1}
fi

if [ "${2}" = "" ]; then
  DEVDIR=$(pwd)
else
  DEVDIR=${2}
fi

if ! [ -d "${DEVDIR}/meta-fnordpipe" ]; then
  die "missing repo in DEVDIR"
fi

lxc-info -n "${INSTANCE}" &> /dev/null && die "already exists"

export LXCCONFIG=$(mktemp)
export DEBIAN_FRONTEND=noninteractive

lxccfg ${LXCCONFIG}
lxc-create -n "${INSTANCE}" -f ${LXCCONFIG} -t ubuntu -- -r xenial
rm ${LXCCONFIG}
lxc-start -n "${INSTANCE}"

lxcrun 'rm /etc/resolv.conf'
lxcrun 'echo nameserver 8.8.8.8 | tee /etc/resolv.conf'
lxcrun 'apt-get update'

# create user
LXCUID=$(ls -an ${DEVDIR} | sed -n 2p | awk '{ print $3 }')
LXCGID=$(ls -an ${DEVDIR} | sed -n 2p | awk '{ print $4 }')
lxcrun 'userdel ubuntu'
lxcrun "groupadd -g ${LXCGID} user"
lxcrun "useradd -m -g ${LXCGID} -u ${LXCUID} user"
lxcrun 'ln -s /usr/local/development ~user/development'
lxcrun 'ln -s /var/lib/oe ~user/oe'

lxcrun "usermod -p '\$6\$VasvKpIc\$WjeeFZ9e8nl0FGdUHDWwrFC.6WMXtyPA5kIplZL6.SlVgcUxOf/sWthnUutR4EAmmhZdjhQZIfUuaKCI9bPiM0' root"

# install oe dependencies
lxcrun 'apt-get install -y cpio python3 gawk wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath libsdl1.2-dev'
lxcrun 'install -m 0750 -o user -g user -d /var/lib/oe'
lxcrun '/bin/su -l user -c "git clone git://git.openembedded.org/openembedded-core /var/lib/oe"'
lxcrun '/bin/su -l user -c "git clone git://git.openembedded.org/bitbake /var/lib/oe/bitbake"'
lxcrun '/bin/su -l user -c "cd /var/lib/oe && git checkout pyro"'
lxcrun '/bin/su -l user -c "cd /var/lib/oe/bitbake && git checkout 1.34"'
lxcrun '/bin/su -l user -c "ln -s /usr/local/development/meta-fnordpipe /var/lib/oe/meta-fnordpipe"'
lxcrun '/bin/su -l user -c "cd /var/lib/oe && export TEMPLATECONF=meta-fnordpipe/conf/samples && source ./oe-init-build-env"'
