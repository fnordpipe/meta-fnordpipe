IMAGE_ROOT_PW ?= "fnordpipe"

python do_rootpw() {
  import crypt
  import random

  ALPHABET = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
  salt = ''.join(random.choice(ALPHABET) for i in range(16))
  pw = crypt.crypt(d.getVar('IMAGE_ROOT_PW', True), '$6$' + salt)

  shadowFile = d.getVar('IMAGE_ROOTFS') + '/etc/shadow'
  with open(shadowFile, 'r') as fd:
    data = fd.readlines()

  with open(shadowFile, 'w') as fd:
    for line in data:
      user = line.split(':')
      if user[0] == 'root':
        user[1] = pw
      fd.write(':'.join(map(str, user)))
}

ROOTFS_POSTPROCESS_COMMAND += "do_rootpw; "
