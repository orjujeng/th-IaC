output "ecr_repository_url" {
  value = aws_ecrpublic_repository.applciation_ecr_pubilc_repo.repository_uri
}

output "ecs_service_name" {
    value = length(aws_ecs_service.application_specific_service)== 0 ?"": aws_ecs_service.application_specific_service[0].name
}

output "ecs_cluster_name" {
   value = length(aws_ecs_cluster.application_ecs_cluster)== 0?"":aws_ecs_cluster.application_ecs_cluster[0].name
}
  