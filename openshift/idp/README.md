# Cerate Google IDP for OpenShift

1. Go to [Google console](https://console.cloud.google.com/apis/credentials?project=cert-346414) to create OAuth2 client
```
https://oauth-openshift.apps.ocp.drkspace.fr/oauth2callback/googleidp
https://oauth-openshift.apps.ocpr01.drkspace.fr/oauth2callback/googleidp
https://oauth-openshift.apps.ocpr02.drkspace.fr/oauth2callback/googleidp
```

2. Encode your secret client in Base64
```
echo -n '$CLIENT_SECRET' | base64
```

3. Create Secret file in your cluster
```
$ oc create -f secret.yaml
```

4. Add IDP as login source
```
$ oc apply -f google_idp.yaml
```