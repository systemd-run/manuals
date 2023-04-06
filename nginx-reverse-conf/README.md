some nginx config for reverse proxy

### websocket reverse
for enabling websocket reverse need to add

`map $http_upgrade $connection_upgrade` to nginx.conf

look at [nginx.conf](https://github.com/systemd-run/manuals/blob/a8bb3d7fdcfb54bca84404100e01e251ec9c7f42/nginx-reverse-conf/nginx.conf#L65)

everything else you need is in 
`reverse-rpc-ws.conf`

for testing use this tool 

[wscat](https://github.com/websockets/wscat/blob/master/bin/wscat)

ex: `wscat -c wss://host.ip/websocket` # ssl websocket in case of cosmos 

### gRPC reverse
 for grpc check use this tool
 
 [grpcurl](https://github.com/fullstorydev/grpcurl)
 
 ex: `grpcurl host.ip:443 list`
