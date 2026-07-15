output "cluster_name" {
  description = "Name of the provisioned Kind cluster"
  value       = kind_cluster.local.name
}

output "kubeconfig_path" {
  description = "Path to the kubeconfig written by the kind provider"
  value       = kind_cluster.local.kubeconfig_path
}
