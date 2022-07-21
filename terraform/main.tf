resource "argocd_application" "test_application" {
  metadata {
    name = "test-application"
    annotations = {
      "argocd-image-updater.argoproj.io/image-list"                           = "test-app-helm-remote=docker.io/ryanwholey/test-app-helm-remote"
      "argocd-image-updater.argoproj.io/test-app-helm-remote.update-strategy" = "latest"
      "argocd-image-updater.argoproj.io/test-app-helm-remote.helm.image-name" = "app-helm-chart.image.name"
      "argocd-image-updater.argoproj.io/test-app-helm-remote.helm.image-tag"  = "app-helm-chart.image.tag"
    }
  }

  wait = true

  spec {
    source {
      repo_url        = "https://github.com/ryanwholey/test-app-helm-remote"
      path            = ".deploy"
      target_revision = "HEAD"

      helm {
        values = yamlencode({
          "app-helm-chart" = {
            name = "test-application"
            image = {
              name = "docker.io/ryanwholey/test-app-helm-remote"
            }
            app = {
              deployment = {
                port = 80
              }
              service = {
                type = "ClusterIP"
              }
            }
          }
        })
        value_files = ["image.yml"]
      }
    }

    project = "default"

    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "default"
    }

    sync_policy {
      # https://argo-cd.readthedocs.io/en/stable/user-guide/auto_sync/#automated-sync-policy
      automated = {
        # https://argo-cd.readthedocs.io/en/stable/user-guide/auto_sync/#automatic-pruning-with-allow-empty-v18
        allow_empty = false
        # https://argo-cd.readthedocs.io/en/stable/user-guide/auto_sync/#automatic-pruning
        prune = true
        # https://argo-cd.readthedocs.io/en/stable/user-guide/auto_sync/#automatic-self-healing
        self_heal = false
      }
      # https://argo-cd.readthedocs.io/en/stable/user-guide/sync-options/
      sync_options = []
    }

    # ignore_difference {
    #   group = "apps"
    #   kind  = "Deployment"
    #   name  = "test-application"

    #   jq_path_expressions = [
    #     ".spec.template.spec.containers[0].image",
    #   ]
    # }
  }
}
