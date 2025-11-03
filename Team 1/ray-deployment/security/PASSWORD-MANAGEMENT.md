# Ray Dashboard Password Management

## Get Current Password
```bash
kubectl get secret ray-dashboard-secret -o jsonpath="{.data.password}" | base64 -d
```

## PowerShell Version
```powershell
kubectl get secret ray-dashboard-secret -o jsonpath="{.data.password}" | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
```

## Rotate Password
```bash
# Generate new secure password
NEW_PASSWORD="Ray-Secure-2025-$(shuf -i 1000-9999 -n 1)"

# Update secret
kubectl patch secret ray-dashboard-secret -p='{"data":{"password":"'$(echo -n $NEW_PASSWORD | base64)'"}}'

# Restart Ray cluster to pick up new password
kubectl delete pod -l ray.io/node-type=head
```