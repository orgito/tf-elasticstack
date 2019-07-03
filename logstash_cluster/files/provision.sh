#!/bin/bash

# Exit if already executed
if [ -f ~/.terraform_provisioned ]; then exit; fi

# Install java
wget -q --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/otn-pub/java/jdk/8u202-b08/1961070e4c9b4e26a04e7f5a083f551e/jre-8u202-linux-x64.rpm
yum -q localinstall -y jre-8u202-linux-x64.rpm
rm -f jre-8u202-linux-x64.rpm

# Install Logstash
ES_PACKAGE=logstash
if [ "${elk_version}" != "" -a "${elk_version}" != "latest" ]; then
    ES_PACKAGE=logstash-${elk_version}
fi

yum -q -y install $ES_PACKAGE

# Set Heap size to 50% of phisical memory up to 24GB
MEMORY=$(free -m | grep Mem | awk '{print $2}')
HEAP_SIZE=$[MEMORY / 2]
if [ $HEAP_SIZE -gt 24576 ]; then
    HEAP_SIZE=24576
fi
LS_JAVA_OPTS="-Xms$${HEAP_SIZE}m -Xmx$${HEAP_SIZE}m"

sed -i -r "s/-Xms.+/-Xms$${HEAP_SIZE}m/" /etc/logstash/jvm.options
sed -i -r "s/-Xmx.+/-Xmx$${HEAP_SIZE}m/" /etc/logstash/jvm.options

# Add a simple pipepline
cat > /etc/logstash/conf.d/pipeline.conf << EOF
${pipeline}
EOF
chown logstash.logstash /etc/logstash/conf.d/pipeline.conf

# Install system scripts (Necessary for micro instances)
/usr/share/logstash/bin/system-install

# Enable and start
systemctl enable logstash
systemctl start logstash

echo "Node Provisioned" > ~/.terraform_provisioned
chattr +i ~/.terraform_provisioned
