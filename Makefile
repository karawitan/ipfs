TMPDIR=/var/tmp
CONTAINER_NAME=go-ipfs_ipfs_1

default: start stats status doc

all: start enable-cors status stats log
	
init:
	docker run -it go-ipfs:custom init

start:
	docker-compose up -d || echo "maybe you should run make go-ipfs.custom first ?"

stats.dht:
	docker exec -it $(CONTAINER_NAME) ipfs stats dht

stats:
	@docker ps | grep $(CONTAINER_NAME)

status:
	@echo #print status of local ipfs node


# should be replaced with a "build:" within docker-compose.yml file if applicable
go-ipfs.custom:
	docker image list go-ipfs.*custom | egrep "^go-ipfs:custom" || (  \
        cd $(TMPDIR)	;\
        echo using TMPDIR=$(TMPDIR)	;\
	git clone git@github.com:ipfs/go-ipfs.git --branch v0.10.0-rc1 --single-branch --depth 1;\
	cd go-ipfs; \
	git checkout v0.10.0-rc1 ; \
 	docker image list | egrep ^go-ipfs  -q || docker build -t go-ipfs:custom . ;\
	cp ~/i/ipfs/docker-compose.yml .;  \
	:; )
	#rm -rf ../go-ipfs)


cors: enable-cors

enable-cors:
	docker exec -it $(CONTAINER_NAME) ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["http://127.0.0.1:5002", "http://localhost:3000", "http://127.0.0.1:5001", "https://webui.ipfs.io"]'
	docker exec -it $(CONTAINER_NAME) ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["PUT", "POST"]'
stop:
	docker-compose down --remove-orphans 
	docker rm /go-ipfs_ipfs_1 -f
log:
	docker logs -f $(CONTAINER_NAME)

doc:
	@clear
	@egrep -A 1 '^[a-zA-Z]*:' Makefile | egrep -v '\-\-' | tr  -d ':' 
