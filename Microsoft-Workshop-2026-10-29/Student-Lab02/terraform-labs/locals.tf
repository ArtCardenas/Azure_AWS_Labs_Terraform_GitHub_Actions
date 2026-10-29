# Diagnostic settings
locals {
  diagnostic_settings = {
    sendToLogAnalytics = {
      name                  = "law-demo-dev-swedencentral-001"
      workspace_resource_id = module.log_analytics_workspace.resource_id
    }
  }
}

