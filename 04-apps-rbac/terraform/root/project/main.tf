provider "rancher2" {
  version = "~> 1.9"

  api_url    = var.rancher_api_url
  access_key = var.rancher_access_key
  secret_key = var.rancher_secret_key
}

module "app_a_project" {
  source = "../../modules/team-project"

  cluster_name = "test-tooling-a"

  project_name = "App A"
  namespace_names = [
    "app-a-web",
    "app-a-api",
  ]
  project_owner_principals = {
    "nikkelma" = "github_user://16194510",
    "shpwrck" = "github_user://58433720",
  }
  project_member_principals = {
    "oats87" = "github_user://30601846"
    "ebauman" = "github_user://5565738"
  }
}
