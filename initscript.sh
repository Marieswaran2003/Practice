#!/bin/bash

sudo dnf install -y httpd

sudo systemctl enable --now httpd

sudo cp -r Practice/index.html /var/www/html/

SERVER="root@serverb"
#
#echo "Installing HTTPD..."
ssh $SERVER "dnf install -y httpd"
#
echo "Updating Apache Port from 80 to 82..."
ssh $SERVER "sed -i 's/^Listen 80$/Listen 82/' /etc/httpd/conf/httpd.conf"

#
echo "Adding webpage content..."
ssh $SERVER "echo 'All the best guys keep rocking!!' > /var/www/html/index.html"
#
#echo "Enabling & Starting HTTPD Service..."
#ssh $SERVER "systemctl enable --now httpd"
#
#echo "Restarting HTTPD..."
#ssh $SERVER "systemctl restart httpd"
#
echo "HTTPD Setup Completed Successfully on serverb!"
#

ssh root@utility.lab.example.com << 'EOF'
echo "Setting up NFS share on utility machine"
mkdir -p /user-homes/production5
chmod 777 /user-homes/production5

# Install and enable NFS
dnf install -y nfs-utils
systemctl enable --now nfs-server
#
# # Configure exports
echo "/user-homes/production5 *(rw,sync,no_root_squash)" > /etc/exports
exportfs -rav
#
#Configure firewall for NFS
systemctl enable --now firewalld
firewall-cmd --permanent --add-service=nfs
firewall-cmd --permanent --add-service=mountd
firewall-cmd --permanent --add-service=rpc-bind
firewall-cmd --reload
#
# # Verify
echo "NFS export configured successfully:"
exportfs -v
echo "Firewall rules:"
firewall-cmd --list-all
EOF

#Clone a Repository

#Booting Menu
echo "Lab Script"
lab start rootpw-recover

echo "Servera Updation"
echo "Creating 1GB partition on servera..."

ssh root@servera '(
echo -e "n\np\n1\n\n+1G\nw" | fdisk /dev/sdb
partprobe /dev/sdb
)'

echo "Partition /dev/sdb1 created and formatted with XFS on servera."

ssh root@servera.lab.example.com  vgcreate -s 8M vg /dev/sdb1
ssh root@servera.lab.example.com  lvcreate -L 100M  -n lv  vg
ssh root@servera.lab.example.com mkdir /lo
ssh root@servera.lab.example.com 'mkfs.ext3 /dev/vg/lv'
ssh root@servera.lab.example.com 'echo "/dev/vg/lv  /lo  ext3  defaults 0 0" >> /etc/fstab'
ssh root@servera.lab.example.com  mount -a
ssh root@servera.lab.example.com  lsblk
ssh root@servera.lab.example.com 'tuned-adm profile powersave'
ssh root@serverb.lab.example.com rm -rvf /etc/yum.repos.d/*
ssh root@servera.lab.example.com rm -rvf /etc/yum.repos.d/*
echo "All The Best"
