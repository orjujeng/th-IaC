resource "aws_ecrpublic_repository" "applciation_ecr_pubilc_repo" {
  provider        = aws.east
  repository_name = "${var.perfix}-api"

  catalog_data {
    architectures     = ["ARM"]
    operating_systems = ["Linux"]
  }
  tags = {
    Name = "${var.perfix}_ecr_pubilc_repo"
  }
}