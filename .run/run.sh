mvn spring-boot:build image
podman run --name=config-service --network=host -p 8337:8337 docker.io/library/feds-config-service:1.0.0-SNAPSHOT