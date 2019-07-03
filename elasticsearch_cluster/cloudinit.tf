data "template_file" "provision" {
  template = "${file("${path.module}/files/provision.sh")}"

  vars {
    cluster_name = "${var.name}"
    region       = "${data.aws_region.current.name}"
    endpoint     = "${data.aws_region.current.endpoint}"
    groups       = "${aws_security_group.elasticsearch.name}"
    elk_version  = "${var.elk_version}"
  }
}

data "template_cloudinit_config" "provision" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"

    content = <<-CONFIG
      # Add the elaticseach repo
      yum_repos:
        elastic:
          name: Elastics repository for 6.x packages
          baseurl: https://artifacts.elastic.co/packages/6.x/yum
          enabled: true
          gpgcheck: true
          gpgkey: https://artifacts.elastic.co/GPG-KEY-elasticsearch

      write_files:
      # Add the resizer script
      - path: /usr/local/bin/resizesrv.sh
        content: |
          #!/bin/bash
          # Do not try to resize twice
          if [ -e /var/lock/resizingsrv ]; then exit; fi

          trap "rm -f /var/lock/resizingsrv; exit" INT TERM EXIT
          touch /var/lock/resizingsrv
          /sbin/resize2fs /dev/xvdg
          rm -f /var/lock/resizingsrv
        permissions: '0755'

      # Add the prepare script
      - path: /usr/local/bin/preparesrv.sh
        content: |
          #!/bin/bash
          # Bail out if already prepared
          FSTYPE="$(lsblk -n -o FSTYPE /dev/xvdg)"
          if [ "$FSTYPE" == "ext4" ]; then exit; fi

          # Wait for the volume to be attached
          echo "Wait for the volume to be attached" >> /var/log/provision.log
          date +%T.%N >> /var/log/provision.log
          while [ ! -b /dev/xvdg ]; do
              echo "Sleeping 5" >> /var/log/provision.log
              sleep 5
          done
          date +%T.%N >> /var/log/provision.log
          mkfs -t ext4 /dev/xvdg
          tune2fs -i 0 -c 0 /dev/xvdg
          echo /dev/xvdg /srv ext4 defaults,noatime,nodiratime,nofail 0 2 >> /etc/fstab
          mount /srv

          # And now we add to the crontab
          (crontab -l; echo "* * * * * /usr/local/bin/resizesrv.sh >/dev/null 2>&1") | crontab -
        permissions: '0755'
      CONFIG
  }

  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.provision.rendered}"
  }
}
