#!/bin/bash
mapper=`printenv mapred_task_id | cut -d "_" -f 5`
rm -f temp.cache
date +"%F %T Start training mapper=$mapper" > /dev/stderr
vwcmd="/root/vowpal_wabbit/vowpalwabbit/vw --total $mapred_map_tasks --node $mapper --cache_file temp.cache --span_server $mapreduce_job_submithost --loss_function classic"
mapred_job_id=`echo $mapred_job_id | tr -d 'job_'`
gdcmd="$vwcmd --unique_id $mapred_job_id --passes 20 --sgd -d /dev/stdin -f model"
mapred_job_id=`expr $mapred_job_id \* 2` #create new nonce
if [ "$mapper" == '000000' ]; then
    $gdcmd > mapperout 2>&1
    if [ $? -ne 0 ]; then
      date +"%F %T Failed mapper=$mapper cmd=$gdcmd" > /dev/stderr
      exit 1
    fi
    outfile=$mapred_output_dir/model
    mapperfile=$mapred_output_dir/mapperout
    found=`/root/ephemeral-hdfs/bin/hadoop dfs -lsr / | grep $mapred_output_dir | grep mapperout`
    if [ "$found" != "" ]; then
      /root/ephemeral-hdfs/bin/hadoop dfs -rm -r $mapperfile
    fi
    found=`/root/ephemeral-hdfs/bin/hadoop dfs -lsr / | grep $mapred_output_dir | grep model`
    if [ "$found" != "" ]; then
      /root/ephemeral-hdfs/bin/hadoop dfs -rm -r $outfile
    fi
    date +"%F %T outfile=$outfile" > /dev/stderr
    /root/ephemeral-hdfs/bin/hadoop dfs -put model $outfile
    /root/ephemeral-hdfs/bin/hadoop dfs -put mapperout $mapperfile
else
    $gdcmd
    if [ $? -ne 0 ]; then
      date +"%F %T Failed mapper=$mapper cmd=$gdcmd" > /dev/stderr
      exit 1
    fi
fi
date +"%F %T Done mapper=$mapper" > /dev/stderr

