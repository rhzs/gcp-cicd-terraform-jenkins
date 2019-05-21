# Defining ingress firewall rules

data "google_compute_network" "net" {
  name = "default"
}

resource "google_compute_firewall" "fw" {
  name    = "fw"
  network = "${data.google_compute_network.net.name}"

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
}
