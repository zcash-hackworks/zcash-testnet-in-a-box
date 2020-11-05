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
? Choose the git resource to use for source:  [Use arrows to move, type to filter]
> zcash (https://github.com/zcash/zcash.git#v4.1.0)
  create new "git" resource
? Value for param `JOBS` of type `string`? (Default is `8`) 8
? Value for param `ipfs-api-service` of type `string`? (Default is `/dns/ipfs-cache/tcp/5001`) /dns/ipfs-cache/tcp/5001
? Value for param `TNBOX_SCRIPT_CID` of type `string`? (Default is `QmdcXSthqb89VF3CwtFXYHiSVZTCrggWPsDzyFSs69Cezg`) QmdcXSthqb89VF3CwtFXYHiSVZTCrggWPsDzyFSs69Cezg
TaskRun started: zcashd-build-tnb-run-zfxmd
```


## Follow the task to completion

Watch either the pod logs or task status on the Tekton dashboard.

```
tkn taskrun logs zcashd-build-tnb-run-zfxmd -f -n default
```
Prodcues output like:
```
