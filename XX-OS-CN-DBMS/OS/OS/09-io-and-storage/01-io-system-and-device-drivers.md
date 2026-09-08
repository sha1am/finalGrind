# I/O System and Device Drivers

The I/O subsystem gives programs consistent interfaces to very different devices.

```text
application
   |
OS API / syscall
   |
filesystem / socket / device layer
   |
device driver
   |
controller
   |
device
```

A device driver translates generic OS operations into device-specific commands and handles completion/errors.

## Interview point

The kernel usually does not “know how an SSD works” at application level; the driver/controller stack abstracts the device.
