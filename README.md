#KVM VM provisioner

Use this to provision KVM machines on your RHEL/Fedora host. 

## Assumptions:
- All necessary packages installed for qemu-kvm
- sudo access 
- qcow2 image is downloaded

## Defaults:
|Variable|Default|Description
|--------|-------|-----------|
|IMGPASS |`password`| Set the password for the root user in your qcow2 image |
|IMGDIR  |`/var/lib/libvirt/images`| Default path for libvirt images |
|BKGIMG  |`rhel-9.4-x86_64.qcow2`| Backing image for ``qemu-img` |
|NAME    |`kvm-vm`| Refer to usage for setting this via cli |
|VCPUS   | `4` | Number of vCPU's to assign |
|RAM     | `8192`| Amount of RAM in `MiB` to assign to virtualmachine|
|DSKSIZE | `25G`| Amount of disk for virtual machine in `GiB`
|OSVAR   | `rhel9.0` |Operating System Variant - ex: `rhel7.0, rhel8.0`|

## Usage:
Make:
`make help` - See What targets are available

Set the root password for the qcow image:
`make setpass IMGPASS=password`

Build a virtual machine:
`make build NAME=test.example.com`

Delete a virtual machine:
`make delete NAME=test.example.com`

**NOTE:** The flow for deleting a VM is: 
1. Poweroff (destroy) the vm
2. Delete (undefine)
3. Remove all associated storage

### Conclusion
The shell script (`vmbuild.sh`) is available but all of the action is in the Makefile targets. The script will provision a VM but assumes that the password for the image is already set.