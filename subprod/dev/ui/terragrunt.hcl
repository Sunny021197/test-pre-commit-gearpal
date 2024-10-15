# modules
terraform {
  source = "../../../modules//ui"
   
}

include {
  path = find_in_parent_folders()
}
