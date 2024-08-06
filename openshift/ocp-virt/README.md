# Notes about OCP Virt

## Create new DataVolume from ISO

```
virtctl image-upload dv win2019 --size=10Gi --force-bind --insecure --access-mode=ReadWriteOnce --image-path=/Users/dmartini/Downloads/win2019.iso -n openshift-virtualization-os-images
```