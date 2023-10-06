variable "GCP_PROJECT" {
  description = "GCP Project ID"
  type        = string
  default     = ""
}

variable "gcr_name" {
  type    = string
  default = "cathay-start-gcr-module"
}

variable "GCP_REGION" {
  type    = string
  default = "asia-east1"
}

variable "container_name" {
  type    = string
  default = "cloud-run-tf-spring-lab-7"
}

variable "image_name" {
  type    = string
  default = "asia-east1-docker.pkg.dev/peppy-ward-398202/hello-repo/demo-app:latest"
}