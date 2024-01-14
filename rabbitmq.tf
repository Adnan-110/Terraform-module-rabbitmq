# # Creates EC2 Spot Instance

# resource "aws_spot_instance_request" "rabbitmq" {
#   ami                     = data.aws_ami.image.id
#   subnet_id               = data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNET_IDS[0]
#   instance_type           = var.RABBITMQ_NODE_TYPE
#   vpc_security_group_ids  = [aws_security_group.allows_rabbitmq.id]
#   wait_for_fulfillment    = true
  
#   tags = {
#     Name = "roboshop-rabbitmq-${var.ENV}"
#   }
# }

# Creates EC2 Instance
resource "aws_instance" "rabbitmq" {
  ami                     = data.aws_ami.image.id
  instance_type           = var.RABBITMQ_NODE_TYPE
  subnet_id               = data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNET_IDS[0]
  vpc_security_group_ids  = [aws_security_group.allows_rabbitmq.id]
  
  tags = {
    Name = "roboshop-rabbitmq-${var.ENV}"
  }
}

resource "null_resource" "app_install" {
  provisioner "remote-exec" {
    
    # Connection block establish connection to server
    connection {
      type      = "ssh"
      user      = local.SSH_USERNAME
      password  = local.SSH_PASSWORD
      host      = aws_instance.rabbitmq.private_ip    # aws_instance.sample.private_ip : Use this only if your provisioner is outside the resource.
    }

    inline = [ 
      "ansible-pull -U https://github.com/Adnan-110/ansible.git -e ENVIRONMENT=${var.ENV} -e COMPONENT=rabbitmq roboshop-pull.yaml"
     ]
  }  
}

# # Provisions Redis/Elastic-Cache Cluster

# resource "aws_elasticache_cluster" "example" {
#   cluster_id              = "roboshop-${var.ENV}-redis"
#   engine                  = var.REDIS_ENGINE
#   node_type               = var.REDIS_NODE_TYPE
#   num_cache_nodes         = var.REDIS_NODE_COUNT
#   parameter_group_name    = aws_elasticache_parameter_group.redis.name
#   engine_version          = var.REDIS_ENGINE_VERSION
#   port                    = var.REDIS_PORT
#   subnet_group_name       = aws_elasticache_subnet_group.redis.name
#   security_group_ids      = [aws_security_group.allows_redis.id]
# }

# # Creates a subnet-groups
# resource "aws_elasticache_subnet_group" "redis" {
#   name       = "roboshop-${var.ENV}-redis-subnet-group"
#   subnet_ids = data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNET_IDS

#   tags = {
#     Name = "roboshop-${var.ENV}-redis-subnet-group"
#   }
# }

# # Provisions Redis/Elastic-Cache Parameter Group
# resource "aws_elasticache_parameter_group" "redis" {
#   name   = "roboshop-${var.ENV}-redis-pg"
#   family = var.REDIS_ENGINE_FAMILY
# }



  

