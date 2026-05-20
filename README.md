# Crush DevSpaces

OpenShift DevSpaces workspace with Crush AI coding TUI pre-installed.

## Quick Start

### 1. Build and Push the Container Image

```bash
# Log in to Quay.io
podman login quay.io

# Build the image
podman build -t quay.io/YOUR_USERNAME/crush-devspaces:latest -f Containerfile .

# Push to Quay.io
podman push quay.io/YOUR_USERNAME/crush-devspaces:latest
```

Or use the build script:
```bash
./build.sh YOUR_USERNAME
```

### 2. Update the Devfile

Edit `devfile.yaml` and replace `YOUR_USERNAME` with your actual Quay.io username:

```yaml
image: quay.io/YOUR_USERNAME/crush-devspaces:latest
```

### 3. Deploy to OpenShift DevSpaces

#### Option A: From Git Repository

1. Push this repository to GitHub/GitLab
2. In DevSpaces dashboard, click "Create Workspace"
3. Enter your repository URL
4. DevSpaces will auto-detect the `devfile.yaml`

#### Option B: Direct Import

1. In DevSpaces dashboard, click "Create Workspace"
2. Select "Import from Git"
3. Paste your repository URL
4. Click "Create & Open"

### 4. Configure API Keys

**Option A: Via Environment Variables (for testing)**

Once the workspace is running, open a terminal and export your keys:

```bash
export ANTHROPIC_API_KEY="your-key-here"
export OPENAI_API_KEY="your-key-here"
export CUSTOM_API_ENDPOINT="https://your-api.example.com/v1"
export CUSTOM_API_KEY="your-key-here"
```

**Option B: Via Kubernetes Secrets (recommended for production)**

Create a secret in your DevSpaces namespace:

```bash
oc create secret generic crush-api-keys \
  --from-literal=ANTHROPIC_API_KEY="your-key" \
  --from-literal=OPENAI_API_KEY="your-key" \
  --from-literal=CUSTOM_API_KEY="your-key" \
  --from-literal=CUSTOM_API_ENDPOINT="https://your-api.example.com/v1"

# Label it so DevSpaces injects it
oc label secret crush-api-keys controller.devfile.io/watch-secret=true
```

Then update the `devfile.yaml` env section to reference the secret values.

### 5. Run Crush

From the DevSpaces terminal:

```bash
crush
```

Or use the task menu and select "run-crush".

## Files

- **`Containerfile`** - Container image with Crush pre-installed on UBI9
- **`devfile.yaml`** - OpenShift DevSpaces workspace definition
- **`crush.json`** - Default Crush configuration with multi-provider support
- **`setup.sh`** - Legacy install script (not used with container approach)
- **`build.sh`** - Helper script to build and push the image

## Customization

### Adding More Providers

Edit `crush.json` to add additional AI providers. See [Crush documentation](https://github.com/charmbracelet/crush) for supported providers.

### Custom Model Endpoints

The `custom` provider in `crush.json` supports any OpenAI-compatible API:

```json
"custom": {
  "type": "openai-compat",
  "base_url": "$CUSTOM_API_ENDPOINT",
  "api_key": "$CUSTOM_API_KEY",
  "models": [
    {
      "id": "your-model-id",
      "name": "Your Model Name",
      "context_window": 128000,
      "default_max_tokens": 4096
    }
  ]
}
```

## Troubleshooting

### Image Pull Errors

Ensure your Quay.io repository is public, or configure image pull secrets:

```bash
oc create secret docker-registry quay-pull-secret \
  --docker-server=quay.io \
  --docker-username=YOUR_USERNAME \
  --docker-password=YOUR_PASSWORD

oc secrets link default quay-pull-secret --for=pull
```

### Crush Not Starting

Check that API keys are set:

```bash
env | grep API_KEY
```

View Crush logs:

```bash
cat ~/.local/share/crush/crush.log
```

## Resources

- [Crush GitHub](https://github.com/charmbracelet/crush)
- [OpenShift DevSpaces Docs](https://developers.redhat.com/products/openshift-dev-spaces/overview)
- [Devfile v2 Spec](https://devfile.io/)
