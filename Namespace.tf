resource "kubernetes_namespace" "cve_processor" {
  metadata {
    annotations = {
      name = "cve-processor"
    }

    labels = {
      mylabel = "cve-processor",
        istio-injection = "enabled"
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
      mylabel = "kafka",
        istio-injection = "enabled"
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
      mylabel = "db",
      istio-injection = "enabled"
      
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
      mylabel = "autoscaler",
      istio-injection = "enabled"
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
      mylabel = "operator",
      istio-injection = "enabled"
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
      mylabel = "logging",
      istio-injection = "enabled"
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
      mylabel = "monitoring",
      istio-injection = "enabled"
    }

    name = "monitoring"
  }
}


resource "kubernetes_namespace" "istio" {
  metadata {
    name = "istio-system",
    istio-injection = "enabled"
  }
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager",
    istio-injection = "enabled"
  }
}
