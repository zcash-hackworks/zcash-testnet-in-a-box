# Building zcashd testnet in a box artifacts

The only change made to a "testnet in a box" artifacts is changing the network magic numbers defined in `chainparams.cpp`.

To produce a new build, the `tnbox.py` script included in this repo is run against a zcash git clone, then a normal build process is performed.

A Tekon task is included to automate the process.

## Make the script `tnbox.py` script available inside the box.

Install the minio client https://min.io/download#/

### Get the minio admin secret
```
MINIO_SECRETACCESSKEY=$(kubectl get secrets minio-secret-key -o jsonpath="{.data.SECRETACCESSKEY}" | base64 -d)
```
### Configure mc client
```
mc config host add \
  zcash-testnet-in-a-box http://localhost:9000 minio $MINIO_SECRETACCESSKEY \
  --api S3v4
```
### Upload the script
```
mc cp ./tools/tnbox.py zcash-testnet-in-a-box/binaries/
```

## Create the tekton task for the tnb build

Edit `tekton/tasks/build-binary-tnb.yml` for the git version to build from.

Then run it:
```
kubectl create -f tekton/tasks/build-binary-tnb.yml
```

## Follow the task to completion

Watch either the pod logs or task status on the Tekton dashboard.

```
kubectl logs -l build=zcashd-tnb  -c step-upload-file
```
Prodcues output like:
```
2020/07/20 13:56:08 Skipping step because a previous step failed
Added `minio` successfully.
+ tar --strip-components 3 -zvcf ./zcashd-tnb-artifacts-d292376.tgz /workspace/source/src/zcashd /workspace/source/src/zcash-cli /workspace/source/src/zcash-gtest /workspace/source/src/zcash-tx
tar: removing leading '/' from member names
workspace/source/src/zcashd
workspace/source/src/zcash-cli
workspace/source/src/zcash-gtest
workspace/source/src/zcash-tx
+ mc cp ./zcashd-tnb-artifacts-d292376.tgz minio/binaries/
`zcashd-tnb-artifacts-d292376.tgz` -> `minio/binaries/zcashd-tnb-artifacts-d292376.tgz`
Total: 0 B, Transferred: 155.33 MiB, Speed: 378.84 MiB/s
```

The compiled archive will be uploaded to minio identified but the git commit hash build from.  
``zcashd-tnb-artifacts-d292376.tgz` -> `minio/binaries/zcashd-tnb-artifacts-d292376.tgz``