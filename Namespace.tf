resource "kubernetes_namespace" "cve_processor" {
  metadata {
    annotations = {
      name = "cve-processor"
    }

    labels = {
      mylabel = "cve-processor"
    }

    name = "cve-processor"
  }
  depends_on = [module.eks]
}

resource "kubernetes_namespace" "kafka" {
  metadata {
    annotations = {
      name = "kafka"
    }

    labels = {
      mylabel = "kafka"
    }

    name = "kafka"
  }
  depends_on = [module.eks]
}

resource "kubernetes_namespace" "db" {
  metadata {
    annotations = {
      name = "db"
    }

    labels = {
      mylabel = "db"
    }

    name = "db"
  }
}
resource "kubernetes_namespace" "autoscaler" {
  metadata {
    annotations = {
      name = "autoscaler"
    }

    labels = {
      mylabel = "autoscaler"
    }

    name = "autoscaler"
  }
}

resource "kubernetes_namespace" "operator" {
  metadata {
    annotations = {
      name = "operator"
    }

    labels = {
      mylabel = "operator"
    }

    name = "operator"
  }
}
