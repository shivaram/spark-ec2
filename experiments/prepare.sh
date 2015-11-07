y | sudo yum update binutils

# Have to call this part of keystone setup.sh again because of unclear bug in setup scripts...
/root/matrix-bench/build-openblas-ec2.sh
/root/spark-ec2/copy-dir /root/openblas-install

~/spark/sbin/slaves.sh rm /etc/ld.so.conf.d/atlas-x86_64.conf
~/spark/sbin/slaves.sh ldconfig
~/spark/sbin/slaves.sh ln -sf /root/openblas-install/lib/libopenblas.so /usr/lib64/liblapack.so.3
~/spark/sbin/slaves.sh ln -sf /root/openblas-install/lib/libopenblas.so /usr/lib64/libblas.so.3

rm /etc/ld.so.conf.d/atlas-x86_64.conf
ldconfig
ln -sf /root/openblas-install/lib/libopenblas.so /usr/lib64/liblapack.so.3
ln -sf /root/openblas-install/lib/libopenblas.so /usr/lib64/libblas.so.3

