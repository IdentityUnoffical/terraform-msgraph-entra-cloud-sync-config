variable "ad_domain" {
  description = "The on-premises Active Directory domain name (e.g., contoso.com)."
  type        = string
}

variable "tenant_id" {
  description = "The Entra tenant ID where the Entra Cloud Sync application will be created."
  type        = string
}