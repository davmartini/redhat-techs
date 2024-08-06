# Use S3 bucket avec Noobaa

1. Install noobaa CLI on mac  
`# brew install noobaa/noobaa/noobaa` 

2. Export Kube env  
`# export KUBECONFIG="/Users/dmartini/Google Drive/Labs/OCP/auth/kubeconfig"`  

3. Check noobaa service status  
`# noobaa status -n openshift-storage` 

4. Check existing OBC  
`# oc get obc -n openshift-storage` 

5. Create a bucket with noobaa CLI  
`# noobaa obc create $BUCKET_NAME -n openshift-storage`  

6. List bucket with noobaa CLI  
`# noobaa obc list`  

7. Create a S3 alias for AWS CLI  
`# alias s3='AWS_ACCESS_KEY_ID=$AK AWS_SECRET_ACCESS_KEY=$SK aws --endpoint $NOOBAA_ENDPOINT --no-verify-ssl s3'`  

8. Copy a file in a bucket with AWS CLI  
`# s3 cp $LOCAL_FILE s3://$BUCKET_NAME/`  

9. Delete a file in a bucket with AWS CLI  
`# s3 rm s3://$BUCKET_NAME/$FILE`  
