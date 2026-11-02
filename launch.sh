#!/bin/bash
cd /var/
echo "Hello, World" > index.html
%{ for port in var.server_ports }
nohup python3 -m http.server ${port} > /var/python-server-${port}.log 2>&1 &
%{ endfor }
