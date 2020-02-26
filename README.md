# Istio BookInfo Envoy Config

Envoy configs dumped from Istio when going through different features of Istio

To dump a snapshot of Envoy configs at any point in time:

```
kubectl apply ... # apply Istio changes
./dump-config.sh
```
