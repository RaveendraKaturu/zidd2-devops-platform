Write-Host "Starting Grafana port-forward..." -ForegroundColor Green
Write-Host "Open: http://localhost:8080  (login: admin / admin)" -ForegroundColor Cyan
kubectl port-forward -n monitoring svc/monitoring-grafana 8080:80
