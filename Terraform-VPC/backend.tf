terraform {
  backend "s3"{
      bucket = "learning-docker01"
      key = "terraform.tfstate"
      region = "us-east-1"
  }
}