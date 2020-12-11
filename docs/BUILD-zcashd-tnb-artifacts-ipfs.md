# Building zcashd testnet in a box artifacts

The only change made to a "testnet in a box" artifacts is changing the network magic numbers defined in `chainparams.cpp` and the branchID in `upgrades.cpp`.

To produce a new build, the `tnbox.py` script included in this repo is run against a zcash git clone, then a normal build process is performed.

A Tekon task is included to automate the process.

## Make the script `tnbox.py` script available inside the box.

This is currently handled with an IPFS CID of the script in this repo, and is a variable in the Tekton task, you you can bring your own source modifying script.

## Create the tekton task for the tnb build

### Using `tkn`

The `zcashd-build-tnb` Task should already be deployed, we just need to create an instance of it

Make sure the task is available
```
$ tkn tasks list
NAME               DESCRIPTION   AGE
...
zcashd-build-tnb                 3 hours ago
```

Start a task  
If no git resources are defined, relax. You just need to provide a "friendly name", git clone url publicly available, and a git commit.  
For the rest of the prompts, the defaults should be fine.
```
$ tkn tasks start zcashd-build-tnb
Please create a new "git" resource for pipeline resource "source"
? Enter a name for a pipeline resource : zc
? Enter a value for url :  https://github.com/zcash/zcash.git
? Enter a value for revision :  v4.1.1
New git resource "zc" has been created
? Value for param `JOBS` of type `string`? (Default is `8`) 8
? Value for param `ipfs-api-service` of type `string`? (Default is `/dns/ipfs-cache/tcp/5001`) /dns/ipfs-cache/tcp/5001
? Value for param `TNBOX_SCRIPT_CID` of type `string`? (Default is `QmdcXSthqb89VF3CwtFXYHiSVZTCrggWPsDzyFSs69Cezg`) QmdcXSthqb89VF3CwtFXYHiSVZTCrggWPsDzyFSs69Cezg
Taskrun started: zcashd-build-tnb-run-jxbhsIn order to track the taskrun progress run:
tkn taskrun logs zcashd-build-tnb-run-jxbhs -f -n default
```


## Follow the task to completion

Watch either the pod logs or task status on the Tekton dashboard.

```
tkn taskrun logs zcashd-build-tnb-run-zfxmd -f -n default
```
Produces output like:
```
build-with-new-magic-numbers] make[2]: Leaving directory '/workspace/source/src'
[build-with-new-magic-numbers] make[1]: Leaving directory '/workspace/source/src'
[build-with-new-magic-numbers] Making all in doc/man
[build-with-new-magic-numbers] make[1]: Entering directory '/workspace/source/doc/man'
[build-with-new-magic-numbers] make[1]: Nothing to be done for 'all'.
[build-with-new-magic-numbers] make[1]: Leaving directory '/workspace/source/doc/man'
[build-with-new-magic-numbers] make[1]: Entering directory '/workspace/source'
[build-with-new-magic-numbers] make[1]: Nothing to be done for 'all-am'.
[build-with-new-magic-numbers] make[1]: Leaving directory '/workspace/source'
[build-with-new-magic-numbers] + tar --strip-components 3 -zvcf ./zcashd-tnb-artifacts-.tgz /workspace/source/src/zcashd /workspace/source/src/zcash-cli /workspace/source/src/zcash-gtest /workspace/source/src/zcash-tx
[build-with-new-magic-numbers] /workspace/source/src/zcashd
[build-with-new-magic-numbers] tar: Removing leading `/' from member names
[build-with-new-magic-numbers] /workspace/source/src/zcash-cli
[build-with-new-magic-numbers] tar: Removing leading `/' from hard link targets
[build-with-new-magic-numbers] /workspace/source/src/zcash-gtest
[build-with-new-magic-numbers] /workspace/source/src/zcash-tx
[build-with-new-magic-numbers] + ipfs --api /dns/ipfs-cache/tcp/5001 add --quieter ./zcashd-tnb-artifacts-.tgz
[build-with-new-magic-numbers] + tee /tekton/results/PIN_ADDED
[build-with-new-magic-numbers] QmTu6kgWwSS8CjzYJUoQJ79sytF7QQcQC9J3gkaQdwJe2d
```
To retrieve this bundle to update local configmap CIDs:
```
ipfs --api=/ip4/127.0.0.1/tcp/5002 get /ipfs/QmTu6kgWwSS8CjzYJUoQJ79sytF7QQcQC9J3gkaQdwJe2d -o zcashd-tnb-artifacts-<insertshortsha>.tgz
```
