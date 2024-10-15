locals {
    application_id          = "EAI"
    application_name        = "EAI GEARPALGPT"
    created_by_email        = "sheevam.thapa@toyota.com"
    team                    = "EAI"
    common_tags = {
       Environment = var.environment
       Type  = "GearPal"
       Managedby = "Terraform"
    }
    managed_rules_sets = tomap({
    AWSManagedRulesKnownBadInputsRuleSet = {
      priority        = 0
      override_action = "none"
      excluded_rules  = []
    },
    AWSManagedRulesAmazonIpReputationList = {
      priority        = 2
      override_action = "none"
      excluded_rules  = []
    }
  })
  /* zscaler_ips = [
    "162.246.77.114/32", # zScaler DDC" connectors
    "162.246.78.229/32", # zScaler DC2 connectors
    #AWS Connectors - EAST:
    "10.89.146.172/32", #aws-nzpaeast1a(internal)
    "52.5.126.144/32",  #aws-nzpaeast1a
    "10.89.146.223/32", #aws-nzpaeast1b(internal)
    "52.54.127.251/32", #aws-nzpaeast1b
    #AWS Connectors - WEST:
    "10.57.146.73/32",   #aws-nzpawest1a(internal)
    "44.236.235.170/32", #aws-nzpawest1a
    "10.57.146.160/32",  #aws-nzpawest1b(internal)
    "50.112.144.11/32"   #aws-nzpawest1b
  ]*/
}