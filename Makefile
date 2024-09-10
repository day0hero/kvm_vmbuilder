# Define the password for the root user in the cloud image
IMGPASS ?= password
# Virtual Machine Image Directory
IMGDIR ?= /var/lib/libvirt/images
#Backing Store Image - this is the base image that all vms are provisioned from
BKGIMG ?= rhel-9.4-x86_64-kvm.qcow2
# Virtual Machine name
NAME ?= kvm-vm
# Number of vCPUS to assign to VM
VCPUS ?= 4
# RAM to give to VM in MiB
RAM ?= 8192
# DISK Size 
DSKSIZE ?= 200G
# Operating System Variant (rhel7.0,rhel8.0)
OSVAR ?= rhel9.0

.PHONY: help
# No need to add a comment here as help is described in common/
help:
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^(\s|[a-zA-Z_0-9-])+:.*?##/ { printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: setpass
setpass: ## Set password in the image
	virt-customize -a $(IMGDIR)/$(BKGIMG) --root-password password:$(IMGPASS)

.PHONY: createdisk
createdisk: ## Create kvm 
	@echo "Creating and resizing vm disk image in $(IMGDIR)"
	qemu-img create -f qcow2 -b $(IMGDIR)/$(BKGIMG) -F qcow2 $(IMGDIR)/$(NAME).qcow2 $(DSKSIZE)
	virt-resize --expand /dev/sda4 $(IMGDIR)/$(BKGIMG) $(IMGDIR)/$(NAME).qcow2 

.PHONY: build
build: createdisk ## Create virtualmachine
	@echo "Creating virtualmachine"
	sudo virt-install --name $(NAME) --memory $(RAM) --vcpus $(VCPUS) --disk $(IMGDIR)/$(NAME).qcow2,bus=virtio,device=disk,format=qcow2 --network network=default --import --os-variant $(OSVAR) --noautoconsole --graphics spice,listen=127.0.0.1

PHONY: delete
delete: ## Delete virtualmachine
	@echo "Deleting virtualmachine"
	virsh destroy $(NAME)
	virsh undefine $(NAME) --remove-all-storage
	@echo "Virtualmachine deleted"
