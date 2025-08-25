# Deps for spdk
apt-get install -y linux-modules-extra-$(uname -r)
apt-get install -y libmlx5-1
apt-get install -y libnuma1
apt-get install -y librdmacm1
apt-get install -y libfuse3-3
apt-get install -y libpmem1
apt-get install -y libaio-dev
apt-get install -y libiscsi7
apt-get install -y nvme-cli

# Deps for top cmd 
apt-get install -y libncurses5-dev libncursesw5-dev

# Deps for s3Backer
apt-get install -y libfuse2 nbd-client

# install s3backer
apt-get install -t migrx -y mgx-s3backer

# install spdk
apt-get install -t migrx -y mgx-spdk

# load nbd module
echo "nbd" | sudo tee -a /etc/modules
modprobe nbd

# set huge page
echo 2048 | tee /proc/sys/vm/nr_hugepages
mount -t hugetlbfs none /dev/hugepages

# create default dir for cache
mkdir -p /mnt/s3cache
chown -R mgx-core:mgx-core /mnt/s3cache
