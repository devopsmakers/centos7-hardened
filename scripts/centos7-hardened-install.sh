# Installs cloudinit, cloud-init, havaged - requires epel repo
yum -y install wget

version=7
mirror=http://mirror.bytemark.co.uk/centos/

# Detect primary root drive
if [ -e /dev/xvda ]; then
  drive=xvda
elif [ -e /dev/vda ]; then
  drive=vda
elif [ -e /dev/sda ]; then
  drive=sda
fi

mkdir /boot/centos
cd /boot/centos
wget ${mirror}/${version}/os/x86_64/isolinux/vmlinuz
wget ${mirror}/${version}/os/x86_64/isolinux/initrd.img


# This kickstart file has been adapted from the scap-security-guide kickstart
# file in: https://github.com/OpenSCAP/scap-security-guide and the RedHatGov
# project: https://github.com/RedHatGov/ssg-el7-kickstart
cat > /boot/centos/kickstart.ks << EOKSCONFIG
# SCAP Security Guide OSPP/USGCB profile kickstart for Red Hat Enterprise Linux 7 Server
# Version: 0.0.2
# Date: 2015-11-19
#
# Based on:
# http://fedoraproject.org/wiki/Anaconda/Kickstart
# https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Installation_Guide/sect-kickstart-syntax.html
# http://usgcb.nist.gov/usgcb/content/configuration/workstation-ks.cfg

# Text or Graphical
text

# Install a fresh new system (optional)
install

# Don't run the Setup Agent on first boot
firstboot --disable

# Accept Eula
eula --agreed

# Suppress unsupported hardware warning
unsupported_hardware

# Don't configure X even if installed
skipx

# Specify installation method to use for installation
# To use a different one comment out the 'url' one below, update
# the selected choice with proper options & un-comment it
#
# Install from an installation tree on a remote server via FTP or HTTP:
# --url		the URL to install from
#
# Example:
#
# url --url=http://192.168.122.1/image
#
# Modify concrete URL in the above example appropriately to reflect the actual
# environment machine is to be installed in
#
# Other possible / supported installation methods:
# * install from the first CD-ROM/DVD drive on the system:
#
# cdrom
#
# * install from a directory of ISO images on a local drive:
#
# harddrive --partition=hdb2 --dir=/tmp/install-tree
#
# * install from provided NFS server:
#
# nfs --server=<hostname> --dir=<directory> [--opts=<nfs options>]
#

# We'll be using a known good mirror of CentOS repos for the install
# Many thanks to ByteMark, a Manchester based ISP worth checking out
url --url="http://mirror.bytemark.co.uk/centos/7/os/x86_64/"
repo --name="base" --baseurl=http://mirror.bytemark.co.uk/centos/7/os/x86_64/
# Including the updates repo ensures we install the latest packages at install time
repo --name="updates" --baseurl=http://mirror.bytemark.co.uk/centos/7/updates/x86_64/
repo --name="extras" --baseurl=http://mirror.bytemark.co.uk/centos/7/extras/x86_64/
repo --name="epel" --baseurl=http://mirror.bytemark.co.uk/fedora/epel/7/x86_64/
repo --name="puppet" --baseurl=https://yum.puppetlabs.com/el/7/PC1/x86_64/

# OS Locale and time
lang en_GB.UTF-8
keyboard uk
timezone Europe/London --isUtc --ntpservers=0.centos.pool.ntp.org,1.centos.pool.ntp.org,2.centos.pool.ntp.org,3.centos.pool.ntp.org

# Configure network information for target system and activate network devices in the installer environment (optional)
# --onboot	enable device at a boot time
# --device	device to be activated and / or configured with the network command
# --bootproto	method to obtain networking configuration for device (default dhcp)
# --noipv6	disable IPv6 on this device
#
# NOTE: Usage of DHCP will fail CCE-27021-5 (DISA FSO RHEL-06-000292). To use static IP configuration,
#       "--bootproto=static" must be used. For example:
# network --bootproto=static --ip=10.0.2.15 --netmask=255.255.255.0 --gateway=10.0.2.254 --nameserver 192.168.2.1,192.168.3.1
#
network --onboot yes --device eth0 --bootproto dhcp --ipv6=auto --activate

# Set the system's root password (required)
rootpw --lock --iscrypted "*"

# Configure firewall settings for the system (optional)
# --enabled	reject incoming connections that are not in response to outbound requests
# --ssh		allow sshd service through the firewall
firewall --enabled --ssh

# Set up the authentication options for the system (required)
# --enableshadow	enable shadowed passwords by default
# --passalgo		hash / crypt algorithm for new passwords
# See the manual page for authconfig for a complete list of possible options.
authconfig --enableshadow --passalgo=sha512

# State of SELinux on the installed system (optional)
# Defaults to enforcing
selinux --enforcing

# Specify how the bootloader should be installed (required)
bootloader --location=mbr --append="crashkernel=auto rhgb quiet" --timeout=0

# Initialize (format) all disks (optional)
zerombr

# The following partition layout scheme assumes disk of size 20GB or larger
# Modify size of partitions appropriately to reflect actual machine's hardware
#
# Remove Linux partitions from the system prior to creating new ones (optional)
# --linux	erase all Linux partitions
# --initlabel	initialize the disk label to the default based on the underlying architecture
clearpart --linux --initlabel

# Create primary system partitions (required for installs)
part /boot --fstype=xfs --size=512
part pv.00 --grow --size=1

# Create a Logical Volume Management (LVM) group (optional)
volgroup VolGroup00 --pesize=4096 pv.00

# Create particular logical volumes (optional)
logvol / --fstype=xfs --name=00_root --vgname=VolGroup00 --size=256 --fsoptions="defaults,nobarrier,noatime,nodiratime"
# CCE-26557-9: Ensure /home Located On Separate Partition
logvol /home --fstype=xfs --name=01_home --vgname=VolGroup00 --size=1024 --fsoptions="defaults,nobarrier,noatime,nodiratime,nodev"
# CCE-26435-8: Ensure /tmp Located On Separate Partition
logvol /tmp --fstype=xfs --name=02_tmp --vgname=VolGroup00 --size=256 --fsoptions="defaults,nobarrier,noatime,nodiratime,nodev,noexec,nosuid"
# CCE-26639-5: Ensure /var Located On Separate Partition
logvol /var --fstype=xfs --name=03_var --vgname=VolGroup00 --size=512 --fsoptions="defaults,nobarrier,noatime,nodiratime,nodev"
logvol /var/tmp --fstype=xfs --name=04_var_tmp --vgname=VolGroup00 --size=256 --fsoptions="defaults,nobarrier,noatime,nodiratime,nodev,noexec,nosuid"
# CCE-26215-4: Ensure /var/log Located On Separate Partition
logvol /var/log --fstype=xfs --name=05_var_log --vgname=VolGroup00 --size=256 --fsoptions="defaults,nobarrier,noatime,nodiratime,nodev"
# CCE-26436-6: Ensure /var/log/audit Located On Separate Partition
logvol /var/log/audit --fstype=xfs --name=06_var_log_audit --vgname=VolGroup00 --size=256 --fsoptions="defaults,nobarrier,noatime,nodiratime,nodev"

# Usually where applications get put to run
logvol /opt --fstype=xfs --name=07_opt --vgname=VolGroup00 --size=512 --fsoptions="defaults,nobarrier,noatime,nodiratime,nodev"
logvol /usr --fstype=xfs --name=08_usr --vgname=VolGroup00 --size=1536 --fsoptions="defaults,nobarrier,noatime,nodiratime,nodev"

# Very small swap - we usually set swap to 1 for safety
logvol swap --name=lv_swap --vgname=VolGroup00 --size=128

# Service configuration
services --enabled=NetworkManager,sshd,chronyd,tuned,haveged

# Packages selection (%packages section is required)
%packages --excludedocs

# Install ther latest security guide packege
scap-security-guide

# CCE-27024-9: Install AIDE
aide

# Install libreswan package
libreswan

# A selection of basic system packages
@core
chrony
yum-utils
system-config-firewall-base
wget

# tuned is great for the cloud / virtual world
tuned

# Cloud init bootstraps instances based on this AMI
cloud-init

# havaged improves entropy in the virtual world
haveged

# unneeded firmware
-aic94xx-firmware
-atmel-firmware
-b43-openfwwf
-bfa-firmware
-ipw2100-firmware
-ipw2200-firmware
-ivtv-firmware
-iwl100-firmware
-iwl1000-firmware
-iwl3945-firmware
-iwl4965-firmware
-iwl5000-firmware
-iwl5150-firmware
-iwl6000-firmware
-iwl6000g2a-firmware
-iwl6050-firmware
-libertas-usb8388-firmware
-ql2100-firmware
-ql2200-firmware
-ql23xx-firmware
-ql2400-firmware
-ql2500-firmware
-rt61pci-firmware
-rt73usb-firmware
-xorg-x11-drv-ati-firmware
-zd1211-firmware

# Disable prelink by not installing it
-prelink
%end

# We can apply most security config at install time with the kickstart addon
%addon org_fedora_oscap
  content-type = scap-security-guide
  profile = pci-dss
%end

# A bit of cleanup post install
%post
# cloud-init config
mkdir -p /etc/cloud/
echo "---
users:
 - default

preserve_hostname: false

# This is our pre-base image. Update packages.
package_update: true
package_reboot_if_required: true

# We're in the UK so let's accept it.
locale_configfile: /etc/sysconfig/i18n
locale: en_GB.UTF-8
timezone: Europe/London

# SSH Configuration
disable_root: true
ssh_pwauth: no
ssh_deletekeys: true
ssh_genkeytypes: ~

syslog_fix_perms: ~

system_info:
  default_user:
    name: centos
    lock_passwd: false
    # password: centos
    passwd: $6$Uq.eaVbT3$mNtmpx.3bMPN/DuMs8BjRMCIrFzpglPPw2cf9TvjOU6mD4jav3NOGWQpHX8jF.IIiMhbTEve.zOsD7o6RXVB.1
    gecos: Administrator
    groups: [wheel, adm, systemd-journal]
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    shell: /bin/bash
  distro: rhel
  paths:
    cloud_dir: /var/lib/cloud
    templates_dir: /etc/cloud/templates
  ssh_svcname: sshd

# Edit these to our taste
cloud_init_modules:
 - migrator
 - bootcmd
 - write-files
 - growpart
 - resizefs
 - set_hostname
 - update_hostname
 - update_etc_hosts
 - rsyslog
 - users-groups
 - ssh

cloud_config_modules:
 - mounts
 - locale
 - set-passwords
 - yum-add-repo
 - package-update-upgrade-install
 - timezone
 - puppet
 - chef
 - salt-minion
 - mcollective
 - disable-ec2-metadata
 - runcmd

cloud_final_modules:
 - rightscale_userdata
 - scripts-per-once
 - scripts-per-boot
 - scripts-per-instance
 - scripts-user
 - ssh-authkey-fingerprints
 - keys-to-console
 - phone-home
 - final-message
" > /etc/cloud/cloud.cfg

# Cleanup SSH keys
rm -f /etc/ssh/*key*
rm -rf ~/.ssh/

# Don't require tty for ssh / sudo
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

# Run the virtual-guest tuned profile
echo "virtual-guest" > /etc/tune-profiles/active-profile

# Let SELinux relabel FS on next boot
touch /.autorelabel
%end
reboot --eject
EOKSCONFIG

echo "menuentry 'centosinstall' {
        set root='hd0,msdos1'
    linux /boot/centos/vmlinuz ip=dhcp ksdevice=eth0 ks=hd:${drive}1:/boot/centos/kickstart.ks method=${mirror}/${version}/os/x86_64/ lang=en_US keymap=us
        initrd /boot/centos/initrd.img
}" >> /etc/grub.d/40_custom

echo 'GRUB_DEFAULT=saved
GRUB_HIDDEN_TIMEOUT=
GRUB_TIMEOUT=2
GRUB_RECORDFAIL_TIMEOUT=5
GRUB_CMDLINE_LINUX_DEFAULT="quiet nosplash vga=771 nomodeset"
GRUB_DISABLE_LINUX_UUID=true' > /etc/default/grub

grub2-set-default 'centosinstall'
grub2-mkconfig -o /boot/grub2/grub.cfg

rm -rf ~/.ssh/*
rm -rf /root/*

reboot
