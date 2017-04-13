#!/bin/bash
  wget -P /tmp http://downloads.mesosphere.com/dcos/stable/dcos_generate_config.sh && 
  docker run -d -p 2181:2181 -p 2888:2888 -p 3888:3888 --name=dcos_int_zk jplock/zookeeper && 
  sudo bash /tmp/dcos_generate_config.sh --web
