# Red Hat Device Edge and MicroShift


## Add needed repositories

'''
cat > rhocp-4.14.toml <<EOF
id = "rhocp-4.14"
name = "Red Hat OpenShift Container Platform 4.14 for RHEL 9"
type = "yum-baseurl"
url = "https://cdn.redhat.com/content/dist/layered/rhel9/$(uname -m)/rhocp/4.14/os"
check_gpg = true
check_ssl = true
system = false
rhsm = true
EOF
'''

'''
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
'''