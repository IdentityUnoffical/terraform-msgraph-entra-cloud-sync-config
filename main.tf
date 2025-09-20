resource "msgraph_update_resource" "enable_sync_on_tenant" {
  url = "organization/{${var.tenant_id}}"
  body = {
    onPremisesSyncEnabled = true
  }
}

resource "azuread_application_from_template" "aad2entra" {
  display_name = "Entra-Cloud-Sync-${var.ad_domain}"
  template_id  = "1a4721b3-e57f-4451-ae87-ef078703ec94" ## Entra Cloud Sync Application Template ID
}

resource "msgraph_resource_action" "entra_cloud_sync_secrets" {
  resource_url   = "servicePrincipals/${azuread_application_from_template.aad2entra.service_principal_object_id}/synchronization/secrets"
  method =  "PUT"
  body = {
    value = [
      {
        key   = "AppKey"
        value = "{\"appKeyScenario\":\"AD2AADPasswordHash\"}"
      },
      {
        key   = "Domain"
        value = "{\"domain\":\"${var.ad_domain}\"}"
      }
    ]
  }
}

resource "msgraph_resource" "entra_cloud_sync_job" {
  url = "servicePrincipals/${azuread_application_from_template.aad2entra.service_principal_object_id}/synchronization/jobs"
  body = {
    templateId = "AD2AADProvisioning"
  }
  response_export_values = {
    job_id = "id"
    status = "synchronization.status"
    all    = "@"
  }
}

resource "msgraph_resource" "entra_cloud_sync_job_password_hash" {
  url = "servicePrincipals/${azuread_application_from_template.aad2entra.service_principal_object_id}/synchronization/jobs"
  body = {
    templateId = "AD2AADPasswordHash"
  }
  response_export_values = {
    job_id = "id"
    status = "synchronization.status"
    all    = "@"
  }
}

locals {
  # Render the schema content from template plus modifications. (large JSON string)
  schema_content = templatefile("${path.module}/jobschemas/jobschema.json.tftpl", {
    service_principal_object_id = azuread_application_from_template.aad2entra.service_principal_object_id
    synchronization_job_id      = msgraph_resource.entra_cloud_sync_job.output.job_id
  })
}
resource "msgraph_resource_action" "put_schema" {
  resource_url = "servicePrincipals/${azuread_application_from_template.aad2entra.service_principal_object_id}/synchronization/jobs/${msgraph_resource.entra_cloud_sync_job.output.job_id}/schema"
  method       = "PUT"
  body = jsondecode(local.schema_content)
  
}

resource "msgraph_resource_action" "start_job" {
  resource_url = "servicePrincipals/${azuread_application_from_template.aad2entra.service_principal_object_id}/synchronization/jobs/${msgraph_resource.entra_cloud_sync_job.output.job_id}"
  method       = "POST"
  action = "start"
}

resource "msgraph_resource_action" "start_job_password_hash" {
  resource_url = "servicePrincipals/${azuread_application_from_template.aad2entra.service_principal_object_id}/synchronization/jobs/${msgraph_resource.entra_cloud_sync_job_password_hash.output.job_id}"
  method       = "POST"
  action = "start"
}
