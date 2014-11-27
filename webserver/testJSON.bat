set curl=D:\curl\curl-7.29.0-rtmp-ssh2-ssl-sspi-zlib-idn-static-bin-w32\curl

curl -vX POST http://localhost:9090/json -d @data.json --header "Content-Type: application/json"