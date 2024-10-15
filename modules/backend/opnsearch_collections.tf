# terragrunt import aws_opensearchserverless_security_policy.auto_eai_gp_test_collection auto-eai-gp-test-collection/encryption
resource "aws_opensearchserverless_security_policy" "auto_eai_gp_test_collection" {
  name        = "auto-eai-gearpal-policy"
  description = "network security policy for collection"
  type        = "network"

  policy = jsonencode([
  {
    "Rules": [
      {
        "Resource": [
          "collection/eai-gearpal-collection"
        ],
        "ResourceType": "dashboard"
      },
      {
        "Resource": [
          "collection/eai-gearpal-collection"
        ],
        "ResourceType": "collection"
      }
    ],
    "AllowFromPublic": true
  }
])
}


resource "aws_opensearchserverless_security_policy" "gearpal_policy" {
  name        = "auto-eai-gearpal-policy"
  type        = "encryption"
  description = "encryption security policy for collection"
  policy = jsonencode({
    Rules = [
      {
        Resource = [
          "collection/eai-gearpal-collection"
        ],
        ResourceType = "collection"
      }
    ],
    AWSOwnedKey = true
  })
}

# terragrunt import aws_opensearchserverless_collection.eai_bb_test_collection fwak7zwk1zbt6jl6ljsj
# Define the OpenSearch Serverless Collection
resource "aws_opensearchserverless_collection" "eai_bb_test_collection" {
  name             = "eai-gearpal-collection"
  type             = "VECTORSEARCH"
  standby_replicas = "ENABLED"
  tags   = merge({ Name = var.app_name }, var.tags)

  depends_on = [aws_opensearchserverless_security_policy.gearpal_policy]
}