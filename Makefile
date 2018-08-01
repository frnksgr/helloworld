
src = main.go
image = docker.io/frnksgr/helloworld
cf-domain = bosh-lite.com
k8s-namespace = hello
k8s-domain = default.example.com
knative-gw := $(shell kubectl -n istio-system get svc knative-ingressgateway \
  -o jsonpath="{.status.loadBalancer.ingress[0].ip}") 
nginx-gw := $(shell kubectl -n nginx get svc nginx-ingress-controller \
  -o jsonpath="{.status.loadBalancer.ingress[0].ip}")

go-build: $(src)
	go build .
	@echo to run: FROM=commandline PORT=4711 ./helloworld
	@echo to call: curl http://localhost:4711/

docker-build: Dockerfile $(src)
	docker build -t $(image) .
	@echo to run: docker run -e FROM=docker-container -p 4711:8080 $($image)
	@echo to call: curl http://localhost:4711/

docker-push: # docker-build
	docker push $(image)

docker-build-cf: Dockerfile $(src)
	docker build -t $(image)-cf --build-arg BASEIMAGE=alpine .
	@echo to run: docker run -e FROM=docker-container-cf -p 4711:8080 $($image)-cf
	@echo to call: curl http://localhost:4711/

docker-push-cf: # docker-build-cf
	docker push $(image)-cf

cf-push-buildpack: 
	cf push -f config/cf/manifest-bp.yml helloworld-bp
	@echo to call: curl http://helloworld-bp.$(cf-domain)/

cf-push-containerimage:
	cf push -f config/cf/manifest-ci.yml helloworld-ci
	@echo to call: curl http://helloworld-ci.$(cf-domain)/

k8s-deploy: 
	kubectl apply -f config/k8s/sample.yml
	@echo to call: curl -H \"Host: helloworld.$(k8s-domain)\" $(nginx-gw) 

knative-deploy: 
	kubectl apply -f config/knative/sample.yml
	@echo to call: curl -H \"Host: helloworld-kn.$(k8s-domain)\" $(knative-gw) 

knative-deploy-dockerfile: 
	kubectl apply -f config/knative/sample-dockerfile.yml
	@echo to call: curl -H \"Host: helloworld-kn-df.$(k8s-domain)\" $(knative-gw) 

knative-deploy-buildpack: 
	kubectl apply -f config/knative/sample-buildpack.yml
	@echo to call: curl -H \"Host: helloworld-kn-bp.$(k8s-domain)\" $(knative-gw) 
