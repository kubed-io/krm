# Variable Transformer with `sed`  

Uses the linux `sed` command to replace any variable in the list with a value. In yaml files you can place the variables on pretty much anywhere within the values. 

TL;DR  
Variables in yaml like: `$(some_var)`  
Plugin values is just like `env` on a container:
```yaml
apiVersion: krm.kubed.io
kind: VarTransformer
metadata:
  name: test-variables
vars:
- name: some_var
  value: foo
- name: whoami
  valueFrom:
    env: USER
- name: the_ip
  valueFrom:
    liveRef:
      name: svc/kubernetes
      fieldPath: .spec.clusterIP
```