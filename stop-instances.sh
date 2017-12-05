#!/bin/sh
imageDiscoveryService="springio/discovery-service"
discoveryApp="discovery_service"
docker stop "$discoveryApp" || true


imageProductService="springio/product-service"
instance1="product_service_1"
instance2="product_service_2"
instance3="product_service_3"
docker stop "$instance1" || true 
docker stop "$instance2" || true 
docker stop "$instance3" || true 