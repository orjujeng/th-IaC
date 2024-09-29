output inside_subnet_id {
    value = [for subnet in aws_subnet.application_inside_net : subnet.id]
}

output private_subnet_id {
     value = [for subnet in aws_subnet.application_private_net : subnet.id]
}
output vpc_id {
    value = aws_vpc.application_vpc.id
}