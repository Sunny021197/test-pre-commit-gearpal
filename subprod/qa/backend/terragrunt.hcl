# modules
terraform {
  source = "../../../modules//backend"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  image_tag = "latest"
}
