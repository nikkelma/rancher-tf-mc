data "rancher2_cluster" "target" {
  name = var.cluster_name
}

resource "rancher2_project" "target" {
  name       = var.project_name
  cluster_id = data.rancher2_cluster.target.id
}

resource "rancher2_namespace" "target" {
  for_each = toset(var.namespace_names)

  name       = each.value
  project_id = rancher2_project.target.id
}

resource "rancher2_project_role_template_binding" "owners" {
  lifecycle {
    ignore_changes = [
      user_id,
    ]
  }

  for_each = var.project_owner_principals

  name              = "project-owner-${each.key}"
  project_id        = rancher2_project.target.id
  role_template_id  = "project-owner"
  user_principal_id = each.value
}

resource "rancher2_project_role_template_binding" "members" {
  lifecycle {
    ignore_changes = [
      user_id,
    ]
  }

  for_each = var.project_member_principals

  name              = "project-member-${each.key}"
  project_id        = rancher2_project.target.id
  role_template_id  = "project-member"
  user_principal_id = each.value
}
