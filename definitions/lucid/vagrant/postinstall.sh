#!/bin/bash -e

# most of this script taken from veewee, vagrant
umask 022

# dont prompt
export DEBIAN_FRONTEND="noninteractive"

# udev cleanup
rm -rf /etc/udev/rules.d/70-persistent-net.rules
mkdir -p /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm -rf /lib/udev/rules.d/75-persistent-net-generator.rules

# dhcp cleanup
rm -f /var/lib/dhcp3/*

# build requirements for virtual box guest additions
aptitude install -y build-essential wget linux-headers-$(uname -r)

tmp_vguest=$(mktemp -t XXXXXXXXX)

VBOX_VERSION=$(cat ~/.vbox_version)
wget -O $tmp_vguest http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso

mount -o loop $tmp_vguest /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt

rm $tmp_vguest

# grant sudo permissions
cat > /etc/sudoers <<EOF
Defaults env_reset
root ALL=(ALL) ALL
EOF

chmod 440 /etc/sudoers

# update OS packages
if [[ -z $(grep multiverse /etc/apt/sources.list) ]]; then
  sed -i s/universe/"universe multiverse"/ /etc/apt/sources.list
fi

# install the basics
aptitude install -q -y rsync figlet 

# install build packages
figlet "ruby"
aptitude install -q -y ruby rubygems

# upgrade rubygems
gem install rubygems-update -v 1.5.3
cd /var/lib/gems/1.8/gems/rubygems-update-1.5.3
ruby setup.rb
gem uninstall rubygems-update -x -a || true
