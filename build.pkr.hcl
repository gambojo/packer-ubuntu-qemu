### Source
source "qemu" "ubuntu" {
  iso_url            = var.iso_url
  iso_checksum       = var.iso_checksum
  output_directory   = var.output_directory
  vm_name            = local.vm_name
  format             = var.format
  cpus               = var.cpus
  memory             = var.memory
  disk_size          = var.disk_size
  http_directory     = var.http_directory
  http_port_min      = var.http_port_min
  http_port_max      = var.http_port_max
  host_port_min      = var.host_port_min
  host_port_max      = var.host_port_max
  ssh_password       = var.ssh_password
  ssh_username       = var.ssh_username
  ssh_timeout        = var.ssh_timeout
  ssh_wait_timeout   = var.ssh_timeout
  disk_compression   = var.disk_compression
  disk_discard       = var.disk_discard
  skip_compaction    = var.skip_compaction
  disk_detect_zeroes = var.disk_detect_zeroes
  headless           = var.headless
  boot_wait          = var.boot_wait
  accelerator        = var.accelerator
  shutdown_command   = local.shutdown_command
  boot_command = [
    "c",
    "<wait>",
    "linux /casper/vmlinuz --- autoinstall ds='nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/' ",
    "<enter><wait>",
    "initrd /casper/initrd<enter><wait>",
    "boot<enter>"
  ]
}

### Build
build {
  sources = ["source.qemu.ubuntu"]

  ### Wait for boot finished
  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done"
    ]
  }

  ### Shell provisioner
  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    scripts = [
      "${var.provisions_dir}/shell/script.sh"
    ]
  }

  ### Ansible provisioner
  provisioner "ansible" {
    playbook_file = "${var.provisions_dir}/ansible/playbook.yml"
    user          = var.ssh_username
    use_proxy     = false
    extra_arguments = [
      "--extra-vars", "ansible_sudo_pass=${var.ssh_password}",
      "--extra-vars", "ansible_ssh_pass=${var.ssh_password}"
    ]
  }

  ### Post-processors
  post-processors {
    post-processor "checksum" {
      checksum_types      = ["${var.checksum_type}"]
      output              = "${var.output_directory}/${local.vm_name}.{{.ChecksumType}}"
      keep_input_artifact = true
    }

    post-processor "manifest" {
      keep_input_artifact = true
      output              = "${var.output_directory}/packer_manifest.json"
    }
  }
}
