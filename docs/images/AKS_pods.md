```bash
NAMESPACE          NAME                                                             READY   STATUS      RESTARTS     AGE
alloy              alloy-95727                                                      2/2     Running     0            6h56m
alloy              alloy-xtdvs                                                      2/2     Running     0            6h56m
argocd             argocd-application-controller-0                                  1/1     Running     0            9h
argocd             argocd-applicationset-controller-576d8d6b76-8j99h                1/1     Running     0            9h
argocd             argocd-dex-server-64f84d4478-5669m                               1/1     Running     0            9h
argocd             argocd-notifications-controller-6cc497c75-pc4gh                  1/1     Running     0            9h
argocd             argocd-redis-6bb877959d-x6h6m                                    1/1     Running     0            9h
argocd             argocd-repo-server-6f554cff5f-gwpmf                              1/1     Running     0            9h
argocd             argocd-server-6bd45cf484-qkh7j                                   1/1     Running     0            9h
backend-ns         azure-workload-backend-dev-6b7877678c-cdlk5                      1/1     Running     0            3h50m
backend-ns         azure-workload-backend-dev-6b7877678c-dkrww                      1/1     Running     0            3h50m
backend-ns         azure-workload-backend-dev-6b7877678c-dwgbg                      1/1     Running     0            3h50m
backend-ns         azure-workload-backend-dev-6b7877678c-mxdlx                      1/1     Running     0            3h50m
external-secrets   eso-operator-external-secrets-58784cb564-bjrdr                   1/1     Running     0            9h
external-secrets   eso-operator-external-secrets-cert-controller-78698b6b8b-c2m9t   1/1     Running     0            9h
external-secrets   eso-operator-external-secrets-webhook-6cf46fc9d4-dhv2v           1/1     Running     0            9h
frontend-ns        azure-workload-frontend-dev-7df47cc55b-4l2kl                     1/1     Running     0            6h55m
frontend-ns        azure-workload-frontend-dev-7df47cc55b-hjh2x                     1/1     Running     0            6h56m
frontend-ns        azure-workload-frontend-dev-7df47cc55b-qc7bk                     1/1     Running     0            6h55m
kube-system        azure-wi-webhook-controller-manager-76dcf4697-4jjj8              1/1     Running     2 (9h ago)   9h
kube-system        azure-wi-webhook-controller-manager-76dcf4697-nqpvb              1/1     Running     2 (9h ago)   9h
kube-system        cilium-envoy-jd42s                                               1/1     Running     0            9h
kube-system        cilium-envoy-nrwml                                               1/1     Running     0            9h
kube-system        cilium-operator-69b585ff94-928hs                                 1/1     Running     0            9h
kube-system        cilium-operator-69b585ff94-gdnht                                 1/1     Running     0            9h
kube-system        cilium-rklt9                                                     1/1     Running     0            9h
kube-system        cilium-thp9h                                                     1/1     Running     0            9h
kube-system        cloud-node-manager-4t7lq                                         1/1     Running     0            10h
kube-system        cloud-node-manager-9mnhm                                         1/1     Running     0            10h
kube-system        coredns-5d474ff6db-6x5nb                                         1/1     Running     0            9h
kube-system        coredns-5d474ff6db-zqrkd                                         1/1     Running     0            10h
kube-system        coredns-autoscaler-6769f8f9b-9j6vk                               1/1     Running     0            10h
kube-system        csi-azuredisk-node-d94w7                                         3/3     Running     0            10h
kube-system        csi-azuredisk-node-ljl4p                                         3/3     Running     0            10h
kube-system        csi-azurefile-node-cshrp                                         4/4     Running     0            10h
kube-system        csi-azurefile-node-d8wzd                                         4/4     Running     0            10h
kube-system        konnectivity-agent-85f64b985-j8877                               1/1     Running     0            9h
kube-system        konnectivity-agent-85f64b985-pgnl2                               1/1     Running     0            9h
kube-system        konnectivity-agent-autoscaler-57c596c6fd-djfnr                   1/1     Running     0            10h
kube-system        metrics-server-85768b658b-j5pw4                                  2/2     Running     0            9h
kube-system        metrics-server-85768b658b-kzfpq                                  2/2     Running     0            9h
kyverno            kyverno-admission-controller-66787d458d-8whb8                    1/1     Running     0            6h55m
kyverno            kyverno-background-controller-8fb8b68cf-wgn9p                    1/1     Running     0            6h55m
kyverno            kyverno-cleanup-controller-fdcbbd468-724b5                       1/1     Running     0            6h55m
kyverno            kyverno-reports-controller-7949866bf7-s79br                      1/1     Running     0            6h55m
kyverno            kyverno-system-migrate-resources-p5fxk                           0/1     Completed   0            35m
loki               loki-0                                                           2/2     Running     0            6h56m
monitoring         alertmanager-kube-prometheus-stack-alertmanager-0                2/2     Running     0            6h55m
monitoring         kube-prometheus-stack-grafana-54dc8f677b-lfcqc                   3/3     Running     0            6h55m
monitoring         kube-prometheus-stack-kube-state-metrics-869857b4d7-dj5tz        1/1     Running     0            6h55m
monitoring         kube-prometheus-stack-operator-7bcd6567d9-d9p4c                  1/1     Running     0            6h55m
monitoring         kube-prometheus-stack-prometheus-node-exporter-85p4p             1/1     Running     0            6h55m
monitoring         kube-prometheus-stack-prometheus-node-exporter-l9m9v             1/1     Running     0            6h55m
monitoring         prometheus-kube-prometheus-stack-prometheus-0                    2/2     Running     0            6h54m

```