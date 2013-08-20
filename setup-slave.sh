#!/bin/bash

# Make sure we are in the spark-openstack directory
cd /root/spark-openstack

source ec2-variables.sh

# Set hostname based on EC2 private DNS name, so that it is set correctly
# even if the instance is restarted with a different private DNS name
PRIVATE_DNS=`wget -q -O - http://169.254.169.254/latest/meta-data/local-hostname`
hostname $PRIVATE_DNS
echo $PRIVATE_DNS > /etc/hostname
HOSTNAME=$PRIVATE_DNS  # Fix the bash built-in hostname variable too

echo "Setting up slave on `hostname`..."

# Mount options to use for ext3 and xfs disks (the ephemeral disks
# are ext3, but we use xfs for EBS volumes to format them faster)
EXT3_MOUNT_OPTS="defaults,noatime,nodiratime"
XFS_MOUNT_OPTS="defaults,noatime,nodiratime,allocsize=8m"

# Mount any ephemeral volumes we might have beyond /mnt
function setup_extra_volume {
  device=$1
  mount_point=$2
  if [[ -e $device && ! -e $mount_point ]]; then
    mkdir -p $mount_point
    mount -o $EXT3_MOUNT_OPTS $device $mount_point
    echo "$device $mount_point auto $EXT3_MOUNT_OPTS 0 0" >> /etc/fstab
  fi
}
setup_extra_volume /dev/xvdc /mnt2
setup_extra_volume /dev/xvdd /mnt3
setup_extra_volume /dev/xvde /mnt4

# Mount cgroup file system
if [[ ! -e /cgroup ]]; then
  mkdir -p /cgroup
  mount -t cgroup none /cgroup
  echo "none /cgroup cgroup defaults 0 0" >> /etc/fstab
fi

# Format and mount EBS volume (/dev/sdv) as /vol if the device exists
if [[ -e /dev/sdv ]]; then
  # Check if /dev/sdv is already formatted
  if ! blkid /dev/sdv; then
    mkdir /vol
    if mkfs.xfs -q /dev/sdv; then
      mount -o $XFS_MOUNT_OPTS /dev/sdv /vol
      chmod -R a+w /vol
    else
      # mkfs.xfs is not installed on this machine or has failed;
      # delete /vol so that the user doesn't think we successfully
      # mounted the EBS volume
      rmdir /vol
    fi
  else
    # EBS volume is already formatted. Mount it if its not mounted yet.
    if ! grep -qs '/vol' /proc/mounts; then
      mkdir /vol
      mount -o $XFS_MOUNT_OPTS /dev/sdv /vol
      chmod -R a+w /vol
    fi
  fi
fi

# Make data dirs writable by non-root users, such as CDH's hadoop user
chmod -R a+w /mnt*

# Remove ~/.ssh/known_hosts because it gets polluted as you start/stop many
# clusters (new machines tend to come up under old hostnames)
rm -f /root/.ssh/known_hosts

# Create swap space on /mnt
/root/spark-openstack/create-swap.sh $SWAP_MB

# Allow memory to be over committed. Helps in pyspark where we fork
echo 1 > /proc/sys/vm/overcommit_memory
