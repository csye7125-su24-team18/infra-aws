resource "helm_release" "cert-manager"{
    name = "cert-manager"
    namespace = kubernetes_namespace.cert_manager.metadata[0].name
    create_namespace = true
    repository = "https://charts.jetstack.io"
    chart = "cert-manager"
    version = "v1.5.3"
    cleanup_on_fail = true
    force_update = false
    wait = true
    values = [
        file("cert-manager-values.yaml")
    ]
    depends_on = [
        kubernetes_namespace.cert_manager
    ]
}
