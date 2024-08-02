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

resource "kubernetes_namespace" "logging" {
  metadata {
    annotations = {
      name = "logging"
    }

    labels = {
      mylabel = "logging"
    }

    name = "logging"
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    annotations = {
      name = "monitoring"
    }

    labels = {
      mylabel = "monitoring"
    }

    name = "monitoring"
  }
}

resource "kubernetes_namespace" "istio" {
  metadata {
    name = "istio-system"
    labels = {
      istio-injection = "enabled"
    }
  }
}

# Create namespace for Cert-Manager
resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
    labels = {
      "istio-injection" = "enabled"
    }
  }
}

