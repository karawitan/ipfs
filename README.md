
Steps to get a local ipfs node running

1. Build locally the go-ipfs image using version v0.10.0-rc1

make go-ipfs.custom

2. Review and update docker-compose.yml file (/Users/kalou should be replaced with your local home directory. /tmp/Downloads is inside the container)

3. Start the ipfs node

make start

4. Check logs

make log

To get the status of your local IPFS node;

http://127.0.0.1:5002/webui
