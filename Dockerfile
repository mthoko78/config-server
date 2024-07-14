FROM docker.fnb.co.za/hc-integration/docker-images/ibm-semeru-runtimes:open-17.0.4.1_1-jdk-mvn-jammy as builder
WORKDIR /build
ADD ./ ./
RUN jar xf ./target/*.jar
RUN find ./ -type f -iname "*.sh" -exec chmod -v +x {} \;

FROM docker.fnb.co.za/hc-integration/docker-images/ibm-semeru-runtimes-with-certs:open-17.0.4.1_1-jre-jammy-with-certs

# Install git:

COPY --from=builder /build/.dependencies/deb-packages     /debs

RUN apt install /debs/*.deb --allow-downgrades -y && rm -R /debs

# Install certificates:

COPY --from=builder /build/.certificates                   /certificates

RUN original_directory=$(pwd) && cd /certificates && ./setup.sh && ./add-certs-to-java.sh || true && cd $original_directory

# Global git config:

RUN git config --system http.sslverify false

# Add user for application:

RUN addgroup spring && useradd -g spring spring
RUN mkdir /home/spring && chown -R spring /home/spring

# Add directories required by service and modes for directories:

RUN mkdir /logs && mkdir /logs/json && chmod 777 -R /logs
RUN mkdir /.config && mkdir /.config/jgit && chmod 777 -R /.config

# Service files and configuration:

EXPOSE 8081/tcp

ENV JAVA_OPTS=""
ENV JVM_OPTS=""

COPY --from=builder /build/BOOT-INF/lib          /app/lib/
COPY --from=builder /build/META-INF              /app/META-INF/
COPY --from=builder /build/BOOT-INF/classes      /app/

USER spring

# User git config:

RUN git config --global http.sslverify false

ENTRYPOINT ["sh", "-c", "echo 'JVM Memory Sizes:' && \
java \
${JVM_OPTS} \
-cp app:app/lib/* \
-verbose:sizes \
-noverify \
-Xtune:virtualized \
-Xquickstart \
-XX:+UseContainerSupport \
-XX:TieredStopAtLevel=1 \
-Dspring.backgroundpreinitializer.ignore=true \
-Dspring.jmx.enabled=false \
${JAVA_OPTS} \
com.mthoko.service.config.server.ServiceConfigServerApplication \
${0} \
${@}"]
