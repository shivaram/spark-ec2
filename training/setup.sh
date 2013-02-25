#!/bin/bash

pushd /root

# Install ipython for our tutorial.
# NOTE: Done in the AMI
# easy_install ipython

#for node in $SLAVES $OTHER_MASTERS; do
#  echo $node
#  ssh -t -t $SSH_OPTS root@$node "easy_install ipython" & sleep 0.3
#done
#wait

yum install -y numpy
for node in $SLAVES $OTHER_MASTERS; do
  echo $node
  ssh -t -t $SSH_OPTS root@$node "yum install -y numpy" & sleep 0.3
done
wait

ssh-keyscan -H github.com >> /root/.ssh/known_hosts
rm -rf training
git clone https://github.com/amplab/training.git

pushd training
/root/spark-ec2/copy-dir /root/training 

#cp -r streaming /root/
#cp -r kmeans /root/
#cp -r java-app-template /root/
#cp -r scala-app-template /root/

ln -s /root/training/streaming /root/streaming
ln -s /root/training/kmeans /root/kmeans
ln -s /root/training/java-app-template /root/java-app-template
ln -s /root/training/scala-app-template /root/scala-app-template

popd
popd

#/root/spark-ec2/copy-dir /root/streaming
#/root/spark-ec2/copy-dir /root/kmeans
#/root/spark-ec2/copy-dir /root/java-app-template
#/root/spark-ec2/copy-dir /root/scala-app-template

# Training specific hacks

# Check if Hadoop version is 0.205.0 in project/SparkBuild.scala
# if not rebuild spark

HADOOP_VERSION=`cat /root/spark/project/SparkBuild.scala | grep "val HADOOP_VERSION =" | grep -v "//" | awk '{print $NF}' | tr -d \"`
if [[ "$HADOOP_VERSION" != "0.20.205.0" ]]; then
  echo "Setting hadoop version to 0.20.205.0 ..."
  sed -i 's/val HADOOP_VERSION = \"'$HADOOP_VERSION'\"/val HADOOP_VERSION = \"0.20.205.0\"/g' /root/spark/project/SparkBuild.scala
  pushd /root/spark
  ./sbt/sbt clean publish-local
  /root/spark-ec2/copy-dir /root/spark
  popd
fi
