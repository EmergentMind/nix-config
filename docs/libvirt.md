# libvirt issues

- [libvirt issues](#libvirt-issues)
  - [networking](#networking)

## networking

set up virtual network for virt

create a file called foo.xml with:

```
<network connections='1'>
  <name>default</name>
  <uuid>8e91d351-e902-4fce-99b6-e5ea88ac9b80</uuid>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='virbr0' stp='on' delay='0'/>
  <mac address='52:54:00:f8:26:85'/>
  <ip address='192.168.122.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.122.2' end='192.168.122.254'/>
    </dhcp>
  </ip>
</network>
```

Then run the following:
```
sudo virsh net-define foo.xml
sudo net-start default
sudo net-autostart default
```



If qemu isn't working because of lack of network, you need to run:

```bash
virsh net-autostart default
virsh net-start default
```

Is not clear how to get the first command to be part of the nix config
