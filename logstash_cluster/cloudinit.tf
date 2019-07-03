data "template_file" "provision" {
  template = "${file("${path.module}/files/provision.sh")}"

  vars {
    elk_version = "${var.elk_version}"
    pipeline    = "${var.pipeline}"
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
      CONFIG
  }

  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.provision.rendered}"
  }
}
