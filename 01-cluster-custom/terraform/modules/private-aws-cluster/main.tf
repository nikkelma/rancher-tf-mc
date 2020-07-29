
resource "rancher2_cluster" "target" {
  name = var.cluster_name
  rke_config {
    kubernetes_version = "v1.17.9-rancher1-1"
    ingress {
      node_selector = {
        app = "ingress"
      }
    }
  }
  cluster_monitoring_input {
    version = "0.1.1"
  }
}

resource "rancher2_cluster_sync" "target" {
  cluster_id      = rancher2_cluster.target.id
  wait_monitoring = true
}

// TODO: remove hard-coded CIDR
resource "aws_vpc" "target" {
  cidr_block = "10.25.128.0/24"

  tags = {
    Name = "${var.cluster_name}-vpc"
  }
}

// TODO: remove hard-coded CIDR
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.target.id
  cidr_block = "10.25.128.0/26"

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.cluster_name}-public-subnet"
  }
}

// TODO: remove hard-coded CIDR
resource "aws_subnet" "egress_only" {
  vpc_id     = aws_vpc.target.id
  cidr_block = "10.25.128.64/26"

  map_public_ip_on_launch = false

  tags = {
    Name = "${var.cluster_name}-eo-subnet"
  }
}

resource "aws_internet_gateway" "target" {
  vpc_id = aws_vpc.target.id

  tags = {
    Name = "${var.cluster_name}-igw"
  }
}

resource "aws_eip" "ngw" {
  depends_on = [aws_internet_gateway.target]

  vpc = true
}

resource "aws_nat_gateway" "target" {
  depends_on = [aws_internet_gateway.target]

  allocation_id = aws_eip.ngw.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "${var.cluster_name}-ngw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.target.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.target.id
  }

  tags = {
    Name = "${var.cluster_name}-public-rt"
  }
}

resource "aws_route_table" "egress_only" {
  vpc_id = aws_vpc.target.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.target.id
  }

  tags = {
    Name = "${var.cluster_name}-eo-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "egress_only" {
  subnet_id      = aws_subnet.egress_only.id
  route_table_id = aws_route_table.egress_only.id
}

resource "aws_key_pair" "target" {
  key_name_prefix = "${var.cluster_name}-key-"
  public_key      = var.ssh_public_key
}

resource "aws_security_group" "public" {
  name        = "${var.cluster_name}-sg-public"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.target.id

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Creator = var.creator
  }
}

resource "aws_security_group" "internal" {
  name        = "${var.cluster_name}-sg-internal"
  description = "Allow ingress only from instances in same SG, allow all egress"
  vpc_id      = aws_vpc.target.id

  ingress {
    self      = true
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Creator = var.creator
  }
}

// TODO: remove hard-coded AMIs that restrict to us-east-2
locals {
  ami_ubuntu_18_04 = "ami-0f4ee0f926e9f568d"
  ami_ubuntu_20_04 = "ami-045a25a3e38518838"
}

resource "aws_instance" "bastion" {
  ami           = local.ami_ubuntu_20_04
  instance_type = "t3a.small"

  key_name = aws_key_pair.target.key_name

  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [
    aws_security_group.internal.id,
    aws_security_group.public.id,
  ]

  tags = {
    Name    = "${var.cluster_name}-bastion"
    Creator = var.creator
  }
}

resource "aws_eip" "bastion" {
  depends_on = [aws_internet_gateway.target]

  vpc = true
}

resource "aws_eip_association" "bastion" {
  instance_id   = aws_instance.bastion.id
  allocation_id = aws_eip.bastion.id
}

locals {
  master_config = {
    v01 = {
      ami            = local.ami_ubuntu_20_04
      instance_type  = "t3a.large"
      docker_version = "19.03.12"
    }
  }
  master_instances = {
    v01_01 = local.master_config["v01"]
    v01_02 = local.master_config["v01"]
    v01_03 = local.master_config["v01"]
  }
}

resource "aws_instance" "master" {
  for_each = local.master_instances

  depends_on = [
    aws_instance.bastion,
    aws_route_table_association.egress_only,
  ]

  ami           = each.value["ami"]
  instance_type = each.value["instance_type"]

  key_name = aws_key_pair.target.key_name

  user_data = templatefile(
    join("/", [path.module, "files/userdata_ec2_internal.template"]),
    {
      docker_version   = each.value["docker_version"]
      username         = "ubuntu"
      register_command = rancher2_cluster.target.cluster_registration_token.0.node_command
      role_flags       = ["--etcd", "--controlplane"]
    }
  )

  subnet_id              = aws_subnet.egress_only.id
  vpc_security_group_ids = [aws_security_group.internal.id]

  root_block_device {
    volume_size = 50
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for cloud-init to complete...'",
      "cloud-init status --wait > /dev/null",
      "echo 'Completed cloud-init!'",
    ]

    connection {
      type                = "ssh"
      host                = self.private_ip
      user                = "ubuntu"
      private_key         = var.ssh_private_key
      bastion_host        = aws_eip.bastion.public_ip
      bastion_private_key = var.ssh_private_key
    }
  }

  tags = {
    Name    = "${var.cluster_name}-master-${each.key}"
    Creator = var.creator
  }
}

locals {
  ingress_config = {
    v01 = {
      ami            = local.ami_ubuntu_20_04
      instance_type  = "t3a.medium"
      docker_version = "19.03.12"
    }
  }
  ingress_instances = {
    v01_01 = local.ingress_config.v01
    v01_02 = local.ingress_config.v01
  }
}

resource "aws_instance" "ingress" {
  for_each = local.ingress_instances

  depends_on = [aws_instance.bastion]

  ami           = each.value.ami
  instance_type = each.value.instance_type

  key_name = aws_key_pair.target.key_name

  user_data = templatefile(
    join("/", [path.module, "files/userdata_ec2_ingress.template"]),
    {
      docker_version   = each.value.docker_version
      username         = "ubuntu"
      register_command = rancher2_cluster.target.cluster_registration_token.0.node_command
    }
  )

  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [
    aws_security_group.internal.id,
    aws_security_group.public.id,
  ]

  root_block_device {
    volume_size = 20
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for cloud-init to complete...'",
      "cloud-init status --wait > /dev/null",
      "echo 'Completed cloud-init!'",
    ]

    connection {
      type                = "ssh"
      host                = self.private_ip
      user                = "ubuntu"
      private_key         = var.ssh_private_key
      bastion_host        = aws_eip.bastion.public_ip
      bastion_private_key = var.ssh_private_key
    }
  }

  tags = {
    Name    = "${var.cluster_name}-ingress-${each.key}"
    Creator = var.creator
  }
}

locals {
  worker_config = {
    // Ubuntu 18.04, older version of docker
    v01 = {
      ami            = local.ami_ubuntu_18_04
      instance_type  = "t3a.xlarge"
      docker_version = "19.03.11"
    }
    // Ubuntu 20.04, newest version of docker
    v02 = {
      ami            = local.ami_ubuntu_20_04
      instance_type  = "t3a.xlarge"
      docker_version = "19.03.12"
    }
  }
  worker_instances = {
    v01_01 = local.worker_config["v01"]
    v01_02 = local.worker_config["v01"]
    v02_01 = local.worker_config["v02"]
    v02_02 = local.worker_config["v02"]
  }
}

resource "aws_instance" "worker" {
  for_each = local.worker_instances

  depends_on = [
    aws_instance.bastion,
    aws_route_table_association.egress_only,
  ]

  ami           = each.value["ami"]
  instance_type = each.value["instance_type"]

  key_name = aws_key_pair.target.key_name

  user_data = templatefile(
    join("/", [path.module, "files/userdata_ec2_internal.template"]),
    {
      docker_version   = each.value["docker_version"]
      username         = "ubuntu"
      register_command = rancher2_cluster.target.cluster_registration_token.0.node_command
      role_flags       = ["--worker"]
    }
  )

  subnet_id              = aws_subnet.egress_only.id
  vpc_security_group_ids = [aws_security_group.internal.id]

  root_block_device {
    volume_size = 50
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for cloud-init to complete...'",
      "cloud-init status --wait > /dev/null",
      "echo 'Completed cloud-init!'",
    ]

    connection {
      type                = "ssh"
      host                = self.private_ip
      user                = "ubuntu"
      private_key         = var.ssh_private_key
      bastion_host        = aws_eip.bastion.public_ip
      bastion_private_key = var.ssh_private_key
    }
  }

  tags = {
    Name    = "${var.cluster_name}-worker-${each.key}"
    Creator = var.creator
  }
}
