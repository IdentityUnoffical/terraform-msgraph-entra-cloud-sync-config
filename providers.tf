terraform {
    required_providers {
        msgraph = {
        source  = "microsoft/msgraph"
        version = ">= 0.0.2"
        }
        azuread = {
        source  = "hashicorp/azuread"
        version = ">= 2.29.0"
        }
    }
}