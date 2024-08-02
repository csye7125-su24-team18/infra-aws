resource "aws_route53_record" "grafana" {
  provider = aws.infra
  zone_id  = "Z0737843TOQS535B51BB"    # Replace with your Route 53 Zone ID
  name     = "grafana.poojacloud24.pw" # Replace with your desired subdomain
  type     = "CNAME"                   # Use CNAME if pointing to a load balancer DNS name
  ttl      = "300"
  records  = ["a74ba4b1b14ad4b4b90de1e5aa256f29-1969840439.us-east-2.elb.amazonaws.com"] # Replace with the DNS name of your Istio IngressGateway
}

resource "aws_route53_record" "prometheus" {
  provider = aws.infra
  zone_id  = "Z0737843TOQS535B51BB"       # Replace with your Route 53 Zone ID
  name     = "prometheus.poojacloud24.pw" # Replace with your desired subdomain
  type     = "CNAME"                      # Use CNAME if pointing to a load balancer DNS name
  ttl      = "300"
  records  = ["a74ba4b1b14ad4b4b90de1e5aa256f29-1969840439.us-east-2.elb.amazonaws.com"] # Replace with the DNS name of your Istio IngressGateway
}

resource "kubernetes_manifest" "grafana_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "grafana-cert"
      namespace = "cert-manager"
    }
    spec = {
      secretName = "grafana-tls"
      issuerRef = {
        name = "letsencrypt-route53"
        kind = "ClusterIssuer"
      }
      commonName = "grafana.poojacloud24.pw"
      dnsNames = [
        "grafana.poojacloud24.pw"
      ]
    }
  }
}

resource "kubernetes_manifest" "prometheus_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "prometheus-cert"
      namespace = "cert-manager"
    }
    spec = {
      secretName = "prometheus-tls"
      issuerRef = {
        name = "letsencrypt-route53"
        kind = "ClusterIssuer"
      }
      commonName = "prometheus.poojacloud24.pw"
      dnsNames = [
        "prometheus.poojacloud24.pw"
      ]
    }
  }
}
