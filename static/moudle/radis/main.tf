#redis 和rds几乎相同，
#另外还有两个模式，集群模式和正常模式，集群模式可以分为多了切片，正常模式可能只有16个数据库，但是无论如何，都有主从模式。
#分为一主多从，和多主多从，主负责写，从负责读。

#子网
resource "aws_elasticache_subnet_group" "application_redis_subnet_group" {
  name        = "${var.perfix}-redis-subnet-group"
  description = "This subnet group is only cover the private subnet zone"
  subnet_ids  = var.redis_subnet_ids
}

#参数组
resource "aws_elasticache_parameter_group" "application_redis_parameter_group" {
  name   = "${var.perfix}-redis7-parameter-group"
  family = "redis7"
  parameter {
  name  = "cluster-enabled"
  value = var.cluster_mode ? "yes" : "no"
 }
  parameter {
    name  = "notify-keyspace-events"
    value = "Egx"
  }
  
}
#redis sg
resource "aws_security_group" "application_redis_sg" {
  name        = "${var.perfix}_redis_sg"
  description = "Allow container to redis"
  vpc_id      = var.vpc_id

  ingress {
    description     = "container to redis"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = var.container_sg_id
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.perfix}_redis_sg"
  }
}
#单节点模式
resource "aws_elasticache_cluster" "application_elasticache_replica" {
 count = var.cluster_mode ? 0 : 1
  cluster_id           = "${var.perfix}-elasticache"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = aws_elasticache_parameter_group.application_redis_parameter_group.name
  engine_version       = "7.1"
  port                 = 6379
  security_group_ids   = [aws_security_group.application_redis_sg.id]
  subnet_group_name    = aws_elasticache_subnet_group.application_redis_subnet_group.name
  tags = {
    name = "${var.perfix}_elasticache_replica"
  }
}

#集群模式
resource "aws_elasticache_replication_group" "application_elasticache_cluster" {
  count = var.cluster_mode ? 1 : 0
  automatic_failover_enabled = true
  replication_group_id       = "${var.perfix}-elasticache-cluster"
  description                = "${var.perfix}_elasticache_cluster"
  node_type                  = "cache.t3.micro"
  parameter_group_name       = aws_elasticache_parameter_group.application_redis_parameter_group.name
  engine_version             = "7.1"
  engine                     = "redis"
  port                       = 6379
  #num_cache_clusters         = 2 猜测为集群还是非集群模式的分界，非集群模式设置这个？
  num_node_groups            = 2 #conflict with num_cache_clusters 几个节点  num_cache_nodes    = 1  # 非集群模式，每个实例一个节点
  replicas_per_node_group    = 2 #number of node in shards 每个节点的切几片
  multi_az_enabled   = true #开启后每一个az会都会有 node数量 * replicas数量的节点
  subnet_group_name  = aws_elasticache_subnet_group.application_redis_subnet_group.name
  security_group_ids = [aws_security_group.application_redis_sg.id]
  tags = {
    name = "${var.perfix}_elasticache_cluster"
  }
}