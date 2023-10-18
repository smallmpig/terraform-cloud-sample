module "gcr-module-demo1" {
  source   = "./modules/cloudRun"
  gcr_name = "${var.gcr_name}-1"
  location = var.GCP_REGION
  image_name= var.image_name
  container_name= var.container_name
}




# resource "google_sql_database_instance" "cloud_sql_postgre" {
#   name = "bi-saas-sql-db-server"
#   database_version = var.database_version
#   region = var.sql_region
#   root_password = random_password.root.result
#   project = var.project_id
#   settings {
#     tier = var.database_tier
#     disk_autoresize = false
#     disk_size = 10
#      ip_configuration {
#       # Add optional authorized networks
#       # Update to match the customer's networks
#       authorized_networks {
#         name  = "bi"
#         value = "61.219.174.44"
#       }
#       # Enable public IP
#       ipv4_enabled = true
#     }
#   }
#   #這邊要能動態調整，作為下架的流程
#   deletion_protection = false
  
# }

# resource "google_sql_database" "cloud_database" {
#     name = var.table_name
#     instance = google_sql_database_instance.cloud_sql_postgre.name
#     project = var.project_id
  
# }

# resource "google_sql_user" "sql" {
#   name     = var.user_name
#   instance = google_sql_database_instance.cloud_sql_postgre.name
#   password = random_password.user.result
# }

# resource "google_secret_manager_secret" "connection_name" {
#   secret_id = "connection-name"
#   replication {
#     auto { }
#   }
# }

# resource "google_secret_manager_secret_version" "connection_name" {
#   secret      = google_secret_manager_secret.connection_name.id
#   secret_data = google_sql_database_instance.cloud_sql_postgre.connection_name
# }


# resource "google_cloud_run_v2_service" "module-gcr" {
#     name = var.container_name
#     location = "aisa-east1"
#     template {
        
#         containers {
#             # 下載檔案 docker hub - https://hub.docker.com/_/nginx
#             image = var.image_name
#             ports {
#             name           = "http1"
#             container_port = 8080
#             }
#             env {
#              name = "SPRING_PROFILES_ACTIVE"
#              value = "sit"
#             }
            
#         }
#         vpc_access {
#           connector = google_vpc_access_connector.connector.id
#           egress = "ALL_TRAFFIC"
#         } 
#     }
#     traffic {
#         type = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
#         percent         = 100
#     }
# }


# # import a VPC network if enable_vpc is set to 1 (true)
# resource "google_compute_network" "vpc_network" {
#   name                    = "raveb-vpc"
  
# }

