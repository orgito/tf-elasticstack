locals {
   safe_name = "${replace(var.name, "_", "-")}"
}
