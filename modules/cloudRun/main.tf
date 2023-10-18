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
        percent         = 100
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