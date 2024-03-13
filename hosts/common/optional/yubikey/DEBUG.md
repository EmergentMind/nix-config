# Rule Location

```bash
[aa@onyx:~]$ rg -i yubikey /etc/udev/rules.d/99-local.rules
2:SUBSYSTEM=="usb", ACTION=="add", ATTR{idVendor}=="1050", RUN+="/nix/store/ds68a4n1lyvlm41hdppyndvvim8jd3xv-yubikey-up/bin/yubikey-up"
3:SUBSYSTEM=="usb", ACTION=="remove", ENV{ID_VENDOR_ID}=="1050", RUN+="/nix/store/pj2cs5nxi2ikra5w63h62xks1sfz3g83-yubikey-down/bin/yubikey-down"
```

# Event Log

The events associated with insertion/removal to help with writing the udev rules.

When you are writing the UDEV rules there are a few important things:

- removal cannot access ATTR{} values. You must use ENV{..}
- be careful to check the subsystem! ex: you may add on SUBSYSTEM usb, but removal may require SUBSYSTEM input

```bash
[aa@onyx:~/dev/nix-config]$ udevadm monitor --environment --udev
monitor will print the received events for:
UDEV - the event which udev sends out after rule processing

UDEV  [733866.322842] add      /devices/pci0000:00/0000:00:14.0/usb3/3-1 (usb)
ACTION=add
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1
SUBSYSTEM=usb
DEVNAME=/dev/bus/usb/003/062
DEVTYPE=usb_device
PRODUCT=1050/407/527
TYPE=0/0/0
BUSNUM=003
DEVNUM=062
SEQNUM=20566
USEC_INITIALIZED=733865563180
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_BUS=usb
ID_MODEL=YubiKey_OTP+FIDO+CCID
ID_MODEL_ENC=YubiKey\x20OTP+FIDO+CCID
ID_MODEL_ID=0407
ID_SERIAL=Yubico_YubiKey_OTP+FIDO+CCID
ID_VENDOR=Yubico
ID_VENDOR_ENC=Yubico
ID_VENDOR_ID=1050
ID_REVISION=0527
ID_USB_MODEL=YubiKey_OTP+FIDO+CCID
ID_USB_MODEL_ENC=YubiKey\x20OTP+FIDO+CCID
ID_USB_MODEL_ID=0407
ID_USB_SERIAL=Yubico_YubiKey_OTP+FIDO+CCID
ID_USB_VENDOR=Yubico
ID_USB_VENDOR_ENC=Yubico
ID_USB_VENDOR_ID=1050
ID_USB_REVISION=0527
ID_USB_INTERFACES=:030101:030000:0b0000:
ID_VENDOR_FROM_DATABASE=Yubico.com
ID_MODEL_FROM_DATABASE=Yubikey 4/5 OTP+U2F+CCID
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1
ID_PATH=pci-0000:00:14.0-usb-0:1
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1
ID_SMARTCARD_READER=1
DRIVER=usb
ID_SECURITY_TOKEN=1
ID_FOR_SEAT=usb-pci-0000_00_14_0-usb-0_1
SYSTEMD_WANTS=smartcard.target
SYSTEMD_USER_WANTS=smartcard.target
MAJOR=189
MINOR=317
TAGS=:seat:security-device:systemd:uaccess:
CURRENT_TAGS=:seat:security-device:systemd:uaccess:

UDEV  [733866.326252] add      /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0 (usb)
ACTION=add
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0
SUBSYSTEM=usb
DEVTYPE=usb_interface
PRODUCT=1050/407/527
TYPE=0/0/0
INTERFACE=3/1/1
MODALIAS=usb:v1050p0407d0527dc00dsc00dp00ic03isc01ip01in00
SEQNUM=20567
USEC_INITIALIZED=733865593386
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_VENDOR_FROM_DATABASE=Yubico.com
ID_MODEL_FROM_DATABASE=Yubikey 4/5 OTP+U2F+CCID
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1:1.0
ID_PATH=pci-0000:00:14.0-usb-0:1:1.0
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1_1_0
DRIVER=usbhid
ID_SECURITY_TOKEN=1

UDEV  [733866.327717] add      /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069 (hid)
ACTION=add
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069
SUBSYSTEM=hid
HID_ID=0003:00001050:00000407
HID_NAME=Yubico YubiKey OTP+FIDO+CCID
HID_PHYS=usb-0000:00:14.0-1/input0
HID_UNIQ=
MODALIAS=hid:b0003g0001v00001050p00000407
SEQNUM=20568
USEC_INITIALIZED=733865593428
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_SECURITY_TOKEN=1
DRIVER=hid-generic

UDEV  [733866.328259] add      /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.1 (usb)
ACTION=add
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.1
SUBSYSTEM=usb
DEVTYPE=usb_interface
PRODUCT=1050/407/527
TYPE=0/0/0
INTERFACE=3/0/0
MODALIAS=usb:v1050p0407d0527dc00dsc00dp00ic03isc00ip00in01
SEQNUM=20583
USEC_INITIALIZED=733865618802
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_VENDOR_FROM_DATABASE=Yubico.com
ID_MODEL_FROM_DATABASE=Yubikey 4/5 OTP+U2F+CCID
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1:1.1
ID_PATH=pci-0000:00:14.0-usb-0:1:1.1
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1_1_1
DRIVER=usbhid
ID_SECURITY_TOKEN=1

UDEV  [733866.328831] add      /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.2 (usb)
ACTION=add
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.2
SUBSYSTEM=usb
DEVTYPE=usb_interface
PRODUCT=1050/407/527
TYPE=0/0/0
INTERFACE=11/0/0
MODALIAS=usb:v1050p0407d0527dc00dsc00dp00ic0Bisc00ip00in02
SEQNUM=20589
USEC_INITIALIZED=733865619622
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_VENDOR_FROM_DATABASE=Yubico.com
ID_MODEL_FROM_DATABASE=Yubikey 4/5 OTP+U2F+CCID
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1:1.2
ID_PATH=pci-0000:00:14.0-usb-0:1:1.2
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1_1_2
DRIVER=usbfs
ID_SECURITY_TOKEN=1

UDEV  [733866.330296] add      /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81 (input)
ACTION=add
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81
SUBSYSTEM=input
PRODUCT=3/1050/407/110
NAME="Yubico YubiKey OTP+FIDO+CCID"
PHYS="usb-0000:00:14.0-1/input0"
UNIQ=""
PROP=0
EV=120013
KEY=e080ffdf01cfffff fffffffffffffffe
MSC=10
LED=1f
MODALIAS=input:b0003v1050p0407e0110-e0,1,4,11,14,k77,7D,7E,7F,ram4,l0,1,2,3,4,sfw
SEQNUM=20569
USEC_INITIALIZED=733865593451
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_INPUT=1
ID_INPUT_KEY=1
ID_INPUT_KEYBOARD=1
ID_BUS=usb
ID_MODEL=YubiKey_OTP+FIDO+CCID
ID_MODEL_ENC=YubiKey\x20OTP+FIDO+CCID
ID_MODEL_ID=0407
ID_SERIAL=Yubico_YubiKey_OTP+FIDO+CCID
ID_VENDOR=Yubico
ID_VENDOR_ENC=Yubico
ID_VENDOR_ID=1050
ID_REVISION=0527
ID_TYPE=hid
ID_USB_MODEL=YubiKey_OTP+FIDO+CCID
ID_USB_MODEL_ENC=YubiKey\x20OTP+FIDO+CCID
ID_USB_MODEL_ID=0407
ID_USB_SERIAL=Yubico_YubiKey_OTP+FIDO+CCID
ID_USB_VENDOR=Yubico
ID_USB_VENDOR_ENC=Yubico
ID_USB_VENDOR_ID=1050
ID_USB_REVISION=0527
ID_USB_TYPE=hid
ID_USB_INTERFACES=:030101:030000:0b0000:
ID_USB_INTERFACE_NUM=00
ID_USB_DRIVER=usbhid
.INPUT_CLASS=kbd
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1:1.0
ID_PATH=pci-0000:00:14.0-usb-0:1:1.0
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1_1_0
ID_SECURITY_TOKEN=1
ID_FOR_SEAT=input-pci-0000_00_14_0-usb-0_1_1_0
TAGS=:seat:
CURRENT_TAGS=:seat:

UDEV  [733866.330904] add      /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.1/0003:1050:0407.006A (hid)
ACTION=add
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.1/0003:1050:0407.006A
SUBSYSTEM=hid
HID_ID=0003:00001050:00000407
HID_NAME=Yubico YubiKey OTP+FIDO+CCID
HID_PHYS=usb-0000:00:14.0-1/input1
HID_UNIQ=
MODALIAS=hid:b0003g0001v00001050p00000407
SEQNUM=20584
USEC_INITIALIZED=733865619258
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_SECURITY_TOKEN=1
DRIVER=hid-generic

UDEV  [733866.331016] add      /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.1/usbmisc/hiddev1 (usbmisc)
ACTION=add
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.1/usbmisc/hiddev1
SUBSYSTEM=usbmisc
DEVNAME=/dev/usb/hiddev1
SEQNUM=20585
USEC_INITIALIZED=733865619323
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_SECURITY_TOKEN=1
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1:1.1
ID_PATH=pci-0000:00:14.0-usb-0:1:1.1
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1_1_1
ID_FOR_SEAT=usbmisc-pci-0000_00_14_0-usb-0_1_1_1
MAJOR=180
MINOR=97
TAGS=:seat:uaccess:
CURRENT_TAGS=:seat:uaccess:

UDEV  [733866.332633] add      /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/input81::numlock (leds)
ACTION=add
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/input81::numlock
SUBSYSTEM=leds
SEQNUM=20570
USEC_INITIALIZED=733865618195
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_SECURITY_TOKEN=1
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1:1.0
ID_PATH=pci-0000:00:14.0-usb-0:1:1.0
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1_1_0
ID_FOR_SEAT=leds-pci-0000_00_14_0-usb-0_1_1_0
TAGS=:seat:
CURRENT_TAGS=:seat:

UDEV  [733866.334636] add      /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/input81::capslock (leds)
ACTION=add
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/input81::capslock
SUBSYSTEM=leds
SEQNUM=20572
USEC_INITIALIZED=733865618283
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_SECURITY_TOKEN=1
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1:1.0
ID_PATH=pci-0000:00:14.0-usb-0:1:1.0
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1_1_0
ID_FOR_SEAT=leds-pci-0000_00_14_0-usb-0_1_1_0
TAGS=:seat:
CURRENT_TAGS=:seat:

UDEV  [733866.335086] change   /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/input81::numlock (leds)
ACTION=change
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/input81::numlock
SUBSYSTEM=leds
TRIGGER=kbd-numlock
SEQNUM=20571
USEC_INITIALIZED=733865618195
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_SECURITY_TOKEN=1
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1:1.0
ID_PATH=pci-0000:00:14.0-usb-0:1:1.0
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1_1_0
ID_FOR_SEAT=leds-pci-0000_00_14_0-usb-0_1_1_0
TAGS=:seat:
CURRENT_TAGS=:seat:

UDEV  [733866.335812] add      /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/input81::compose (leds)
ACTION=add
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/input81::compose
SUBSYSTEM=leds
SEQNUM=20576
USEC_INITIALIZED=733865618374
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_SECURITY_TOKEN=1
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1:1.0
ID_PATH=pci-0000:00:14.0-usb-0:1:1.0
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1_1_0
ID_FOR_SEAT=leds-pci-0000_00_14_0-usb-0_1_1_0
TAGS=:seat:
CURRENT_TAGS=:seat:

UDEV  [733866.336047] add      /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/input81::kana (leds)
ACTION=add
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/input81::kana
SUBSYSTEM=leds
SEQNUM=20577
USEC_INITIALIZED=733865618392
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_SECURITY_TOKEN=1
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1:1.0
ID_PATH=pci-0000:00:14.0-usb-0:1:1.0
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1_1_0
ID_FOR_SEAT=leds-pci-0000_00_14_0-usb-0_1_1_0
TAGS=:seat:
CURRENT_TAGS=:seat:

UDEV  [733866.336653] change   /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/input81::capslock (leds)
ACTION=change
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/input81::capslock
SUBSYSTEM=leds
TRIGGER=kbd-capslock
SEQNUM=20573
USEC_INITIALIZED=733865618283
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_SECURITY_TOKEN=1
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1:1.0
ID_PATH=pci-0000:00:14.0-usb-0:1:1.0
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1_1_0
ID_FOR_SEAT=leds-pci-0000_00_14_0-usb-0_1_1_0
TAGS=:seat:
CURRENT_TAGS=:seat:

UDEV  [733866.336743] add      /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/input81::scrolllock (leds)
ACTION=add
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/input81::scrolllock
SUBSYSTEM=leds
SEQNUM=20574
USEC_INITIALIZED=733865618333
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_SECURITY_TOKEN=1
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1:1.0
ID_PATH=pci-0000:00:14.0-usb-0:1:1.0
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1_1_0
ID_FOR_SEAT=leds-pci-0000_00_14_0-usb-0_1_1_0
TAGS=:seat:
CURRENT_TAGS=:seat:

UDEV  [733866.338209] change   /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/input81::kana (leds)
ACTION=change
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/input81::kana
SUBSYSTEM=leds
TRIGGER=kbd-kanalock
SEQNUM=20578
USEC_INITIALIZED=733865618392
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_SECURITY_TOKEN=1
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1:1.0
ID_PATH=pci-0000:00:14.0-usb-0:1:1.0
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1_1_0
ID_FOR_SEAT=leds-pci-0000_00_14_0-usb-0_1_1_0
TAGS=:seat:
CURRENT_TAGS=:seat:

UDEV  [733866.338522] change   /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/input81::scrolllock (leds)
ACTION=change
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/input81::scrolllock
SUBSYSTEM=leds
TRIGGER=kbd-scrolllock
SEQNUM=20575
USEC_INITIALIZED=733865618333
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_SECURITY_TOKEN=1
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1:1.0
ID_PATH=pci-0000:00:14.0-usb-0:1:1.0
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1_1_0
ID_FOR_SEAT=leds-pci-0000_00_14_0-usb-0_1_1_0
TAGS=:seat:
CURRENT_TAGS=:seat:

UDEV  [733866.339141] add      /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/hidraw/hidraw1 (hidraw)
ACTION=add
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/hidraw/hidraw1
SUBSYSTEM=hidraw
DEVNAME=/dev/hidraw1
SEQNUM=20580
USEC_INITIALIZED=733865618480
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_SECURITY_TOKEN=1
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1:1.0
ID_PATH=pci-0000:00:14.0-usb-0:1:1.0
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1_1_0
ID_FOR_SEAT=hidraw-pci-0000_00_14_0-usb-0_1_1_0
MAJOR=246
MINOR=1
TAGS=:seat:uaccess:
CURRENT_TAGS=:seat:uaccess:

UDEV  [733866.342108] add      /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.1/0003:1050:0407.006A/hidraw/hidraw2 (hidraw)
ACTION=add
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.1/0003:1050:0407.006A/hidraw/hidraw2
SUBSYSTEM=hidraw
DEVNAME=/dev/hidraw2
SEQNUM=20586
USEC_INITIALIZED=733865619393
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_FIDO_TOKEN=1
ID_SECURITY_TOKEN=1
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1:1.1
ID_PATH=pci-0000:00:14.0-usb-0:1:1.1
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1_1_1
ID_FOR_SEAT=hidraw-pci-0000_00_14_0-usb-0_1_1_1
MAJOR=246
MINOR=2
TAGS=:seat:security-device:uaccess:
CURRENT_TAGS=:seat:security-device:uaccess:

UDEV  [733866.342681] bind     /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.1/0003:1050:0407.006A (hid)
ACTION=bind
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.1/0003:1050:0407.006A
SUBSYSTEM=hid
DRIVER=hid-generic
HID_ID=0003:00001050:00000407
HID_NAME=Yubico YubiKey OTP+FIDO+CCID
HID_PHYS=usb-0000:00:14.0-1/input1
HID_UNIQ=
MODALIAS=hid:b0003g0001v00001050p00000407
SEQNUM=20587
USEC_INITIALIZED=733865619258
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin

UDEV  [733866.343352] bind     /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.1 (usb)
ACTION=bind
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.1
SUBSYSTEM=usb
DEVTYPE=usb_interface
DRIVER=usbhid
PRODUCT=1050/407/527
TYPE=0/0/0
INTERFACE=3/0/0
MODALIAS=usb:v1050p0407d0527dc00dsc00dp00ic03isc00ip00in01
SEQNUM=20588
USEC_INITIALIZED=733865618802
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_VENDOR_FROM_DATABASE=Yubico.com
ID_MODEL_FROM_DATABASE=Yubikey 4/5 OTP+U2F+CCID
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1:1.1
ID_PATH=pci-0000:00:14.0-usb-0:1:1.1
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1_1_1

UDEV  [733866.371486] add      /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/event1 (input)
ACTION=add
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/event1
SUBSYSTEM=input
DEVNAME=/dev/input/event1
SEQNUM=20579
USEC_INITIALIZED=733865618434
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_INPUT=1
ID_INPUT_KEY=1
ID_INPUT_KEYBOARD=1
ID_BUS=usb
ID_MODEL=YubiKey_OTP+FIDO+CCID
ID_MODEL_ENC=YubiKey\x20OTP+FIDO+CCID
ID_MODEL_ID=0407
ID_SERIAL=Yubico_YubiKey_OTP+FIDO+CCID
ID_VENDOR=Yubico
ID_VENDOR_ENC=Yubico
ID_VENDOR_ID=1050
ID_REVISION=0527
ID_TYPE=hid
ID_USB_MODEL=YubiKey_OTP+FIDO+CCID
ID_USB_MODEL_ENC=YubiKey\x20OTP+FIDO+CCID
ID_USB_MODEL_ID=0407
ID_USB_SERIAL=Yubico_YubiKey_OTP+FIDO+CCID
ID_USB_VENDOR=Yubico
ID_USB_VENDOR_ENC=Yubico
ID_USB_VENDOR_ID=1050
ID_USB_REVISION=0527
ID_USB_TYPE=hid
ID_USB_INTERFACES=:030101:030000:0b0000:
ID_USB_INTERFACE_NUM=00
ID_USB_DRIVER=usbhid
.INPUT_CLASS=kbd
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1:1.0
ID_PATH=pci-0000:00:14.0-usb-0:1:1.0
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1_1_0
ID_SECURITY_TOKEN=1
ID_FOR_SEAT=input-pci-0000_00_14_0-usb-0_1_1_0
LIBINPUT_DEVICE_GROUP=3/1050/407:usb-0000:00:14.0-1
MAJOR=13
MINOR=65
DEVLINKS=/dev/input/by-path/pci-0000:00:14.0-usb-0:1:1.0-event-kbd /dev/input/by-id/usb-Yubico_YubiKey_OTP+FIDO+CCID-event-kbd /dev/input/by-path/pci-0000:00:14.0-usbv2-0:1:1.0-event-kbd
TAGS=:seat:uaccess:power-switch:
CURRENT_TAGS=:seat:uaccess:power-switch:

UDEV  [733866.372708] bind     /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069 (hid)
ACTION=bind
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069
SUBSYSTEM=hid
DRIVER=hid-generic
HID_ID=0003:00001050:00000407
HID_NAME=Yubico YubiKey OTP+FIDO+CCID
HID_PHYS=usb-0000:00:14.0-1/input0
HID_UNIQ=
MODALIAS=hid:b0003g0001v00001050p00000407
SEQNUM=20581
USEC_INITIALIZED=733865593428
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin

UDEV  [733866.373818] bind     /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0 (usb)
ACTION=bind
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0
SUBSYSTEM=usb
DEVTYPE=usb_interface
DRIVER=usbhid
PRODUCT=1050/407/527
TYPE=0/0/0
INTERFACE=3/1/1
MODALIAS=usb:v1050p0407d0527dc00dsc00dp00ic03isc01ip01in00
SEQNUM=20582
USEC_INITIALIZED=733865593386
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_VENDOR_FROM_DATABASE=Yubico.com
ID_MODEL_FROM_DATABASE=Yubikey 4/5 OTP+U2F+CCID
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1:1.0
ID_PATH=pci-0000:00:14.0-usb-0:1:1.0
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1_1_0

UDEV  [733866.384384] bind     /devices/pci0000:00/0000:00:14.0/usb3/3-1 (usb)
ACTION=bind
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1
SUBSYSTEM=usb
DEVNAME=/dev/bus/usb/003/062
DEVTYPE=usb_device
DRIVER=usb
PRODUCT=1050/407/527
TYPE=0/0/0
BUSNUM=003
DEVNUM=062
SEQNUM=20590
USEC_INITIALIZED=733865563180
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_BUS=usb
ID_MODEL=YubiKey_OTP+FIDO+CCID
ID_MODEL_ENC=YubiKey\x20OTP+FIDO+CCID
ID_MODEL_ID=0407
ID_SERIAL=Yubico_YubiKey_OTP+FIDO+CCID
ID_VENDOR=Yubico
ID_VENDOR_ENC=Yubico
ID_VENDOR_ID=1050
ID_REVISION=0527
ID_USB_MODEL=YubiKey_OTP+FIDO+CCID
ID_USB_MODEL_ENC=YubiKey\x20OTP+FIDO+CCID
ID_USB_MODEL_ID=0407
ID_USB_SERIAL=Yubico_YubiKey_OTP+FIDO+CCID
ID_USB_VENDOR=Yubico
ID_USB_VENDOR_ENC=Yubico
ID_USB_VENDOR_ID=1050
ID_USB_REVISION=0527
ID_USB_INTERFACES=:030101:030000:0b0000:
ID_VENDOR_FROM_DATABASE=Yubico.com
ID_MODEL_FROM_DATABASE=Yubikey 4/5 OTP+U2F+CCID
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1
ID_PATH=pci-0000:00:14.0-usb-0:1
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1
ID_SMARTCARD_READER=1
ID_FOR_SEAT=usb-pci-0000_00_14_0-usb-0_1
SYSTEMD_WANTS=smartcard.target
SYSTEMD_USER_WANTS=smartcard.target
MAJOR=189
MINOR=317
TAGS=:seat:security-device:systemd:uaccess:
CURRENT_TAGS=:seat:security-device:systemd:uaccess:

UDEV  [733869.236745] change   /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/input81::numlock (leds)
ACTION=change
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/input81::numlock
SUBSYSTEM=leds
TRIGGER=none
SEQNUM=20591
USEC_INITIALIZED=733865618195
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_SECURITY_TOKEN=1
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1
ID_PATH=pci-0000:00:14.0-usb-0:1
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1
ID_FOR_SEAT=leds-pci-0000_00_14_0-usb-0_1
TAGS=:seat:
CURRENT_TAGS=:seat:

UDEV  [733869.237158] change   /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/input81::capslock (leds)
ACTION=change
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/input81::capslock
SUBSYSTEM=leds
TRIGGER=none
SEQNUM=20593
USEC_INITIALIZED=733865618283
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_SECURITY_TOKEN=1
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1
ID_PATH=pci-0000:00:14.0-usb-0:1
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1
ID_FOR_SEAT=leds-pci-0000_00_14_0-usb-0_1
TAGS=:seat:
CURRENT_TAGS=:seat:

UDEV  [733869.237301] remove   /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/input81::numlock (leds)
ACTION=remove
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/input81::numlock
SUBSYSTEM=leds
SEQNUM=20592
USEC_INITIALIZED=733865618195
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_SECURITY_TOKEN=1
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1
ID_PATH=pci-0000:00:14.0-usb-0:1
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1
ID_FOR_SEAT=leds-pci-0000_00_14_0-usb-0_1
TAGS=:seat:
CURRENT_TAGS=:seat:

UDEV  [733869.237475] change   /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/input81::scrolllock (leds)
ACTION=change
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/input81::scrolllock
SUBSYSTEM=leds
TRIGGER=none
SEQNUM=20595
USEC_INITIALIZED=733865618333
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_SECURITY_TOKEN=1
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1
ID_PATH=pci-0000:00:14.0-usb-0:1
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1
ID_FOR_SEAT=leds-pci-0000_00_14_0-usb-0_1
TAGS=:seat:
CURRENT_TAGS=:seat:

UDEV  [733869.237704] remove   /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/input81::capslock (leds)
ACTION=remove
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/input81::capslock
SUBSYSTEM=leds
SEQNUM=20594
USEC_INITIALIZED=733865618283
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_SECURITY_TOKEN=1
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1
ID_PATH=pci-0000:00:14.0-usb-0:1
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1
ID_FOR_SEAT=leds-pci-0000_00_14_0-usb-0_1
TAGS=:seat:
CURRENT_TAGS=:seat:

UDEV  [733869.237736] remove   /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/input81::compose (leds)
ACTION=remove
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/input81::compose
SUBSYSTEM=leds
SEQNUM=20597
USEC_INITIALIZED=733865618374
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_SECURITY_TOKEN=1
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1:1.0
ID_PATH=pci-0000:00:14.0-usb-0:1:1.0
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1_1_0
ID_FOR_SEAT=leds-pci-0000_00_14_0-usb-0_1_1_0
TAGS=:seat:
CURRENT_TAGS=:seat:

UDEV  [733869.237872] remove   /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/input81::scrolllock (leds)
ACTION=remove
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/input81::scrolllock
SUBSYSTEM=leds
SEQNUM=20596
USEC_INITIALIZED=733865618333
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_SECURITY_TOKEN=1
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1
ID_PATH=pci-0000:00:14.0-usb-0:1
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1
ID_FOR_SEAT=leds-pci-0000_00_14_0-usb-0_1
TAGS=:seat:
CURRENT_TAGS=:seat:

UDEV  [733869.238150] change   /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/input81::kana (leds)
ACTION=change
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/input81::kana
SUBSYSTEM=leds
TRIGGER=none
SEQNUM=20598
USEC_INITIALIZED=733865618392
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_SECURITY_TOKEN=1
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1
ID_PATH=pci-0000:00:14.0-usb-0:1
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1
ID_FOR_SEAT=leds-pci-0000_00_14_0-usb-0_1
TAGS=:seat:
CURRENT_TAGS=:seat:

UDEV  [733869.238577] remove   /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/input81::kana (leds)
ACTION=remove
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/input81::kana
SUBSYSTEM=leds
SEQNUM=20599
USEC_INITIALIZED=733865618392
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_SECURITY_TOKEN=1
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1
ID_PATH=pci-0000:00:14.0-usb-0:1
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1
ID_FOR_SEAT=leds-pci-0000_00_14_0-usb-0_1
TAGS=:seat:
CURRENT_TAGS=:seat:

UDEV  [733869.241725] remove   /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/event1 (input)
ACTION=remove
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81/event1
SUBSYSTEM=input
DEVNAME=/dev/input/event1
SEQNUM=20600
USEC_INITIALIZED=733865618434
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_INPUT=1
ID_INPUT_KEY=1
ID_INPUT_KEYBOARD=1
ID_BUS=usb
ID_MODEL=YubiKey_OTP+FIDO+CCID
ID_MODEL_ENC=YubiKey\x20OTP+FIDO+CCID
ID_MODEL_ID=0407
ID_SERIAL=Yubico_YubiKey_OTP+FIDO+CCID
ID_VENDOR=Yubico
ID_VENDOR_ENC=Yubico
ID_VENDOR_ID=1050
ID_REVISION=0527
ID_TYPE=hid
ID_USB_MODEL=YubiKey_OTP+FIDO+CCID
ID_USB_MODEL_ENC=YubiKey\x20OTP+FIDO+CCID
ID_USB_MODEL_ID=0407
ID_USB_SERIAL=Yubico_YubiKey_OTP+FIDO+CCID
ID_USB_VENDOR=Yubico
ID_USB_VENDOR_ENC=Yubico
ID_USB_VENDOR_ID=1050
ID_USB_REVISION=0527
ID_USB_TYPE=hid
ID_USB_INTERFACES=:030101:030000:0b0000:
ID_USB_INTERFACE_NUM=00
ID_USB_DRIVER=usbhid
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1:1.0
ID_PATH=pci-0000:00:14.0-usb-0:1:1.0
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1_1_0
ID_SECURITY_TOKEN=1
ID_FOR_SEAT=input-pci-0000_00_14_0-usb-0_1_1_0
LIBINPUT_DEVICE_GROUP=3/1050/407:usb-0000:00:14.0-1
MAJOR=13
MINOR=65
DEVLINKS=/dev/input/by-path/pci-0000:00:14.0-usb-0:1:1.0-event-kbd /dev/input/by-id/usb-Yubico_YubiKey_OTP+FIDO+CCID-event-kbd /dev/input/by-path/pci-0000:00:14.0-usbv2-0:1:1.0-event-kbd
TAGS=:seat:uaccess:power-switch:
CURRENT_TAGS=:seat:uaccess:power-switch:

UDEV  [733869.252948] remove   /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/hidraw/hidraw1 (hidraw)
ACTION=remove
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/hidraw/hidraw1
SUBSYSTEM=hidraw
DEVNAME=/dev/hidraw1
SEQNUM=20602
USEC_INITIALIZED=733865618480
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_SECURITY_TOKEN=1
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1:1.0
ID_PATH=pci-0000:00:14.0-usb-0:1:1.0
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1_1_0
ID_FOR_SEAT=hidraw-pci-0000_00_14_0-usb-0_1_1_0
MAJOR=246
MINOR=1
TAGS=:seat:uaccess:
CURRENT_TAGS=:seat:uaccess:

UDEV  [733869.253269] remove   /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81 (input)
ACTION=remove
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069/input/input81
SUBSYSTEM=input
PRODUCT=3/1050/407/110
NAME="Yubico YubiKey OTP+FIDO+CCID"
PHYS="usb-0000:00:14.0-1/input0"
UNIQ=""
PROP=0
EV=120013
KEY=e080ffdf01cfffff fffffffffffffffe
MSC=10
LED=1f
MODALIAS=input:b0003v1050p0407e0110-e0,1,4,11,14,k77,7D,7E,7F,ram4,l0,1,2,3,4,sfw
SEQNUM=20601
USEC_INITIALIZED=733865593451
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_INPUT=1
ID_INPUT_KEY=1
ID_INPUT_KEYBOARD=1
ID_BUS=usb
ID_MODEL=YubiKey_OTP+FIDO+CCID
ID_MODEL_ENC=YubiKey\x20OTP+FIDO+CCID
ID_MODEL_ID=0407
ID_SERIAL=Yubico_YubiKey_OTP+FIDO+CCID
ID_VENDOR=Yubico
ID_VENDOR_ENC=Yubico
ID_VENDOR_ID=1050
ID_REVISION=0527
ID_TYPE=hid
ID_USB_MODEL=YubiKey_OTP+FIDO+CCID
ID_USB_MODEL_ENC=YubiKey\x20OTP+FIDO+CCID
ID_USB_MODEL_ID=0407
ID_USB_SERIAL=Yubico_YubiKey_OTP+FIDO+CCID
ID_USB_VENDOR=Yubico
ID_USB_VENDOR_ENC=Yubico
ID_USB_VENDOR_ID=1050
ID_USB_REVISION=0527
ID_USB_TYPE=hid
ID_USB_INTERFACES=:030101:030000:0b0000:
ID_USB_INTERFACE_NUM=00
ID_USB_DRIVER=usbhid
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1:1.0
ID_PATH=pci-0000:00:14.0-usb-0:1:1.0
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1_1_0
ID_SECURITY_TOKEN=1
ID_FOR_SEAT=input-pci-0000_00_14_0-usb-0_1_1_0
TAGS=:seat:
CURRENT_TAGS=:seat:

UDEV  [733869.253551] remove   /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.1/usbmisc/hiddev1 (usbmisc)
ACTION=remove
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.1/usbmisc/hiddev1
SUBSYSTEM=usbmisc
DEVNAME=/dev/usb/hiddev1
SEQNUM=20607
USEC_INITIALIZED=733865619323
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_SECURITY_TOKEN=1
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1:1.1
ID_PATH=pci-0000:00:14.0-usb-0:1:1.1
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1_1_1
ID_FOR_SEAT=usbmisc-pci-0000_00_14_0-usb-0_1_1_1
ID_VENDOR=Yubico
MAJOR=180
MINOR=97
TAGS=:seat:uaccess:
CURRENT_TAGS=:seat:uaccess:

UDEV  [733869.253678] remove   /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.1/0003:1050:0407.006A/hidraw/hidraw2 (hidraw)
ACTION=remove
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.1/0003:1050:0407.006A/hidraw/hidraw2
SUBSYSTEM=hidraw
DEVNAME=/dev/hidraw2
SEQNUM=20608
USEC_INITIALIZED=733865619393
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_FIDO_TOKEN=1
ID_SECURITY_TOKEN=1
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1:1.1
ID_PATH=pci-0000:00:14.0-usb-0:1:1.1
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1_1_1
ID_FOR_SEAT=hidraw-pci-0000_00_14_0-usb-0_1_1_1
MAJOR=246
MINOR=2
TAGS=:seat:security-device:uaccess:
CURRENT_TAGS=:seat:security-device:uaccess:

UDEV  [733869.254655] unbind   /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.2 (usb)
ACTION=unbind
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.2
SUBSYSTEM=usb
DEVTYPE=usb_interface
PRODUCT=1050/407/527
TYPE=0/0/0
INTERFACE=11/0/0
SEQNUM=20613
USEC_INITIALIZED=733865619622
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1:1.2
ID_PATH=pci-0000:00:14.0-usb-0:1:1.2
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1_1_2

UDEV  [733869.255021] unbind   /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069 (hid)
ACTION=unbind
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069
SUBSYSTEM=hid
HID_ID=0003:00001050:00000407
HID_NAME=Yubico YubiKey OTP+FIDO+CCID
HID_PHYS=usb-0000:00:14.0-1/input0
HID_UNIQ=
SEQNUM=20603
USEC_INITIALIZED=733865593428
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin

UDEV  [733869.255102] unbind   /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.1/0003:1050:0407.006A (hid)
ACTION=unbind
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.1/0003:1050:0407.006A
SUBSYSTEM=hid
HID_ID=0003:00001050:00000407
HID_NAME=Yubico YubiKey OTP+FIDO+CCID
HID_PHYS=usb-0000:00:14.0-1/input1
HID_UNIQ=
SEQNUM=20609
USEC_INITIALIZED=733865619258
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin

UDEV  [733869.255317] remove   /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.2 (usb)
ACTION=remove
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.2
SUBSYSTEM=usb
DEVTYPE=usb_interface
PRODUCT=1050/407/527
TYPE=0/0/0
INTERFACE=11/0/0
MODALIAS=usb:v1050p0407d0527dc00dsc00dp00ic0Bisc00ip00in02
SEQNUM=20614
USEC_INITIALIZED=733865619622
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1:1.2
ID_PATH=pci-0000:00:14.0-usb-0:1:1.2
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1_1_2

UDEV  [733869.255444] remove   /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069 (hid)
ACTION=remove
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0/0003:1050:0407.0069
SUBSYSTEM=hid
HID_ID=0003:00001050:00000407
HID_NAME=Yubico YubiKey OTP+FIDO+CCID
HID_PHYS=usb-0000:00:14.0-1/input0
HID_UNIQ=
MODALIAS=hid:b0003g0001v00001050p00000407
SEQNUM=20604
USEC_INITIALIZED=733865593428
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin

UDEV  [733869.255592] remove   /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.1/0003:1050:0407.006A (hid)
ACTION=remove
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.1/0003:1050:0407.006A
SUBSYSTEM=hid
HID_ID=0003:00001050:00000407
HID_NAME=Yubico YubiKey OTP+FIDO+CCID
HID_PHYS=usb-0000:00:14.0-1/input1
HID_UNIQ=
MODALIAS=hid:b0003g0001v00001050p00000407
SEQNUM=20610
USEC_INITIALIZED=733865619258
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin

UDEV  [733869.256083] unbind   /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0 (usb)
ACTION=unbind
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0
SUBSYSTEM=usb
DEVTYPE=usb_interface
PRODUCT=1050/407/527
TYPE=0/0/0
INTERFACE=3/1/1
SEQNUM=20605
USEC_INITIALIZED=733865593386
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1:1.0
ID_PATH=pci-0000:00:14.0-usb-0:1:1.0
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1_1_0

UDEV  [733869.256291] unbind   /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.1 (usb)
ACTION=unbind
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.1
SUBSYSTEM=usb
DEVTYPE=usb_interface
PRODUCT=1050/407/527
TYPE=0/0/0
INTERFACE=3/0/0
SEQNUM=20611
USEC_INITIALIZED=733865618802
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1:1.1
ID_PATH=pci-0000:00:14.0-usb-0:1:1.1
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1_1_1

UDEV  [733869.256500] remove   /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0 (usb)
ACTION=remove
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.0
SUBSYSTEM=usb
DEVTYPE=usb_interface
PRODUCT=1050/407/527
TYPE=0/0/0
INTERFACE=3/1/1
MODALIAS=usb:v1050p0407d0527dc00dsc00dp00ic03isc01ip01in00
SEQNUM=20606
USEC_INITIALIZED=733865593386
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1:1.0
ID_PATH=pci-0000:00:14.0-usb-0:1:1.0
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1_1_0

UDEV  [733869.256760] remove   /devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.1 (usb)
ACTION=remove
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1/3-1:1.1
SUBSYSTEM=usb
DEVTYPE=usb_interface
PRODUCT=1050/407/527
TYPE=0/0/0
INTERFACE=3/0/0
MODALIAS=usb:v1050p0407d0527dc00dsc00dp00ic03isc00ip00in01
SEQNUM=20612
USEC_INITIALIZED=733865618802
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1:1.1
ID_PATH=pci-0000:00:14.0-usb-0:1:1.1
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1_1_1

UDEV  [733869.257531] unbind   /devices/pci0000:00/0000:00:14.0/usb3/3-1 (usb)
ACTION=unbind
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1
SUBSYSTEM=usb
DEVNAME=/dev/bus/usb/003/062
DEVTYPE=usb_device
PRODUCT=1050/407/527
TYPE=0/0/0
BUSNUM=003
DEVNUM=062
SEQNUM=20615
USEC_INITIALIZED=733865563180
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1
ID_PATH=pci-0000:00:14.0-usb-0:1
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1
MAJOR=189
MINOR=317
TAGS=:seat:security-device:systemd:uaccess:

UDEV  [733869.258224] remove   /devices/pci0000:00/0000:00:14.0/usb3/3-1 (usb)
ACTION=remove
DEVPATH=/devices/pci0000:00/0000:00:14.0/usb3/3-1
SUBSYSTEM=usb
DEVNAME=/dev/bus/usb/003/062
DEVTYPE=usb_device
PRODUCT=1050/407/527
TYPE=0/0/0
BUSNUM=003
DEVNUM=062
SEQNUM=20616
USEC_INITIALIZED=733865563180
PATH=/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/bin:/nix/store/kxdwld6bh9wcwnkmc9nlwymx3km25v1h-udev-path/sbin
ID_PATH_WITH_USB_REVISION=pci-0000:00:14.0-usbv2-0:1
ID_PATH=pci-0000:00:14.0-usb-0:1
ID_PATH_TAG=pci-0000_00_14_0-usb-0_1
MAJOR=189
MINOR=317
TAGS=:seat:security-device:systemd:uaccess:

```
