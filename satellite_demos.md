# Satellite Demo

## What we need for this demo

- OCP Virt cluster (https://console-openshift-console.apps.ocp.drkspace.fr/)
- Satellite server (https://satellite.apps.ocp.drkspace.fr/)
- AAP instance (https://aap-controller.apps.ocp.drkspace.fr/)
- RHEL VMs

## What this demo cover

- Automatically VM registration to Satellite via AK pass in cloud-init
- Errata / bug identification
- CV promotion and system upgrade
- OpenSCAP conplaiance
- Insights recommendations with satellite remediations

## Workflow to start

1. **W - Create VMs workflow** : Create VMs on OCP Virt with automatic registation on Satellite server and Insights
2. **W - Create RH Insights issues workflow** : Create problems detected on RH Insights on created VMs
3. **W - Delete VMs workflow** : Delete VMs previously created