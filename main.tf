module "gcr-module-demo1" {
  source   = "./modules/cloudRun"
  gcr_name = "${var.gcr_name}-1"
  location = var.GCP_REGION
  image_name= var.image_name
  container_name= var.container_name
}

# import {
#   to = google_sql_database_instance.sql_instance
#   id = "raven-test"
# }
# resource "google_sql_database_instance" "sql_instance" {
#   name             = "raven-test"
#   database_version = "POSTGRES_15"
#   region           = "asia-east1"

#   settings {
#     # Second-generation instance tiers are based on the machine
#     # type. See argument reference below.
#     tier = "db-f1-micro"
#   }
# }

import {
  to =google_vpc_access_connector.my-vpc
  id = "raveb-vpc"
}

# import a VPC network if enable_vpc is set to 1 (true)
resource "google_compute_network" "vpc_network" {
  name                    = "raveb-vpc"
  
}
