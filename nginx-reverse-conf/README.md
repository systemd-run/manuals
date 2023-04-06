some nginx config for reverse proxy

### websocket reverse
for enabling websocket reverse need to add

`map $http_upgrade $connection_upgrade` to nginx.conf
look at [nginx.conf](https://github.com/systemd-run/manuals/blob/a8bb3d7fdcfb54bca84404100e01e251ec9c7f42/nginx-reverse-conf/nginx.conf#L65)

everything else you need is in 
`reverse-rpc-ws.conf`
