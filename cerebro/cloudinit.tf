data "template_file" "provision" {
  template = "${file("${path.module}/files/provision.sh")}"

  vars {
    cerebro_version   = "${var.cerebro_version}"
    elasticsearch_url = "${var.elasticsearch_url}"
    es_cluster_name   = "${var.es_cluster_name}"
  }
}

data "template_cloudinit_config" "provision" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"

    content = <<-CONFIG
      yum_repos:
        nginx:
          name: nginx repo
          baseurl: http://nginx.org/packages/mainline/centos/7/$basearch/
          gpgcheck: false
          enabled: true
      write_files:
      - path: /etc/nginx/conf.d/cerebro.conf
        content: |
          server {
              listen 80;
              server_name _;

              location / {
                  proxy_pass http://127.0.0.1:9000;
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
