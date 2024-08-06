# RHDE OpenShift

## RHDE image creation

1. Install needed image builder components en RHEL VM
```
yum install osbuild-composer composer-cli cockpit-composer
systemctl enable --now osbuild-composer.socket
source /etc/bash_completion.d/composer-cli
systemctl restart osbuild-composer
composer-cli status show
API server status:
    Database version:   0
    Database supported: true
    Schema version:     0
    API version:        1
    Backend:            osbuild-composer
    Build:              NEVRA:osbuild-composer-101-1.el9.x86_64
```

2. Add needed repositories to image builder
```
cat > rhocp-4.16.toml <<EOF
id = "rhocp-4.16"
name = "Red Hat OpenShift Container Platform 4.16 for RHEL 9"
type = "yum-baseurl"
url = "https://cdn.redhat.com/content/dist/layered/rhel9/$(uname -m)/rhocp/4.16/os"
check_gpg = true
check_ssl = true
system = false
rhsm = true
EOF
```

```
cat > fast-datapath.toml <<EOF
id = "fast-datapath"
name = "Fast Datapath for RHEL 9"
type = "yum-baseurl"
url = "https://cdn.redhat.com/content/dist/layered/rhel9/$(uname -m)/fast-datapath/os"
check_gpg = true
check_ssl = true
system = false
rhsm = true
EOF
```

```
sudo composer-cli sources add rhocp-4.16.toml
sudo composer-cli sources add fast-datapath.toml
sudo composer-cli sources list
```

3. Create RHDE 4.16 blueprint
```
cat > rhde_4.16_v1_blueprint.toml <<EOF
name = "RHDE_4_16_v1"
description = "MicroShift 4.16.1 on x86_64 platform"
version = "0.0.1"
modules = []
groups = []

[[packages]]
name = "microshift"
version = "4.16.1"

[customizations.services]
enabled = ["microshift"]

[customizations.firewall]
ports = ["22:tcp", "80:tcp", "443:tcp", "5353:udp", "6443:tcp", "30000-32767:tcp", "30000-32767:udp"]

[[customizations.user]]
name = "cloud-user"
description = "Initial User"
key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC3OL8vJoTsbn/LBUZWgV8YYmxUZSMAWZ6UKMHC2iF9VCYmuI0opJKNBpEDFlomrENOm7HkEIafdPpFfEiDMszDhskvNWAVPiJJChjMBxFgvNWLAEHJQKvGaylVDF4yOex9ehMKOnhBVnO7FFrn33AmgiikEQRcqkz9Q1NQ7ccDZzF5eml0brxmO+2IziUrPdeVwkR7Wzw19zyxLf3f7dfGkfnfoeku1D8BWQaclN0T8AAC4IAVQ1YXp5kf4rpPdf3eCMUKItJCwW4nAKLmJDoJTMXx6LsOGsBZHwPxV0LbR9titUhGpRCBor2nYs1EnN4qCd7f+3yU0lZ+dV5HdMWXesD2czEY8CTncEhD+6c4x3RnyLNC+zqHuM4U1szsQPkOxI5zqItxVgy0HmLThpaA0knohTVYAnq+Qhw+iA6yokRv/pBRTr9fPeUv03LBB5tYEhBDCkGICY4ZRuT+NlsBHMxAjeQIIYeOh0DwldEl2QXVJc3eNt5nkQw49BoCGIU= dmartini@Davids-MacBook-Pro"
groups = ["wheel"]

EOF
```

4. Add new blueprint to image builder
```
sudo composer-cli blueprints push rhde_4.16_v1_blueprint.toml
sudo composer-cli blueprints list
sudo composer-cli blueprints depsolve RHDE_4_16_v1 | grep microshift
```

5. Build RHDE image
```
BUILDID=$(sudo composer-cli compose start-ostree --ref "rhel/9/$(uname -m)/edge" RHDE_4_16_v1 edge-container | awk '{print $2}')
sudo composer-cli compose status
```

6. Dowload container image 
```
sudo composer-cli compose image ${BUILDID}
```

7. Change image permissions and load it in podman
```
sudo chown $(whoami). ${BUILDID}-container.tar
sudo chmod a+r ${BUILDID}-container.tar
IMAGEID=$(cat < "./${BUILDID}-container.tar" | sudo podman load | grep -o -P '(?<=sha256[@:])[a-z0-9]*')
echo $IMAGEID
```

8. Run new imported image with podman
```
sudo podman run -d --name=minimal-microshift-server -p 8085:8080 ${IMAGEID}
podman ps
```

9. Generate the installer blueprint
```
cat > microshift-installer.toml <<EOF
name = "microshift-installer"

description = ""
version = "0.0.0"
modules = []
groups = []
packages = []
EOF
```

10. Add installer blueprint to image builder
```
sudo composer-cli blueprints push microshift-installer.toml
```

11. Build installer image from podman runing image
```
BUILDID=$(sudo composer-cli compose start-ostree --url http://localhost:8085/repo/ --ref "rhel/9/$(uname -m)/edge" microshift-installer edge-installer | awk '{print $2}')
sudo composer-cli compose status
```

12. Download and change image permissions
```
sudo composer-cli compose image ${BUILDID}
sudo chown $(whoami). ${BUILDID}-installer.iso
sudo chmod a+r ${BUILDID}-installer.iso
```