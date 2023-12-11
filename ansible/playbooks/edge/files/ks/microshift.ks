# Partition disk such that it contains an LVM volume group called `rhel` with a
# 10GB+ system root but leaving free space for the LVMS CSI driver for storing data.
#
# For example, a 20GB disk would be partitioned in the following way:
#
# NAME          MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
# sda             8:0    0  20G  0 disk
# ├─sda1          8:1    0 200M  0 part /boot/efi
# ├─sda1          8:1    0 800M  0 part /boot
# └─sda2          8:2    0  19G  0 part
#  └─rhel-root  253:0    0  10G  0 lvm  /sysroot
#


# Configure network to use DHCP and activate on boot
network --bootproto=dhcp --activate --onboot=on --hostname=microshift --noipv6

# Storage configuration
ostreesetup --nogpg --osname=rhel --remote=edge --url="file:///run/install/repo/ostree/repo" --ref="rhel/9/x86_64/edge"
zerombr
clearpart --all --initlabel
part /boot/efi --fstype=efi --size=200
part /boot --fstype=xfs --asprimary --size=800
# Uncomment this line to add a SWAP partition of the recommended size
#part swap --fstype=swap --recommended
part pv.01 --grow
volgroup rhel pv.01
logvol / --vgname=rhel --fstype=xfs --size=10000 --name=root



%post --log=/var/log/anaconda/post-install.log --erroronfail

# Add edge user to sudoers
echo -e 'edge\tALL=(ALL)\tPASSWD: ALL' > /etc/sudoers.d/microshift

# Add the pull secret to CRI-O and set root user-only read/write permissions
cat > /etc/crio/openshift-pull-secret << EOF
{"auths":{"cloud.openshift.com":{"auth":"b3BlbnNoaWZ0LXJlbGVhc2UtZGV2K29jbV9hY2Nlc3NfM2JhYTEyYWE1ODVjNDI3YTlmNmY3NTRhYWY3YjRjZDc6RVE2VlBISVpCSzMzQjlXQ0xVOVNWUldBNU1VMUIzR1lRRzVLVlkzTExYSkNKSFE4Q0E5T0hJVkgzUTE4TDlNVA==","email":"dmartini@redhat.com"},"quay.io":{"auth":"b3BlbnNoaWZ0LXJlbGVhc2UtZGV2K29jbV9hY2Nlc3NfM2JhYTEyYWE1ODVjNDI3YTlmNmY3NTRhYWY3YjRjZDc6RVE2VlBISVpCSzMzQjlXQ0xVOVNWUldBNU1VMUIzR1lRRzVLVlkzTExYSkNKSFE4Q0E5T0hJVkgzUTE4TDlNVA==","email":"dmartini@redhat.com"},"registry.connect.redhat.com":{"auth":"fHVoYy1wb29sLTc1MjQwMjQ4LTdlNWQtNGQ1YS1iYWM3LWQ5NGQ4YjBiZTQyMjpleUpoYkdjaU9pSlNVelV4TWlKOS5leUp6ZFdJaU9pSmlOakF3T1dWalltSTVZak0wTmpGa09ESXdNbUk1TkRFek1qY3daV1ZtTXlKOS5ybFRybndVTWl6NzUtRDZTZEZ4cnBJSUZ1SkJxdmh0elA0Wkt4OWhIUHg2VWtZYUJJTU4tWHRhWTFVbmRCX0xWX3Vqdm41ajlnQmt5RW9oNXNiYS1LaW9wZjl3RWxkNnMwUXlybm1qaDJhSlptNC1tU0lUQkNyOUtKa0pEMWNieU5yUDZnNXlFQW1PeW0yUnYydWI5b3UzTHdBQWttMVplUTgtX0ZlNno2ODZ5bTJfall6WlVncDE3cnZ4dHEza1dsb3hBZ0w1dkk3WWVMY2JHVkEzUWJQdlA4VFF3TWV4UnI5NWg3Q3RBTWdpNTNqSWZWWlFsaXBUYVFnSWRpRG1jNWkwcHFuaGlaemVKRUpYR2xzMThXUTlDazJrWkdGM1AwVXdiZlJIWm04SEhfWFBNMG90bUk3cFFTTjhuZ0wtbTV1T0FFX1BQeG01YjJTRkQ1c2ZocWxJN1N1SVFqVjNXZ0tRN3A5dFlva0ZLSS1EdGNGWFdIN2dOMEhfeE5iMWh2aVRjeUh0RFlEUnM3Y2QxeGtUQXF1a1RkT0ZOTE9lS0l5WldUd2d4aERvVGN6Z0tRNkVxcGxyR25mTjdnNk5DWms3ZE5FQVgyT3J6OWZQMkVzMEZxWkR4U0NhWk1yMFg0TkpiQTRwcUcxdThkbm91V0JvYVJZOFY1Q2JPT19QX0FMRG1sX0dPSDUyV1hfRURzLTZXWU5reWlpS2JSZ2FKOTZEazlKNWg4T2FQUS1aOWlzWlZpbTVKVEg0STJDaVVESlF3UGRrMlhvNDR3ZHFWX3BMRFFiVjEtT1N2Q1NKSEZkdE5SbDFfQm5oMnJ3aFNxWGhQYlhpN2Zvb3d4M0E3ejhLY19RSXB3MGhaUnAzRURmTmJpVmlTQmU2NnY3SmZBaUZYZkR4d3FmTQ==","email":"dmartini@redhat.com"},"registry.redhat.io":{"auth":"fHVoYy1wb29sLTc1MjQwMjQ4LTdlNWQtNGQ1YS1iYWM3LWQ5NGQ4YjBiZTQyMjpleUpoYkdjaU9pSlNVelV4TWlKOS5leUp6ZFdJaU9pSmlOakF3T1dWalltSTVZak0wTmpGa09ESXdNbUk1TkRFek1qY3daV1ZtTXlKOS5ybFRybndVTWl6NzUtRDZTZEZ4cnBJSUZ1SkJxdmh0elA0Wkt4OWhIUHg2VWtZYUJJTU4tWHRhWTFVbmRCX0xWX3Vqdm41ajlnQmt5RW9oNXNiYS1LaW9wZjl3RWxkNnMwUXlybm1qaDJhSlptNC1tU0lUQkNyOUtKa0pEMWNieU5yUDZnNXlFQW1PeW0yUnYydWI5b3UzTHdBQWttMVplUTgtX0ZlNno2ODZ5bTJfall6WlVncDE3cnZ4dHEza1dsb3hBZ0w1dkk3WWVMY2JHVkEzUWJQdlA4VFF3TWV4UnI5NWg3Q3RBTWdpNTNqSWZWWlFsaXBUYVFnSWRpRG1jNWkwcHFuaGlaemVKRUpYR2xzMThXUTlDazJrWkdGM1AwVXdiZlJIWm04SEhfWFBNMG90bUk3cFFTTjhuZ0wtbTV1T0FFX1BQeG01YjJTRkQ1c2ZocWxJN1N1SVFqVjNXZ0tRN3A5dFlva0ZLSS1EdGNGWFdIN2dOMEhfeE5iMWh2aVRjeUh0RFlEUnM3Y2QxeGtUQXF1a1RkT0ZOTE9lS0l5WldUd2d4aERvVGN6Z0tRNkVxcGxyR25mTjdnNk5DWms3ZE5FQVgyT3J6OWZQMkVzMEZxWkR4U0NhWk1yMFg0TkpiQTRwcUcxdThkbm91V0JvYVJZOFY1Q2JPT19QX0FMRG1sX0dPSDUyV1hfRURzLTZXWU5reWlpS2JSZ2FKOTZEazlKNWg4T2FQUS1aOWlzWlZpbTVKVEg0STJDaVVESlF3UGRrMlhvNDR3ZHFWX3BMRFFiVjEtT1N2Q1NKSEZkdE5SbDFfQm5oMnJ3aFNxWGhQYlhpN2Zvb3d4M0E3ejhLY19RSXB3MGhaUnAzRURmTmJpVmlTQmU2NnY3SmZBaUZYZkR4d3FmTQ==","email":"dmartini@redhat.com"}}}
EOF
chmod 600 /etc/crio/openshift-pull-secret

# Configure the firewall with the mandatory rules for MicroShift
firewall-offline-cmd --zone=trusted --add-source=10.42.0.0/16
firewall-offline-cmd --zone=trusted --add-source=169.254.169.1

%end