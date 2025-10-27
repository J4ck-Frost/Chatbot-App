# PostgreSQL Test Application

This is a simple Node.js application to test the PostgreSQL database connection.

## What's Created

### 🗄️ **PostgreSQL Database Infrastructure**
- **Instance**: `dev-postgres` 
- **Database**: `postgres-db`
- **Private IP**: `10.106.0.5`
- **Port**: `5432`
- **Network**: Direct VPC connection (no public IP)

### 🚀 **Test Application**
- **Node.js/Express** web server
- **pg** PostgreSQL client library
- **Docker** containerized application
- **Kubernetes** deployment manifests

## Application Endpoints

- `GET /` - Application status
- `GET /health` - Database connection health check
- `GET /test-query` - Create table and insert test data

## Database Connection Details

The application connects to PostgreSQL using:
```javascript
{
  host: '10.106.0.5',        // Private IP - no internet access
  port: 5432,
  database: 'postgres-db',
  user: 'postgres',
  password: 'abcxyz',
  ssl: { rejectUnauthorized: false }
}
```

## Security Features ✅

- **Private IP only** - Database has no public IP address
- **VPC Direct Connection** - GKE pods connect directly to database
- **SSL/TLS Encryption** - All connections encrypted
- **Service Account Authentication** - Enhanced security
- **Network Isolation** - Traffic never leaves Google's network

## How to Deploy

### Option 1: GKE Cluster (Recommended)
```bash
# 1. Ensure GKE cluster is ready
gcloud container clusters get-credentials gke-cluster-dev --zone=asia-southeast1-a

# 2. Build and push image
docker build -t asia-southeast1-docker.pkg.dev/devopts-k2-advance/team1-ai-repo/postgres-test-app:latest .
docker push asia-southeast1-docker.pkg.dev/devopts-k2-advance/team1-ai-repo/postgres-test-app:latest

# 3. Deploy to Kubernetes
kubectl apply -f k8s-deployment.yaml

# 4. Get external IP
kubectl get service postgres-test-app-service
```

### Option 2: Local Testing
```bash
# Run locally (requires Node.js)
npm install
npm start

# Test endpoints
curl http://localhost:3000/health
curl http://localhost:3000/test-query
```

## Testing the Connection

Once deployed, test these endpoints:

- **Health Check**: `http://[EXTERNAL-IP]/health`
  - Tests basic database connectivity
  - Returns current timestamp from database

- **Query Test**: `http://[EXTERNAL-IP]/test-query`
  - Creates a test table
  - Inserts test data
  - Returns recent records

## Current Infrastructure Status

✅ **VPC Network**: `second-vpc` with subnets  
✅ **Cloud SQL**: Private PostgreSQL instance  
✅ **Artifact Registry**: Container image repository  
✅ **Storage Bucket**: Application storage  
✅ **GKE Cluster**: `gke-cluster-dev` (provisioning)  
✅ **Service Accounts**: Database access permissions  

## Connection Architecture

```
GKE Pod → Private Network (10.x.x.x) → Cloud SQL Private IP (10.106.0.5:5432)
```

**Benefits:**
- **Fastest**: Direct connection, no proxy
- **Securest**: No public IP, private network only  
- **Simplest**: No complex networking setup
- **Cost-effective**: No additional network charges

The database is completely isolated from the internet and can only be accessed from resources within your VPC network.