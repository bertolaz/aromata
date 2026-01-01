# Docker Setup for Aromata Frontend

This guide explains how to build and run the Aromata Flutter web app using Docker.

## Prerequisites

- Docker installed on your system
- Docker Compose (optional, for easier management)

## Building the Docker Image

### Basic Build

```bash
cd aromata_frontend
docker build -t aromata-frontend .
```

### Build with Environment Variables

```bash
docker build \
  --build-arg SUPABASE_URL=http://127.0.0.1:54321 \
  --build-arg SUPABASE_ANON_KEY=your_anon_key_here \
  -t aromata-frontend .
```

### Using .env file

Create a `.env` file in the `aromata_frontend` directory:

```env
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_ANON_KEY=your_anon_key_here
```

Then build:

```bash
docker build \
  --build-arg SUPABASE_URL=$(grep SUPABASE_URL .env | cut -d '=' -f2) \
  --build-arg SUPABASE_ANON_KEY=$(grep SUPABASE_ANON_KEY .env | cut -d '=' -f2) \
  -t aromata-frontend .
```

## Running the Container

### Basic Run

```bash
docker run -p 8080:80 aromata-frontend
```

The app will be available at `http://localhost:8080`

### Using Docker Compose

```bash
# Make sure your .env file is set up
docker-compose up -d
```

The app will be available at `http://localhost:8080`

To stop:

```bash
docker-compose down
```

## Production Deployment

For production, you'll want to:

1. **Use production Supabase credentials**:
   ```bash
   docker build \
     --build-arg SUPABASE_URL=https://your-project.supabase.co \
     --build-arg SUPABASE_ANON_KEY=your_production_anon_key \
     -t aromata-frontend:latest .
   ```

2. **Use HTTPS**: Configure nginx with SSL certificates (update `nginx.conf`)

3. **Set up reverse proxy**: Use a reverse proxy like Traefik or Nginx for SSL termination

4. **Environment variables**: Consider using Docker secrets or environment files for sensitive data

## Customizing Nginx Configuration

The `nginx.conf` file is included but commented out in the Dockerfile. To use it:

1. Uncomment the COPY line in the Dockerfile:
   ```dockerfile
   COPY nginx.conf /etc/nginx/conf.d/default.conf
   ```

2. Rebuild the image

## Troubleshooting

### Build fails with "SUPABASE_ANON_KEY not set"
- Make sure you're passing the build args during build
- Check that your .env file is properly formatted

### App doesn't connect to Supabase
- Verify SUPABASE_URL and SUPABASE_ANON_KEY are correct
- Check network connectivity from container to Supabase
- For local Supabase, use `host.docker.internal` instead of `127.0.0.1`:
  ```
  SUPABASE_URL=http://host.docker.internal:54321
  ```

### Port already in use
- Change the port mapping: `-p 3000:80` (uses port 3000 instead of 8080)

## Multi-architecture Builds

To build for different architectures (e.g., ARM64 for Apple Silicon):

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t aromata-frontend .
```

