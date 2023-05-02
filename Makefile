H=$(shell hostname)
TMPDIR=/var/tmp
CONTAINER_NAME=go-ipfs_ipfs_1

default: start stats status doc

all: start enable-cors status stats log

Oliviers-Mac-mini.local: go-ipfs start enable-cors log


stats.dht:
	docker exec -it $(CONTAINER_NAME) ipfs stats dht

stats:
	@docker ps | grep $(CONTAINER_NAME)
	@# at 1st run, type: docker run -it go-ipfs:latest ipfs init

status:
	@echo #print status of local ipfs node

# should be replaced with a "build:" within docker-compose.yml file if applicable
go-ipfs:
	docker image list go-ipfs.*latest | egrep "^go-ipfs:latest" || (  \
        cd $(TMPDIR)	;\
        echo using TMPDIR=$(TMPDIR)	;\
	git clone git@github.com:ipfs/go-ipfs.git --branch v0.10.0-rc1 --single-branch --depth 1;\
	cd go-ipfs; \
	git checkout v0.10.0-rc1 ; \
 	docker image list | egrep ^go-ipfs  -q || docker build -t go-ipfs:latest . ;\
	cp ~/i/ipfs/docker-compose.yml .;  \
	:; )
	#rm -rf ../go-ipfs)


cors: enable-cors

enable-cors:
	docker exec -it $(CONTAINER_NAME) ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["http://127.0.0.1:5002", "http://localhost:3000", "http://127.0.0.1:5001", "https://webui.ipfs.io"]'
	docker exec -it $(CONTAINER_NAME) ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["PUT", "POST"]'
start:

	docker-compose up -d
stop:
	docker-compose down --remove-orphans 
	docker rm /go-ipfs_ipfs_1 -f
log:
	docker logs -f $(CONTAINER_NAME)

doc:
	@#echo_doc # at 1st run, type: docker run -it go-ipfs:latest ipfs init
	@clear
	@egrep -A 1 '^[a-zA-Z]*:' Makefile | egrep -v '\-\-' | tr  -d ':' 
