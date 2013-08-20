# Set Hadoop-specific environment variables here.

# The only required environment variable is JAVA_HOME.  All others are
# optional.  When running a distributed configuration it is best to
# set JAVA_HOME in this file, so that it is correctly defined on
# remote nodes.

# The java implementation to use.  Required.
export JAVA_HOME={{java_home}}

# Mesos build directory, useful for finding JARs and the native library.
export MESOS_BUILD_DIR=/root/mesos/build

# Google protobuf (necessary for running the MesosScheduler).
export PROTOBUF_JAR=${MESOS_BUILD_DIR}/protobuf-2.3.0.jar

# Mesos.
MESOS_VERSION=`echo @PACKAGE_VERSION@ | ${MESOS_BUILD_DIR}/config.status --file=-:-`
export MESOS_JAR=${MESOS_BUILD_DIR}/src/mesos-${MESOS_VERSION}.jar

# Native Mesos library.
export MESOS_NATIVE_LIBRARY=${MESOS_BUILD_DIR}/src/.libs/libmesos.so

# Extra Java CLASSPATH elements.  Optional.
export HADOOP_CLASSPATH=${HADOOP_HOME}/build/contrib/mesos/classes:${MESOS_JAR}:${PROTOBUF_JAR}

# The maximum amount of heap to use, in MB. Default is 1000.
export HADOOP_HEAPSIZE=1000

# Extra Java runtime options.  Empty by default.
# export HADOOP_OPTS=-server
export HADOOP_OPTS="-Djava.net.preferIPv4Stack=true"

# Command specific options appended to HADOOP_OPTS when specified
export HADOOP_NAMENODE_OPTS="-Dcom.sun.management.jmxremote $HADOOP_NAMENODE_OPTS"
export HADOOP_SECONDARYNAMENODE_OPTS="-Dcom.sun.management.jmxremote $HADOOP_SECONDARYNAMENODE_OPTS"
export HADOOP_DATANODE_OPTS="-Dcom.sun.management.jmxremote $HADOOP_DATANODE_OPTS"
export HADOOP_BALANCER_OPTS="-Dcom.sun.management.jmxremote $HADOOP_BALANCER_OPTS"
export HADOOP_JOBTRACKER_OPTS="-Dcom.sun.management.jmxremote $HADOOP_JOBTRACKER_OPTS"
# export HADOOP_TASKTRACKER_OPTS=
# The following applies to multiple commands (fs, dfs, fsck, distcp etc)
# export HADOOP_CLIENT_OPTS

# Extra ssh options.  Empty by default.
# export HADOOP_SSH_OPTS="-o ConnectTimeout=1 -o SendEnv=HADOOP_CONF_DIR"
export HADOOP_SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5"

# Where log files are stored.  $HADOOP_HOME/logs by default.
# export HADOOP_LOG_DIR=${HADOOP_HOME}/logs
export HADOOP_LOG_DIR=/mnt/hadoop-logs

# File naming remote slave hosts.  $HADOOP_HOME/conf/slaves by default.
# export HADOOP_SLAVES=${HADOOP_HOME}/conf/slaves

# host:path where hadoop code should be rsync'd from.  Unset by default.
# export HADOOP_MASTER=master:/home/$USER/src/hadoop

# Seconds to sleep between slave commands.  Unset by default.  This
# can be useful in large clusters, where, e.g., slave rsyncs can
# otherwise arrive faster than the master can service them.
# export HADOOP_SLAVE_SLEEP=0.1

# The directory where pid files are stored. /tmp by default.
# export HADOOP_PID_DIR=/var/hadoop/pids

# A string representing this instance of hadoop. $USER by default.
# export HADOOP_IDENT_STRING=$USER

# The scheduling priority for daemon processes.  See 'man nice'.
# export HADOOP_NICENESS=10

ulimit -n 10000
