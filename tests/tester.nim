
import unittest
import posix, strutils, os
import libevdev

const
  device = "/dev/input/event0"

proc initevdev(device: string): ptr libevdev =
  let fd = open(device, O_RDONLY or O_NONBLOCK)
  if fd < 0:
    raiseOSError(OSErrorCode(errno), "could not open $1" % device)

  var dev: ptr libevdev
  let ret = libevdev_new_from_fd(fd, addr dev)
  if ret < 0:
    quit("could not create libevdev device")

  return dev

suite "linux evdev tests":

  setup:
    let dev = initevdev(device)

  test "devname":
    let devname:cstring = libevdev_get_name(dev)
    echo "name is: '$1'" % $devname
 
  teardown:
    libevdev_free(dev)
