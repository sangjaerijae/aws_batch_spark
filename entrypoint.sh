#!/bin/bash
#/opt/spark/spark-2.4.5-bin-hadoop2.7/bin/spark-class org.apache.spark.deploy.master.Master --ip `hostname` --port 7077 --webui-port 8080
spark-submit --master local[*] --class org.apache.spark.examples.SparkPi /opt/spark/spark-2.4.5-bin-hadoop2.7/examples/jars/spark-examples_2.11-2.4.5.jar 100

