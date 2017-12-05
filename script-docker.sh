#!/bin/sh

imageConfigService="springio/config-service"
configApp="config_service"
docker stop "$configApp" || true
docker rm "$configApp" || true
docker rmi "$imageConfigService" || true
cd ./config-service/
./mvnw install dockerfile:build
cd ..

imageDiscoveryService="springio/discovery-service"
discoveryApp="discovery_service"
docker stop "$discoveryApp" || true
docker rm "$discoveryApp" || true
docker rmi "$imageDiscoveryService" || true
cd ./discovery-service/
./mvnw install dockerfile:build
#docker run --name "$discoveryApp" -d -p 8761:8761 -t "$imageDiscoveryService"

cd ..

imageProductService="springio/product-service"
instance1="product_service_1"
instance2="product_service_2"
instance3="product_service_3"
docker stop "$instance1" || true 
docker stop "$instance2" || true 
docker stop "$instance3" || true 
docker rm "$instance1" || true
docker rm "$instance2" || true 
docker rm "$instance3" || true

docker rmi "$imageProductService" || true



cd ./product-service
./mvnw install dockerfile:build


docker run --name discovery_service --link config_service -d -p 8761:8761 -t springio/discovery-service
#docker run --name "$instance1" --link "$discoveryApp" -d -p 4200:8080 -t "$imageProductService"
#docker run --name "$instance1" -d -p 4200:8080 -t "$imageProductService"
#docker run --name "$instance2" -d -p 4201:8080 -t "$imageProductService"
#docker run --name "$instance3" -d -p 4202:8080 -t "$imageProductService"


