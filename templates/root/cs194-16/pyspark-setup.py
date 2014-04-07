# Configure the necessary Spark environment
import os
os.environ['SPARK_HOME'] = '/root/spark/'

# And Python path
import sys
sys.path.insert(0, '/root/spark/python')

# Detect the PySpark URL
CLUSTER_URL = open('/root/spark-ec2/cluster-url').read().strip()

from pyspark import SparkContext
import commands
app_name = commands.getoutput("wget -q -O - http://169.254.169.254/latest/meta-data/public-hostname")
sc = SparkContext(CLUSTER_URL, app_name)
