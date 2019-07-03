#!/bin/bash

# Exit if already executed
if [ -f ~/.terraform_provisioned ]; then exit; fi

# Install Kibana
ES_PACKAGE=kibana
if [ "${elk_version}" != "" -a "${elk_version}" != "latest" ]; then
    ES_PACKAGE=kibana-${elk_version}
fi

yum -q -y install $ES_PACKAGE
yum -q -y install nginx

rm -f /etc/nginx/conf.d/default.conf

sed -i -r 's|^#?elasticsearch.url:.*|elasticsearch.url: "${elasticsearch_url}"|' /etc/kibana/kibana.yml

# Enable and start
systemctl enable kibana
systemctl start kibana
systemctl enable nginx
systemctl start nginx

echo "Node Provisioned" > ~/.terraform_provisioned
chattr +i ~/.terraform_provisioned
