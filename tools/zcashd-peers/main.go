/*
Copyright 2016 The Kubernetes Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

// Note: the example only works with the code within the same release/branch.
package main

import (
	"encoding/base64"
	"flag"
	"fmt"
	"os"
	"time"

	"github.com/ybbus/jsonrpc"
	"k8s.io/apimachinery/pkg/api/errors"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
	//
	// Uncomment to load all auth plugins
	// _ "k8s.io/client-go/plugin/pkg/client/auth"
	//
	// Or uncomment to load specific auth plugins
	// _ "k8s.io/client-go/plugin/pkg/client/auth/azure"
	// _ "k8s.io/client-go/plugin/pkg/client/auth/gcp"
	// _ "k8s.io/client-go/plugin/pkg/client/auth/oidc"
	// _ "k8s.io/client-go/plugin/pkg/client/auth/openstack"
)

const labelName = "app"
const labelValue = "zcash-with-exporter"
const namespace = "default"
const configMapName = "zcashd-testnet-miner-config"
const rpcSecretName = "zcashd-rpc"

func main() {
	versionFlag := flag.Bool("version", false, "print version information")
	flag.Parse()
	if *versionFlag {
		fmt.Printf("(version=%s, branch=%s, gitcommit=%s)\n", Version, Branch, GitCommit)
		fmt.Printf("(go=%s, user=%s, date=%s)\n", GoVersion, BuildUser, BuildDate)
		os.Exit(0)
	}
	fmt.Printf("(version=%s, branch=%s, gitcommit=%s)\n", Version, Branch, GitCommit)
	fmt.Printf("(go=%s, user=%s, date=%s)\n", GoVersion, BuildUser, BuildDate)
	// creates the in-cluster config
	config, err := rest.InClusterConfig()
	if err != nil {
		panic(err.Error())
	}
	// creates the clientset
	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		panic(err.Error())
	}
	configMap, err := clientset.CoreV1().ConfigMaps(namespace).Get(configMapName, metav1.GetOptions{})
	if err != nil {
		panic(err.Error())
	}
	secret, err := clientset.CoreV1().Secrets(namespace).Get(rpcSecretName, metav1.GetOptions{})
	if err != nil {
		panic(err.Error())
	}
	rpcUser := configMap.Data["ZCASHD_RPCUSER"]
	rpcPort := configMap.Data["ZCASHD_RPCPORT"]
	rpcPassword := secret.Data["password"]

	for {
		pods, err := clientset.CoreV1().Pods("").List(metav1.ListOptions{})
		if err != nil {
			panic(err.Error())
		}
		fmt.Printf("There are %d pods in the cluster\n", len(pods.Items))

		zcashPeersPods, err := clientset.CoreV1().Pods("default").List(metav1.ListOptions{LabelSelector: labelName + "=" + labelValue})
		if errors.IsNotFound(err) {
			fmt.Printf("zcashPeersPods not found in default namespace\n")
		} else if statusError, isStatus := err.(*errors.StatusError); isStatus {
			fmt.Printf("Error getting zcashPeersPods %v\n", statusError.ErrStatus.Message)
		} else if err != nil {
			panic(err.Error())
		} else {
			var currentIPs []string
			for _, pod := range zcashPeersPods.Items {
				currentIPs = append(currentIPs, pod.Status.PodIP)
			}
			for _, pod := range zcashPeersPods.Items {
				fmt.Printf("RPCUSER: %s, RPCPASSWORD: %s\n", rpcUser, string(rpcPassword))
				basicAuth := base64.StdEncoding.EncodeToString([]byte(rpcUser + ":" + string(rpcPassword)))
				rpcClient := jsonrpc.NewClientWithOpts("http://"+pod.Status.PodIP+":"+rpcPort,
					&jsonrpc.RPCClientOpts{
						CustomHeaders: map[string]string{
							"Authorization": "Basic " + basicAuth,
						}})
				var addNode map[string]interface{}
				for _, peerIP := range currentIPs {
					// Don't add this node as it's own peer
					if peerIP != pod.Status.PodIP {
						if err := rpcClient.CallFor(&addNode, "addnode", peerIP, "onetry"); err != nil {
							fmt.Printf("Error calling addnode for Pod %s: %s\n", pod.Status.PodIP, err)
						} else {
							fmt.Printf("Added peer IP %s to pod: %s\n", peerIP, pod.Status.PodIP)
						}
					}
				}
			}
		}
		fmt.Printf("This is the end\n")
		time.Sleep(60 * time.Second)
	}
}
