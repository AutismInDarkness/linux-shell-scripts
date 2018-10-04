#! /bin/bash
apt-get update -y
apt-get install wget git lrzsz net-tools -y
echo "install java"
sleep 3
tar xf java.tar.gz -C /opt
mv /opt/jdk1.8*  /opt/jdk
echo "export JAVA_HOME=/opt/jdk" >> /etc/profile
echo "export JRE_HOME=\$JAVA_HOME/jre" >> /etc/profile
echo "export CLASSPATH=.:\$JAVA_HOME/lib:\$JRE_HOME/lib" >> /etc/profile
echo "export PATH=\$JAVA_HOME/bin:\$JRE_HOME:bin:\$PATH" >> /etc/profile
source /etc/profile

echo "install zookeeper"
sleep 3
wget http://mirror.bit.edu.cn/apache/zookeeper/zookeeper-3.4.13/zookeeper-3.4.13.tar.gz
sleep 5
tar xf zookeeper-3.4.13.tar.gz -C /opt/
mv /opt/zookeeper-3.4.13/conf/zoo_sample.cfg /opt/zookeeper-3.4.13/conf/zoo.cfg
sed -i "12c dataDir=/var/zookeeper" /opt/zookeeper-3.4.13/conf/zoo.cfg
sed -i "12a dataLogDir=/var/logs/zookeeper" /opt/zookeeper-3.4.13/conf/zoo.cfg
mkdir /var/log/zookeeper
mkdir /var/zookeeper
cd /opt/zookeeper-3.4.13 && bash ./bin/zkServer.sh start


echo "download solr 7.4"
sleep 3
wget http://mirrors.hust.edu.cn/apache/lucene/solr/7.5.0/solr-7.5.0.tgz
sleep 5
tar xzf solr-7.5.0.tgz solr-7.5.0/bin/install_solr_service.sh --strip-components=2
bash ./install_solr_service.sh solr-7.5.0.tgz -i /opt -d /var/solr -u solr -s solr -p 8983 -n
sed -i "22a SOLR_JAVA_HOME=\"/opt/jdk\"" /etc/default/solr.in.sh
sed -i "40a SOLR_JAVA_MEM=\"-Xms1g -Xmx1g\"" /etc/default/solr.in.sh
sed -i "56a ZK_HOST=\"localhost:2181\""  /etc/default/solr.in.sh
cp -r /opt/solr/example/example-DIH/solr/db/conf/* /opt/solr/server/solr/configsets/_default/conf/
service solr start

echo "service init"
sed -i "12a cd /opt/zookeeper-3.4.13 && bash ./bin/zkServer.sh start" /etc/rc.local
sed -i "13a service solr start" /etc/rc.local
#./bin/solr zk upconfig -n _default -d /opt/solr/server/solr/configsets/_default