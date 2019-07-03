data "template_file" "provision" {
  template = "${file("${path.module}/files/provision.sh")}"

  vars {
    elk_version  = "${var.elk_version}"
    elasticsearch_url  = "${var.elasticsearch_url}"
  }
}

data "template_cloudinit_config" "provision" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"

    content = <<-CONFIG
      # Add the Elastic repo
      yum_repos:
        elastic:
          name: Elastic repository for 6.x packages
          baseurl: https://artifacts.elastic.co/packages/6.x/yum
          enabled: true
          gpgcheck: true
          gpgkey: https://artifacts.elastic.co/GPG-KEY-elasticsearch
        nginx:
          name: nginx repo
          baseurl: http://nginx.org/packages/mainline/centos/7/$basearch/
          gpgcheck: false
          enabled: true
      write_files:
      - path: /etc/nginx/conf.d/kibana.conf
        content: |
          server {
              listen 80;
              server_name _;

              location / {
                  proxy_pass http://127.0.0.1:5601;
                  proxy_http_version 1.1;
                  proxy_set_header Upgrade $http_upgrade;
                  proxy_set_header Connection 'upgrade';
                  proxy_set_header Host $host;
                  proxy_cache_bypass $http_upgrade;
              }
          }
        permissions: '0644'
      - path: /etc/nginx/conf.d/00_security.conf
        content: |
          add_header X-Frame-Options "SAMEORIGIN";
          add_header X-XSS-Protection "1; mode=block";
          add_header X-Content-Type-Options nosniff;
          server_tokens off;
        permissions: '0644'
      CONFIG
  }

  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.provision.rendered}"
  }
}
