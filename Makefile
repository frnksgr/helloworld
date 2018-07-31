
src = main.go
image = docker.io/frnksgr/helloworld
cf-domain = bosh-lite.com
k8s-namespace = hello
k8s-domain = hello.example.com

helloworld: $(src)
	go build .
	@echo to run: PORT=4711 ./helloworld
	@echo to call: curl http://localhost:4711/

docker-build: Dockerfile $(src)
	docker build -t $(image) .
	@echo to run: docker run -p 4711:8080 $($image)
	@echo to call: curl http://localhost:4711/

docker-push: # docker-build
	docker push $(image)

cf-push-buildpack: 
	cf push -f config/cf/manifest-bp.yml helloworld-bp
	@echo to call: curl http://$(cf-domain)/helloworld-bp/

cf-push-containerimage:
	cf push -f config/cf/manifest-ci.yml helloworld-ci
	@echo to call: curl http://$($cf-domain)/helloworld-ci/

k8s-namespace:
	@if ! kubectl get ns $(k8s-namespace); then \
		kubectl create namespace $(k8s-namespace); \
	fi

k8s-deploy: k8s-namespace
	kubectl apply -f config/k8s/sample.yml
	@echo to call: todo ...