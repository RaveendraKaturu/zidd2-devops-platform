# zidd2 Helm chart

Deploys the ZIDD 2.0 chat platform onto the EKS cluster:
auth-service, chat-service, frontend (nginx), MySQL + MongoDB (StatefulSets),
Redis, HPA on the three app tiers, and a TargetGroupBinding that wires the
frontend into the Terraform-created ALB target group.

## Prerequisites
- Images pushed to ECR (tag matches `values.yaml` imageTag)
- `aws eks update-kubeconfig --name zidd2 --region ap-south-1`
- AWS Load Balancer Controller + metrics-server running (installed by Terraform)

## Configure
Edit `values.yaml` (or pass `--set`):
- `ecrRegistry`  = 928341811904.dkr.ecr.ap-south-1.amazonaws.com
- `imageTag`     = v1
- `targetGroupArn` = terraform output frontend_target_group_arn

## Install
```
helm upgrade --install zidd2 ./helm/zidd2 -n zidd2 --create-namespace
kubectl get pods -n zidd2 -w
```

## Verify
```
kubectl get pods -n zidd2
kubectl get targetgroupbinding -n zidd2
kubectl get hpa -n zidd2
```
Then browse https://zidd2.raveendra.website (after the GoDaddy CNAME to CloudFront).

## Uninstall
```
helm uninstall zidd2 -n zidd2
# PVCs are retained by design; delete manually if you want the data gone:
kubectl delete pvc -n zidd2 --all
```

## Notes
- Sized for t3.medium nodes: single replicas, modest requests. Scale via HPA.
- Secrets here are demo values. For prod, source them from AWS Secrets Manager
  via the External Secrets Operator (the secret ARNs are in terraform outputs).
- Databases run in-cluster (StatefulSets on gp3/EBS). Swap to RDS/DocumentDB/
  ElastiCache later by changing only the host env vars in the deployments.
