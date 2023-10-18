resource "google_cloud_run_v2_service" "module-gcr" {
    name = var.container_name
    location = var.location
    template {
        
        containers {
            # 下載檔案 docker hub - https://hub.docker.com/_/nginx
            image = var.image_name
            ports {
            name           = "http1"
            container_port = 8080
            }
            env {
             name = "SPRING_PROFILES_ACTIVE"
             value = "sit"
            }
        }
        
    }
    traffic {
        type = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
        percent         = 100
    }
}

import {
  to = google_sql_database_instance.sql_instance
  id = "raven-test"
}
resource "google_sql_database_instance" "sql_instance" {
  name             = "raven-test"
  database_version = "POSTGRES_15"
  region           = "asiz-east1"

  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "db-f1-micro"
  }
  
}

# IAM 所有人都可以去access
resource "google_cloud_run_service_iam_member" "public_access" {
  location = google_cloud_run_v2_service.module-gcr.location
  project  = google_cloud_run_v2_service.module-gcr.project
  service  = google_cloud_run_v2_service.module-gcr.name

  role   = "roles/run.invoker"
  member = "allUsers"
}