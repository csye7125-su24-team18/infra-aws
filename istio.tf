resource "helm_release" "istio_base_chart" {
  name            = "istio-base"
  namespace       = kubernetes_namespace.istio.metadata[0].name
  repository      = "https://istio-release.storage.googleapis.com/charts"
  chart           = "base"
  cleanup_on_fail = true
  force_update    = false
  depends_on = [
    kubernetes_namespace.istio
  ]
}

resource "helm_release" "istiod_chart" {
  name            = "istiod"
  namespace       = kubernetes_namespace.istio.metadata[0].name
  repository      = "https://istio-release.storage.googleapis.com/charts"
  chart           = "istiod"
  cleanup_on_fail = true
  force_update    = false
  timeout         = 600

  # set {
  #   name  = "telemetry.enabled"
  #   value = "true"
  # }
  # set {
  #   name  = "meshConfig.IngressService"
  #   value = "istio-gateway"
  # }
  # set {
  #   name  = "meshConfig.IngressSelector"
  #   value = "gateway"
  # }
  values = [
    file("istio.yaml")
  ]
  depends_on = [
    helm_release.istio_base_chart
  ]
}

resource "helm_release" "istio_ingress_chart" {
  name             = "istio-ingress"
  namespace        = kubernetes_namespace.istio.metadata[0].name
  create_namespace = true
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "gateway" # Changed to istio-ingressgateway
  cleanup_on_fail  = true
  force_update     = false
  # wait             = false
  # timeout = 600

  values = [
    file("istio.yaml")
  ]

  depends_on = [
    kubernetes_namespace.istio,
    helm_release.istiod_chart, helm_release.istio_base_chart
  ]
}

# resource "null_resource" "istio_addons" {
#   provisioner "local-exec" {
#     command = <<EOT
# for ADDON in kiali jaeger prometheus grafana
# do
#     ADDON_URL="https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/$ADDON.yaml"
#     kubectl apply -f $ADDON_URL
# done
# EOT
#   }

#   depends_on = [
#     helm_release.istio_ingress_chart
#   ]
# }



