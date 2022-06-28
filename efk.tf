resource "helm_release" "elastic" {
  name       = "elastic"
  namespace = var.namespace

  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  version    = "7.17.3" 
  
  values = [
     "${file("values/elasticsearch.yaml")}"
   ]
}


resource "helm_release" "kibana" {
  name       = "kibana"
  namespace  = var.namespace
  depends_on = [helm_release.elastic]
  repository = "https://helm.elastic.co"
  chart      = "kibana"
  version    = "7.17.3" 

  values = [
     "${file("values/kibana.yaml")}"
   ]
}

resource "helm_release" "fluent" {
  name       = "fluent"
  namespace = var.namespace
  depends_on = [helm_release.elastic]
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluent-bit"
  version    = "0.20.3"
  values = [
     "${file("values/fluent.yaml")}"
   ]
}
