spark-openstack
=========

This repository contains the set of scripts used to setup a Spark cluster on
your own Openstack installation. These scripts are intended to be used by special
image prepared for Openstack and is *not* expected to work on other AMIs. This
special image will be available soon when we finish testing.
Instructions for use are in progress.

### Details


The Spark cluster setup is guided by the values set in `ec2-variables.sh`.`setup.sh`
first performs basic operations like enabling ssh across machines, mounting ephemeral
drives and also creates files named `/root/spark-openstack/masters`, and
`/root/spark-openstack/slaves`.
Following that every module listed in `MODULES` is initialized. 

To add a new module, you will need to do the following:

  a. Create a directory with the module's name
  
  b. Optionally add a file named `init.sh`. This is called before templates are configured 
and can be used to install any pre-requisites.

  c. Add any files that need to be configured based on the cluster setup to `templates/`.
  The path of the file determines where the configured file will be copied to. Right now
  the set of variables that can be used in a template are
  
      {{master_list}}
      {{active_master}}
      {{slave_list}}
      {{zoo_list}}
      {{cluster_url}}
      {{hdfs_data_dirs}}
      {{mapred_local_dirs}}
      {{spark_local_dirs}}
      {{default_spark_mem}}
      
   You can add new variables by modifying `deploy_templates.py`
   
   d. Add a file named `setup.sh` to launch any services on the master/slaves. This is called
   after the templates have been configured. You can use the environment variables `$SLAVES` to
   get a list of slave hostnames and `/root/spark-openstack/copy-dir` to sync a
   directory across machines.
      
   e. Modify https://github.com/mesos/spark/blob/master/openstack/spark_openstack.py to
   add your module to the list of enabled modules (it will be valid after spark team will
   approve our code).
