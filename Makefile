TMPDIR=/var/tmp
CONTAINER_NAME=kubo_ipfs_1
KUBO_VERSION=v0.20.0-rc2

default: start stats status

all: start enable-cors status stats log
	
init:
	docker run -it kubo:custom init

start:
	docker-compose up -d || echo "maybe you should run make kubo.custom first ?"

doc:
	@clear
	@egrep -A 1 '^[a-zA-Z]*:' Makefile | egrep -v '\-\-' | tr  -d ':' 

stats.dht:
	docker exec -it $(CONTAINER_NAME) ipfs stats dht

stats:
	@docker ps | grep $(CONTAINER_NAME)

status:
	@echo #print status of local ipfs node


# should be replaced with a "build:" within docker-compose.yml file if applicable
kubo.custom:
	docker image list kubo.*custom | egrep "^kubo:custom" || (  \
        cd $(TMPDIR)	;\
        echo using TMPDIR=$(TMPDIR)	;\
	git clone git@github.com:ipfs/kubo.git --branch $(KUBO_VERSION) --single-branch --depth 1;\
	cd kubo; \
	git checkout $(KUBO_VERSION) ; \
 	docker image list | egrep ^kubo  -q || docker build -t kubo:custom . ;\
	cp ~/i/ipfs/docker-compose.yml .;  \
	:; )
	#rm -rf ../kubo)


cors: enable-cors

enable-cors:
	docker exec -it $(CONTAINER_NAME) ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["http://127.0.0.1:5002", "http://localhost:3000", "http://127.0.0.1:5001", "https://webui.ipfs.io"]'
	docker exec -it $(CONTAINER_NAME) ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["PUT", "POST"]'
stop:
	docker-compose down --remove-orphans 
	docker rm /kubo_ipfs_1 -f
log:
	docker logs -f $(CONTAINER_NAME)

