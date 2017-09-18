# Setup

### setup the toolchain:

    $ git clone https://github.com/fnordpipe/meta-fnordpipe.git
    $ bash meta-fnordpipe/env.sh <container>

### run the build:

    $ lxc-attach -n <container> -- /bin/su -l user
    $ cd oe && . ./oe-init-build-env
    $ bitbake <target>
