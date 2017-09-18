# Setup

### setup the toolchain:

    $ git clone https://github.com/fnordpipe/meta-fnordpipe.git
    $ bash ./env.sh <container>

### update the toolchain:

    $ bash ./env.sh <container>

### run the build:

    $ lxc-attach -n <container> -- /bin/su -l user
    $ cd oe && . ./oe-init-build-env
    $ bitbake <target>
