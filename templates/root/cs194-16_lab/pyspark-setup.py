# Configure the necessary Spark environment
import os
os.environ['SPARK_HOME'] = '/root/spark/'

# And Python path
import sys
sys.path.insert(0, '/root/spark/python')

# Detect the PySpark URL
CLUSTER_URL = open('/root/spark-ec2/cluster-url').read().strip()

from pyspark import SparkContext
app_name = CLUSTER_URL.split("//")[1].split(".")[0]
sc = SparkContext(CLUSTER_URL, app_name)
