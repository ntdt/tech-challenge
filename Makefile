pwd := $(shell pwd)
worker_count:=2
.PHONY: build
build:
	DOCKER_BUILDKIT=1 docker build -t ntdt/tech-challenge . && docker push ntdt/tech-challenge

.PHONY: run
run:
	docker run -ti --rm --mount type=bind,src=$(pwd)/ds,dst=/data --mount type=bind,src=$(pwd)/out,dst=/output tech-challenge

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
