pwd := $(shell pwd)
worker_count:=2
.PHONY: build
build:
	DOCKER_BUILDKIT=1 docker build -t ntdt/tech-challenge . && docker push ntdt/tech-challenge

.PHONY: run
test-image:
	docker run -ti --rm --mount type=bind,src=$(pwd)/ds,dst=/dataset --mount type=bind,src=$(pwd)/out,dst=/output tech-challenge

.PHONY: init plan apply upload download ssh
init:
	terraform init

plan:
	terraform plan -out tfplan.out

apply:
	terraform apply tfplan.out

upload:
	$(shell terraform output rsync_upload_cmd)

download:
	$(shell terraform output rsync_download_cmd)

ssh:
	$(shell terraform output  ssh_connection_string)

install_csi:
	$(shell kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master")

run:
	$(shell kubectl apply -f specs)

.PHONY: prepare_prometheus prometheus
prepare_prometheus:
	kubectl create namespace prometheus
	helm repo add stable https://kubernetes-charts.storage.googleapis.com/
	helm repo update

prometheus:
	helm install prometheus stable/prometheus \
	    --namespace prometheus \
	    --set alertmanager.persistentVolume.storageClass="gp2",server.persistentVolume.storageClass="gp2"

dashboard:
	kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.6/components.yaml
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml

logging:
	kubectl apply -f logging
