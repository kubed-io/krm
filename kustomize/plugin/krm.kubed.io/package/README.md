# Package KRM Function

A Kustomize exec plugin that generates Fission Package and Function resources from a declarative configuration.

## Overview

This KRM function simplifies creating Fission serverless functions by:
- Automatically packaging your code into a base64-encoded zip archive
- Generating both Package and Function resources
- Supporting multiple languages (Python, Node.js, Go, etc.)
- Providing an escape hatch for advanced Fission configuration

## Usage

### Basic Example

Create a KRM Package resource that points to your function code:

**package.yaml:**
```yaml
apiVersion: krm.kubed.io
kind: Package
metadata:
  name: hello
  namespace: flow
spec:
  codePath: hello.py
  functionName: main
  environment:
    name: python
    namespace: flow
```

**hello.py:**
```python
def main():
    return "Hello World!\n"
```

**kustomization.yaml:**
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: flow
resources:
- environment.yaml
- httptrigger.yaml
generators:
- package.yaml
```

### Spec Fields

#### Required Fields

- **`spec.codePath`**: Relative path to the function code file
  - Example: `hello.py`, `src/handler.js`, `main.go`

- **`spec.environment.name`**: Name of the Fission environment
  - Example: `python`, `nodejs`, `go`

#### Optional Fields

- **`spec.functionName`**: Function entry point name (default: `main`)
  - For Python: function name in the file
  - For Node.js: exported function name
  - For Go: function name

- **`spec.environment.namespace`**: Environment namespace (defaults to metadata.namespace)

- **`spec.buildcmd`**: Custom build command for source packages
  - Example: `./build.sh`

- **`spec.source`**: URL to source archive for builder-based functions
  - Example: `http://storagesvc.flow/v1/archive?id=abc123`

### Generated Output

The KRM function generates two resources:

1. **Package**: Contains the base64-encoded zip of your code
2. **Function**: Links the package to the environment with correct entry point

The function entry point is automatically set to `<filename>.<functionName>` format required by Fission.

## Examples

### Python Function

**hello-python.yaml:**
```yaml
apiVersion: krm.kubed.io
kind: Package
metadata:
  name: hello-py
  namespace: flow
spec:
  codePath: hello.py
  functionName: main
  environment:
    name: python
    namespace: flow
```

### Node.js Function

**hello-node.yaml:**
```yaml
apiVersion: krm.kubed.io
kind: Package
metadata:
  name: hello-js
  namespace: flow
spec:
  codePath: handler.js
  functionName: handler
  environment:
    name: nodejs
    namespace: flow
```

**handler.js:**
```javascript
module.exports = async function(context) {
    return {
        status: 200,
        body: "Hello from Node.js!\n"
    };
}
```

### With Build Command

**build-package.yaml:**
```yaml
apiVersion: krm.kubed.io
kind: Package
metadata:
  name: my-function
  namespace: flow
spec:
  codePath: src/main.py
  functionName: handler
  buildcmd: "./build.sh"
  environment:
    name: python
    namespace: flow
```

## Installation

Copy the `Package` executable to your kustomize plugin directory:

```bash
mkdir -p $XDG_CONFIG_HOME/kustomize/plugin/krm.kubed.io/package
cp Package $XDG_CONFIG_HOME/kustomize/plugin/krm.kubed.io/package/
chmod +x $XDG_CONFIG_HOME/kustomize/plugin/krm.kubed.io/package/Package
```

Or if using the krm container image, the plugins are pre-installed.

## How It Works

1. Reads the Package KRM resource
2. Locates the code file at `spec.codePath` (relative to the KRM file)
3. Creates a zip archive containing the code
4. Base64-encodes the zip
5. Generates a Fission Package resource with the encoded zip
6. Generates a Fission Function resource with correct entry point format

## Requirements

- `yq` - YAML processor
- `zip` - Archive utility
- `base64` - Base64 encoding

All requirements are included in the krm container image.

## Notes

- The `codePath` is relative to the directory containing the Package KRM resource
- File extension is preserved in the zip (e.g., `.py`, `.js`, `.go`)
- Function entry point follows Fission format: `<filename>.<functionName>`
- Generated resources are separated by `---` for multi-document YAML

## See Also

- [Fission Documentation](https://fission.io/docs/)
- [Example Functions](./example/)
