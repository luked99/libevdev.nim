import strutils, os, posix
import libevdev, linux/input

proc main() =
  var found = false
  var evdev: ptr libevdev

  for device in walkPattern("/dev/input/event*"):
    let fd = open(device, O_RDONLY or O_NONBLOCK)
    if fd < 0:
      raiseOSError(OSErrorCode(errno), "could not open $1" % device)

    let ret = libevdev_new_from_fd(fd, addr evdev)
    if ret < 0:
      raiseOSError(OSErrorCode(errno), "could not create libevdev device for $1" % device)

    if libevdev_has_event_type(evdev, EV_REL):
      # looks like a mouse
      found = true
      break
    discard close(fd)

  if not found: quit("no devices")

  while true:
    var ev: input_event
    let rc = libevdev_next_event(evdev, cuint(LIBEVDEV_READ_FLAG_NORMAL), addr ev)
    if rc == cint(LIBEVDEV_READ_STATUS_SUCCESS):
      echo "Event: $1 $2 $3" % [
        $libevdev_event_type_get_name(ev.ev_type),
        $libevdev_event_code_get_name(ev.ev_type, ev.code),
        $ev.value]


main()
