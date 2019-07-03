#!/bin/bash

# Exit if already executed
if [ -f ~/.terraform_provisioned ]; then exit; fi

# Prepare and mount /srv
/usr/local/bin/preparesrv.sh

# Folders to hold data and logs
mkdir -p /srv/elasticsearch/data
mkdir -p /srv/elasticsearch/logs

# Install java
wget -q --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/otn-pub/java/jdk/8u202-b08/1961070e4c9b4e26a04e7f5a083f551e/jre-8u202-linux-x64.rpm
yum -q localinstall -y jre-8u202-linux-x64.rpm
rm -f jre-8u202-linux-x64.rpm

# Install Elasticsearch
ES_PACKAGE=elasticsearch
if [ "${elk_version}" != "" -a "${elk_version}" != "latest" ]; then
    ES_PACKAGE=elasticsearch-${elk_version}
fi

yum -q -y install $ES_PACKAGE

chown -R elasticsearch.elasticsearch /srv/elasticsearch

rm -rf /var/log/elasticsearch
ln -s /srv/elasticsearch/logs /var/log/elasticsearch

# Install official plugins
/usr/share/elasticsearch/bin/elasticsearch-plugin install -b discovery-ec2
/usr/share/elasticsearch/bin/elasticsearch-plugin install -b repository-s3

# Set Heap size to 50% of phisical memory up to 24GB
MEMORY=$(free -m | grep Mem | awk '{print $2}')
HEAP_SIZE=$[MEMORY / 2]
if [ $HEAP_SIZE -gt 24576 ]; then
    HEAP_SIZE=24576
fi
ES_JAVA_OPTS="-Xms$${HEAP_SIZE}m -Xmx$${HEAP_SIZE}m"

sed -i -r "s/^#?ES_JAVA_OPTS=.*/ES_JAVA_OPTS=\"$${ES_JAVA_OPTS}\"/" /etc/sysconfig/elasticsearch
sed -i -r 's/^#?MAX_LOCKED_MEMORY=.*/MAX_LOCKED_MEMORY=unlimited/' /etc/sysconfig/elasticsearch
sed -i -r "s/^-Xms1g.*/-Xms$${HEAP_SIZE}m/" /etc/elasticsearch/jvm.options
sed -i -r "s/^-Xmx1g.*/-Xmx$${HEAP_SIZE}m/" /etc/elasticsearch/jvm.options

# Create Elasticsearch configuration
cat > /etc/elasticsearch/elasticsearch.yml << EOF
cluster.name: ${cluster_name}

discovery.zen.hosts_provider: ec2
discovery.ec2.endpoint: ${endpoint}
discovery.ec2.groups: ${groups}

network.host: _ec2:privateIpv4_

cloud.node.auto_attributes: true

# Spread shard replicas in different AZs
cluster.routing.allocation.awareness.attributes: aws_availability_zone

path.data: /srv/elasticsearch/data
path.logs: /srv/elasticsearch/logs
EOF

chown elasticsearch.elasticsearch /etc/elasticsearch/elasticsearch.yml

# Enable and start
systemctl enable elasticsearch
systemctl start elasticsearch

echo "Node Provisioned" > ~/.terraform_provisioned
chattr +i ~/.terraform_provisioned
