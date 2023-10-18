output "cloud_run_name" {
  value = google_cloud_run_v2_service.module-gcr.name
}

output "cloud_run_location" {
  value = google_cloud_run_v2_service.module-gcr.location
}


# output "cloud_run_url" {
#   value = google_cloud_run_v2_service.module-gcr.instances[0].attributes.uri
# }