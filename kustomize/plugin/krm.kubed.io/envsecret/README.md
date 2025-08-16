# Env Secret  

Generates a secret based on the list of local environment variables to use. 

## Example 

```yaml
apiVersion: krm.kubed.io
kind: EnvSecret
metadata:
  name: test-secret
variables:
- HOME
- XDG_CONFIG_HOME
```
