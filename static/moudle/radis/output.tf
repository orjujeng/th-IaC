output "redis_address" {
  value = var.cluster_mode ? aws_elasticache_replication_group.application_elasticache_cluster[0].primary_endpoint_address : aws_elasticache_cluster.application_elasticache_replica[0].cache_nodes[0].address
}

