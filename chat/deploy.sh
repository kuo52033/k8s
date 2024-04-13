#!/bin/bash -xe

# declare
NAMESPACE="chat"
WAIT_RESOURCE_CREATION_IN_SEC=300
YAML_DIR_PATH="/home/ubuntu/chat"

applyNamespace() {
	echo "[INFO] apply $NAMESPACE namespace..."

	kubectl apply -f $YAML_DIR_PATH/namespace.yaml

	echo "[INFO] apply $NAMESPACE namespace done"
}

applyChatService() {
	echo "[INFO] apply chat-deployment service ..."

	kubectl apply -f $YAML_DIR_PATH/chat.deploy.yaml

	timeout $WAIT_RESOURCE_CREATION_IN_SEC  kubectl rollout status deploy chat-deployment -w --namespace $NAMESPACE

	echo "[INFO] apply chat-deployment service done"
}

applyNginxIngressController() {
	echo "[INFO] apply nginx-ingress-controller..."

	kubectl apply -f $YAML_DIR_PATH/nginx-ingress-controller.yaml
	timeout $WAIT_RESOURCE_CREATION_IN_SEC kubectl rollout status deploy ingress-nginx-controller -w --namespace ingress-nginx

	echo "[INFO] apply nginx-ingress-controller done"
}

applyRedisService() {
	echo "[INFO] apply redis service..."

	kubectl apply -f $YAML_DIR_PATH/redis.deploy.yaml

	timeout $WAIT_RESOURCE_CREATION_IN_SEC  kubectl rollout status deploy redis -w --namespace $NAMESPACE

	echo "[INFO] apply redis service done"
}

# exit when any command failed
set -e
set -o pipefail

# main
applyNamespace
applyNginxIngressController
applyRedisService
applyChatService

exit 0
