# # AWS Route 53 Record for Grafana
# resource "aws_route53_record" "grafana" {
#   provider = aws.infra
#   zone_id  = "Z0737843TOQS535B51BB"    # Replace with your Route 53 Zone ID
#   name     = "grafana.poojacloud24.pw" # Replace with your desired subdomain
#   type     = "CNAME"                   # Use CNAME if pointing to a load balancer DNS name
#   ttl      = "300"
#   records  = ["a5a41a546191945a8abc61f6528f0ac4-945308486.us-east-2.elb.amazonaws.com"] # Replace with your Istio Ingress Gateway DNS name
# }

# # AWS Route 53 Record for Prometheus
# resource "aws_route53_record" "prometheus" {
#   provider = aws.infra
#   zone_id  = "Z0737843TOQS535B51BB"       # Replace with your Route 53 Zone ID
#   name     = "prometheus.poojacloud24.pw" # Replace with your desired subdomain
#   type     = "CNAME"                      # Use CNAME if pointing to a load balancer DNS name
#   ttl      = "300"
#   records  = ["a5a41a546191945a8abc61f6528f0ac4-945308486.us-east-2.elb.amazonaws.com"] # Replace with your Istio Ingress Gateway DNS name
# }
