#Stop services for cleanup
sudo service rsyslog stop

#clear audit logs
# -s0 sets the bites to 0 erasing the file
sudo truncate -s0 /var/log/wtmp
sudo truncate -s0 /var/log/lastlog

#cleanup /tmp directories
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*

#cleanup current ssh keys
sudo rm -f /etc/ssh/ssh_host_*

#add check for ssh keys on reboot...regenerate if neccessary
cat <<EOL | sudo tee /etc/rc.local
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#

# dynamically create hostname
if hostname | grep localhost; then
    $hn = "vmUbu1804-"
    $rand=head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo ''
    hostnamectl set-hostname $($hn$rand)
fi

# By default this script does nothing.
test -f /etc/ssh/ssh_host_dsa_key || dpkg-reconfigure openssh-server
exit 0
EOL

# make the script executable
sudo chmod +x /etc/rc.local

#reset hostname
# prevent cloudconfig from preserving the original hostname
sudo sed -i 's/preserve_hostname: false/preserve_hostname: true/g' /etc/cloud/cloud.cfg
sudo truncate -s0 /etc/hostname
sudo hostnamectl set-hostname localhost

#cleanup apt
sudo apt clean

# cleans out all of the cloud-init cache / logs - this is mainly cleaning out networking info
sudo cloud-init clean --logs

#cleanup shell history
history -c
history -w
