terraform {
  backend "s3" {
    bucket         = "tfstate-ojm-apne2"
    key            = "terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "tfstate-lock-ojm"
    encrypt        = true
  }
}
