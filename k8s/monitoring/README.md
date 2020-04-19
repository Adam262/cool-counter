# Adding monitoring via Prometheus

## K8s metrics registry
K8s has the concept of a central metrics registry that we can use to query stats within a K8s resources. For example, it can be 
used as a scaling metric within Horizontal Pod Autoscalers.

We interact with the registry via three APIs:

* Resource Metrics API (for CPU and memory metrics)
* Custom Metrics API (for custom metrics on a K8s object)
* External Metrics API (for other custom metrics)

Note these are extension APIs. That is, they are not enabled in core Kubernetes, but can be registered via the so-called [aggregation layer](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/apiserver-aggregation/). 

## Prometheus operator
This is a metrics collector. We configure it to scrape metrics from a target such as our pods. The pods obtain their metrics via custom instrumentation code in our app. 

## Prometheus adapter
This is a metrics API server. We use it to expose custom and external metrics from Prometheus to the central registry

# Getting Started

```
helm install prometheus-operator stable/prometheus-operator --namespace monitoring
helm install prometheus-adapter stable/prometheus-adapter --namespace monitoring
```

# List custom metrics
```
kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1
```
