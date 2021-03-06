
src = main.go
image = docker.io/frnksgr/helloworld
cf-domain = sys.cf.frnksgr.net
k8s-domain = default.example.com
knative-gw=$(shell scripts/get-gateway.sh istio-system istio-ingressgateway)
nginx-gw=$(shell scripts/get-gateway.sh nginx nginx-ingress-controller)

# wow, simple self documenting makefile
# see https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.DEFAULT_GOAL := help
.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

go-build: $(src) ## build local
	go build .
	@echo to run: FROM=commandline PORT=4711 ./helloworld
	@echo to call: curl http://localhost:4711/

docker-build: Dockerfile.docker $(src) ## build default docker image
	docker build -t $(image) -f Dockerfile.docker .
	@echo to run: docker run -e FROM=docker-container -p 4711:8080 $($image)
	@echo to call: curl http://localhost:4711/

.PHONY: docker-push
docker-push: ## push default docker image to repo
	docker push $(image)

docker-build-cf: Dockerfile.docker $(src) ## build cf docker image
	docker build -t $(image)-cf --build-arg BASEIMAGE=alpine -f Dockerfile.docker .
	@echo to run: docker run -e FROM=docker-container-cf -p 4711:8080 $($image)-cf
	@echo to call: curl http://localhost:4711/

.PHONY: docker-push-cf
docker-push-cf: ## push cf docker image to repo
	docker push $(image)-cf

.PHONY: cf-push-buildpack
cf-push-buildpack: ## push to cloud foundry using CF buildpack
	cf push -f config/cf/manifest-bp.yml helloworld-bp
	@echo to call: curl http://helloworld-bp.$(cf-domain)/

.PHONY: cf-push-containerimage
cf-push-containerimage: ## push to cloud foundry using docker image
	cf push -f config/cf/manifest-ci.yml helloworld-ci 
	@echo to call: curl http://helloworld-ci.$(cf-domain)/

#appengine-deploy: ## deploy to google appengine
#	gcp app deploy --image-url=docker.io/frnksgr/helloworld-cf

.PHONY: k8s-deploy
k8s-deploy: ## deploy to k8s with ingress
	kubectl apply -f config/k8s/sample.yml
	@echo to call: curl -H \"Host: helloworld.$(k8s-domain)\" http://$(nginx-gw)/

.PHONY: knative-deploy
knative-deploy: ## deploy to knative without build
	kubectl apply -f config/knative/sample.yml
	@echo to call: curl -H \"Host: helloworld-kn.$(k8s-domain)\" http://$(knative-gw)/

.PHONY: knative-deploy-dockerfile
knative-deploy-dockerfile: ## deploy to knative with Dockerfle based build
	kubectl apply -f config/knative/sample-dockerfile.yml
	@echo to call: curl -H \"Host: helloworld-kn-df.$(k8s-domain)\" http://$(knative-gw)/

.PHONY: knative-deploy-buildpack-cf
knative-deploy-buildpack-cf: ## deploy to knative with CF buildpack build
	kubectl apply -f config/knative/sample-buildpack-cf.yml
	@echo to call: curl -H \"Host: helloworld-kn-bp-cf.$(k8s-domain)\" http://$(knative-gw)/

.PHONY: knative-deploy-buildpack-cnb
knative-deploy-buildpack-cnb: ## deploy to knative with CNCF buildpack build
	@echo no golang support yet; exit 0
	kubectl apply -f config/knative/sample-buildpack-cnb.yml
	@echo to call: curl -H \"Host: helloworld-kn-bp-cnb.$(k8s-domain)\" http://$(knative-gw)/
