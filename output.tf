output "loadbalancer_url" {
  value = google_compute_global_address.lb_addr.address
}