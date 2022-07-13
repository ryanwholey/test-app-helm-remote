resource "argocd_application" "test_application" {
  metadata {
    name = "test-application"
    annotations = {
      "argocd-image-updater.argoproj.io/image-list" = "docker.io/ryanwholey/test-app-helm-remote"
    }
  }

  wait = true

  spec {
    source {
      repo_url        = "https://github.com/ryanwholey/test-app-helm-remote"
      path            = ".deploy"
      target_revision = "HEAD"
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
  }
}

resource "argocd_application" "updater_test" {
  metadata {
    name = "updater-test"
    annotations = {
      "argocd-image-updater.argoproj.io/image-list" = "docker.io/ryanwholey/test-app-helm-remote"
    }
  }

  wait = true

  spec {
    source {
      repo_url        = "https://github.com/ryanwholey/app-helm-chart"
      path            = "."
      target_revision = "HEAD"

      helm {
        parameter {
          name  = "image.tag"
          value = "18201bea378300e498c1706b89b589a5a3ba2ab7"
        }
        parameter {
          name  = "image.name"
          value = "docker.io/ryanwholey/test-app-helm-remote"
        }
        parameter {
          name  = "name"
          value = "updater-test"
        }
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
  }
}
