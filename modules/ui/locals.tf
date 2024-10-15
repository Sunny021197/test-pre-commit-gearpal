# Define local variables that can be reused within the Terraform configuration
locals {
  application_id   = "EAI"
  application_name = "EAI GEARPAL"
  created_by_email = "sheevam.thapa@toyota.com"
  team             = "EAI"
  zscaler_ips = [
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
    ]
  tmna_network_device_ips = [
    "69.25.174.0/24",
    "162.246.76.0/22"
  ]
  tmna_vdi_ips = [
    # TMNA AWS Workspaces IP's 
    # AWS Management network interface 
    # For WSP BYOL Windows WorkSpaces
    "54.239.224.0/20",
    "10.0.0.0/8",
    "172.23.0.0/16",
    "172.22.0.0/16",
    # Primary Network interface (TMNA)
    "10.188.0.0/19",   # Us East 1- Prod - Workspace 
    "10.189.128.0/19", # US west 2 - DR - workspace
    "10.189.1.0/24",   # non-prod workspace 
    # AWS Appstream IP's
    "198.19.0.0/16",
    # Primary Network interface (TMNA)
    "10.188.32.0/21",  # Us East 1- Prod - appstream
    "10.189.160.0/21", # US west 2 - DR - Appstream
    "10.189.0.0/24"    # US West 2 - non-prod - appstream
  ]
  list_of_all_zscalar_ips = [
    "10.0.0.0/8",
    # "10.57.146.73/32",
    # "10.57.146.160/32",
    # "10.89.146.172/32",
    # "10.89.146.223/32",
    # "10.188.0.0/19",
    # "10.188.32.0/21",
    # "10.189.0.0/24",
    # "10.189.1.0/24",
    # "10.189.128.0/19",
    # "10.189.160.0/21",
    "44.236.235.170/32",
    "50.112.144.11/32",
    "52.5.126.144/32",
    "52.54.127.251/32",
    "54.239.224.0/20",
    "58.220.95.0/24",
    "64.215.22.0/24",
    "69.25.174.0/24",
    "87.58.64.0/18",
    "94.188.131.0/25",
    "94.188.139.64/26",
    "94.188.248.64/26",
    "98.98.26.0/24",
    "98.98.27.0/24",
    "98.98.28.0/24",
    "101.2.192.0/18",
    "104.129.192.0/20",
    "112.137.170.0/24",
    "124.248.141.0/24",
    "128.177.125.0/24",
    "136.226.0.0/16",
    # "136.226.100.0/23",
    # "136.226.102.0/23",
    # "136.226.104.0/23",
    # "136.226.238.0/23",
    "137.83.128.0/18",
    "140.210.152.0/23",
    "147.161.128.0/17",
    "147.161.192.0/23",
    "147.161.194.0/23",
    "147.161.196.0/23",
    "147.161.198.0/23",
    "154.113.23.0/24",
    "162.246.76.0/22",
    "162.246.77.114/32",
    "162.246.78.229/32",
    "165.225.0.0/17",
    "165.225.32.0/23",
    "165.225.36.0/23",
    "165.225.96.0/23",
    "165.225.110.0/23",
    "165.225.192.0/18",
    "165.225.216.0/23",
    "167.103.0.0/16",
    # "167.103.8.0/23",
    # "167.103.10.0/23",
    # "167.103.12.0/23",
    # "167.103.14.0/23",
    # "167.103.16.0/23",
    # "167.103.28.0/23",
    # "167.103.42.0/23",
    # "167.103.44.0/23",
    # "167.103.46.0/23",
    "170.85.0.0/16",
    # "170.85.96.0/23",
    # "170.85.98.0/23",
    # "170.85.100.0/23",
    # "170.85.102.0/23",
    # "170.85.104.0/23",
    "185.46.212.0/22",
    "194.9.96.0/20",
    "194.9.112.0/22",
    "194.9.116.0/24",
    "196.23.154.64/27",
    "196.23.154.96/27",
    "197.98.201.0/24",
    "197.156.241.224/27",
    "198.14.64.0/18",
    "198.19.0.0/16",
    "199.168.148.0/23",
    "209.55.128.0/18",
    "209.55.192.0/19",
    "211.144.19.0/24",
    "220.243.154.0/23",
    "221.122.91.0/24"
  ]
  # list_of_all_ips   = concat(var.list_of_ips, local.zscaler_ips, local.tmna_network_device_ips, local.tmna_vdi_ips)
  list_of_all_ips   = concat(var.list_of_ips, local.list_of_all_zscalar_ips)
  managed_rules_sets = tomap({
        AWSManagedRulesKnownBadInputsRuleSet = {
            priority        = 0
            override_action = "none"
            excluded_rule = []
        },
        AWSManagedRulesCommonRuleSet = {
            priority             = 1
            override_action      = "none"
            excluded_rule = []
        },
        AWSManagedRulesAmazonIpReputationList = {
            priority        = 2
            override_action = "none"
            excluded_rule = []
        }
    })
}