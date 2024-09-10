#######################################################################################################

IMGDIR=/var/lib/libvirt/images
BKGIMG=rhel-9.4-x86_64-kvm.qcow2
OSVAR=rhel9.0

if [ $UID != '0' ]; 
     then echo "You must be root or run as sudo"
	exit 0
fi

echo "What is the name of this virtual machine?"
read NAME

echo "What is the domain name? ex: redhat.local, jrickard.io"
read DOMAIN

echo "How much ram in MB for ${NAME}?"
read RAM

echo "How many cpus for ${NAME}?"
read VCPUS

echo "What size disk in GB?"
read DSKSIZE

echo "A machine will be created with the following characteristics:
  NAME: ${NAME}.${DOMAIN}
  RAM: ${RAM}
  CPU: ${VCPUS}
  DISK: ${DSKSIZE}
"
echo "Is this correct? [Y/y|N/n]"
read ANS
if [ ${ANS} == ""]; then
	echo -e "you must enter either Yy|Nn\n"
fi
build_vm () {
  echo "Creating disk image"
  qemu-img create -f qcow2 -b ${IMGDIR}/${BKGIMG} -F qcow2 ${IMGDIR}/${NAME}.qcow2 ${DSKSIZE}G
  virt-resize --expand /dev/sda4 ${IMGDIR}/${BKGIMG} ${IMGDIR}/${NAME}.qcow2
  echo "Setting hostname to ${NAME}.${DOMAIN}"
  virt-customize -a ${IMGDIR}/${NAME}.qcow2 --hostname ${NAME}.${DOMAIN} --selinux-relabel
  echo "Creating virtual machine"
  virt-install --name ${NAME}.${DOMAIN} --memory ${RAM} --vcpus ${VCPUS} --disk ${IMGDIR}/${NAME}.qcow2,bus=virtio,device=disk,format=qcow2 --import --os-variant ${OSVAR} --graphics spice,listen=127.0.0.1 --noautoconsole --network network=default 
  echo "Gathering access information"
  sleep 20
  export IPADD="$(virsh domifaddr ${NAME}.${DOMAIN} | egrep -v 'Name|^$' | awk '{print $4}' | awk '$1=$1' | cut -d / -f1)"
  echo "${NAME} can be reached via ssh at ${IPADD} using root / redhat"
  exit 0
  }

 case "${ANS}" in
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
