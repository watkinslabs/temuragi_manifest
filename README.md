# Temuragi Kubernetes Deployment

## Files
- `manifests.yaml` - Main Kubernetes resources
- `secrets-backend.yaml` - Backend secrets (EDIT BEFORE DEPLOYING!)
- `configmap-backend.yaml` - Backend configuration
- `deploy.sh` - Deployment script

## Before Deploying

1. **Update secrets** in `secrets-backend.yaml`:
   - Change all password values
   - Generate new cipher-key and secret-key

2. **Update ingress host** in `manifests.yaml`:
   - Replace `temuragi.example.com` with your domain

3. **Update image tags** if needed:
   - Backend image in `manifests.yaml`

## Deploy

```bash
./deploy.sh
```

## Verify Deployment

```bash
kubectl -n temuragi get pods
kubectl -n temuragi get svc
kubectl -n temuragi get ingress
```

## Access Logs

```bash
kubectl -n temuragi logs -f deployment/temuragi-backend
kubectl -n temuragi logs -f deployment/temuragi-static
```
# temuragi_manifest
