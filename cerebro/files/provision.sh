#!/bin/bash

# Exit if already executed
if [ -f ~/.terraform_provisioned ]; then exit; fi

# Install java
wget -q --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/otn-pub/java/jdk/8u202-b08/1961070e4c9b4e26a04e7f5a083f551e/jre-8u202-linux-x64.rpm
yum -q localinstall -y jre-8u202-linux-x64.rpm
rm -f jre-8u202-linux-x64.rpm

# Download Cerebro
wget https://github.com/lmenezes/cerebro/releases/download/v${cerebro_version}/cerebro-${cerebro_version}.tgz
tar xvf cerebro-${cerebro_version}.tgz
mv cerebro-${cerebro_version} /opt/cerebro
rm -f cerebro-${cerebro_version}.tgz

Install Nginx
yum -q -y install nginx

rm -f /etc/nginx/conf.d/default.conf

CEREBRO_SECRET=$(dd if=/dev/urandom count=512 | sha256sum | awk '{print $1}')
cat > /opt/cerebro/conf/application.conf << EOF
secret = "$CEREBRO_SECRET"
basePath = "/"
pidfile.path = "/var/run/cerebro.pid"
rest.history.size = 50
data.path = "/var/lib/cerebro.db"
es = {
  gzip = true
}
auth = {
}
hosts = [
  {
    host = "${elasticsearch_url}"
    name = "${es_cluster_name}"
  }
]
EOF

# Set Heap size to 50% of phisical memory up to 24GB
MEMORY=$(free -m | grep Mem | awk '{print $2}')
HEAP_SIZE=$[MEMORY / 2]
if [ $HEAP_SIZE -gt 24576 ]; then
    HEAP_SIZE=24576
fi
JAVA_OPTS="-J-Xms$${HEAP_SIZE}m -J-Xmx$${HEAP_SIZE}m"

/opt/cerebro/bin/cerebro $JAVA_OPTS -Dhttp.port=9000 -Dhttp.address=127.0.0.1 &

echo "/opt/cerebro/bin/cerebro $JAVA_OPTS -Dhttp.port=9000 -Dhttp.address=127.0.0.1 &" >> /etc/rc.local
chmod +x /etc/rc.local

# Enable and start
systemctl enable nginx
systemctl start nginx

echo "Node Provisioned" > ~/.terraform_provisioned
chattr +i ~/.terraform_provisioned
