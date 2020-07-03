#######################################################################################################

disk_pth=/var/lib/libvirt/images
back_dsk=rhel-server-7.5-x86_64-kvm.qcow2

if [ $UID != '0' ]; 
     then echo "You must be root or run as sudo"
	exit 0
fi

echo "What is the name of this virtual machine?"
read name

echo "What is the domain name? ex: redhat.local clusterfudge.net"
read domain

echo "How much ram in MB for ${name}?"
read ram

echo "How many cpus for ${name}?"
read vcpus

echo "What size disk in GB?"
read disk_size

echo "A machine will be created with the following characteristics:
  NAME: ${name}.${domain}
  RAM: ${ram}
  CPU: ${vcpus}
  DISK: ${disk_size}
"
echo "Is this correct? [Y/y|N/n]"
read ans
if [ ${ans} == ""]; then
	echo -e "you must enter either Yy|Nn\n"
fi
build_vm () {
  echo "Creating disk image"
  qemu-img create -f qcow2 -b ${disk_pth}/${back_dsk} ${disk_pth}/${name}.qcow2 ${disk_size}G
  virt-resize --expand /dev/sda1 ${disk_pth}/${back_dsk} ${disk_pth}/${name}.qcow2
  echo "Setting hostname to ${name}.${domain}"
  virt-customize -a ${disk_pth}/${name}.qcow2 --hostname ${name}.${domain} --selinux-relabel
  echo "Creating virtual machine"
  virt-install --name ${name}.${domain} --ram ${ram} --vcpus ${vcpus} --disk path=${disk_pth}/${name}.qcow2,bus=virtio,device=disk,format=qcow2 --import --os-variant rhel7.0 --vnc --noautoconsole --network network:default 
  echo "Gathering access information"
  sleep 20
  export IPADD="$(virsh domifaddr ${name}.${domain} | egrep -v 'Name|^$' | awk '{print $4}' | awk '$1=$1' | cut -d / -f1)"
  echo "${name} can be reached via ssh at ${IPADD} using root / redhat"
  exit 0
  }

 case "${ans}" in
	N* )
          echo "exiting, re-run"
          ;;
	n* )
          echo "exiting, re-run"
          ;;
         Y* )
          build_vm
           ;;
         y* )
          build_vm
           ;;
esac
