resource "null_resource" "validate_worspace" {
  count = "${terraform.workspace == var.stage ? 0 : 1}"
  "\nERROR: You are trying to run ${var.stage} stage in the ${terraform.workspace} workspace.\nCreate/Select the correct workspace first." = true
}
