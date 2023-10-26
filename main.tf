# module "gcr-module-demo1" {
#   source   = "./modules/cloudRun"
#   gcr_name = "${var.gcr_name}-1"
#   location = var.GCP_REGION
#   image_name= var.image_name
#   container_name= var.container_name
# }

resource "google_compute_network" "main" {
  provider                = google-beta
  name                    = "raven-private-network"
  auto_create_subnetworks = false
  project                 = var.project_id
}


resource "google_compute_global_address" "main" {  
  name          = "raven-vpc-address"
  provider      = google-beta
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.main.id
  project       = var.project_id
}

resource "google_compute_global_address" "lb_addr" {  
  name          = "raven-lb-address"
}

resource "google_service_networking_connection" "main" {
  network                 = google_compute_network.main.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.main.name]
}

resource "google_vpc_access_connector" "main" {
  provider       = google-beta
  project        = var.project_id
  name           = "raven-vpc-cx"
  ip_cidr_range  = "10.8.0.0/28"
  network        = google_compute_network.main.id
  region         = var.region
  max_throughput = 300
  depends_on     = [google_compute_global_address.main]
}


# Create a Cloud Run service
resource "google_cloud_run_service" "cloud_run_service" {
  name     = var.cloud_run_service_name
  location = var.region
  project  = var.project_id

  traffic {
    percent         = 100
    latest_revision = true
  }

  template {
    spec {
      container_concurrency = var.cloud_run_container_concurrency
      timeout_seconds       = var.cloud_run_timeout_seconds
       #service_account_name  = var.cloud_run_service_account

      containers {
        image = var.cloud_run_service_image_location

        resources {
          requests = {
            cpu    = var.cloud_run_cpu_request
            memory = var.cloud_run_memory_request
          }
          limits = {
            cpu    = var.cloud_run_cpu_limit
            memory = var.cloud_run_memory_limit
          }
        }

        ports {
          container_port = var.cloud_run_container_port
        }
      }
    }
  metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"        = "10"
        # "run.googleapis.com/cloudsql-instances"   = google_sql_database_instance.main.connection_name
        "run.googleapis.com/client-name"          = "terraform"
        "run.googleapis.com/vpc-access-egress"    = "private-ranges-only"
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.main.id
      }
    }
  }
  autogenerate_revision_name = true
}

# Allow unauthenticated requests to the Cloud Run service
data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers"
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth-env" {
  location    = google_cloud_run_service.cloud_run_service.location
  project     = google_cloud_run_service.cloud_run_service.project
  service     = google_cloud_run_service.cloud_run_service.name
  policy_data = data.google_iam_policy.noauth.policy_data
  depends_on  = [google_cloud_run_service.cloud_run_service]
}

resource "google_compute_region_network_endpoint_group" "serverless-neg" {
  name                  = "raven-serverless-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = google_cloud_run_service.cloud_run_service.name
  }
}

resource "google_compute_security_policy" "security-policy" {
  name = "raven-security"

  rule {
    action   = "deny(403)"
    priority = "1000"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["9.9.9.0/24"]
      }
    }
    description = "default deny rule"
  }

  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "default rule"
  }
}


module "service-loadbalancer" {
  source  = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  version = "~> 6.0"
  name    = "raven-demo-service"
  project = var.project_id
  address        = google_compute_global_address.lb_addr.address
  create_address = false

  #  if you're using ssl and have a domain go ahead and set this to true and uncomment the following lines
  ssl = false
  #  managed_ssl_certificate_domains = [local.domain]
  #  https_redirect                  = true

  backends = {
    default = {
      description = null
      groups = [
        {
          group = google_compute_region_network_endpoint_group.serverless-neg.id
        }
      ]
      enable_cdn              = false
      custom_request_headers  = null
      custom_response_headers = null
      security_policy         = google_compute_security_policy.security-policy.id

      iap_config = {
        enable               = false
        oauth2_client_id     = ""
        oauth2_client_secret = ""
      }
      log_config = {
        enable      = false
        sample_rate = null
      }
    }
  }
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

