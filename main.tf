module "gcr-module-demo1" {
  source   = "./modules/cloudRun"
  gcr_name = "${var.gcr_name}-1"
  location = var.GCP_REGION
  image_name= var.image_name
  container_name= var.container_name
}