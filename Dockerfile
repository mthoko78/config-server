FROM ibm-semeru-runtimes:open-17.0.4.1_1-jdk-jammy as builder
WORKDIR /build
ADD ./ ./
RUN jar xf ./target/*.jar

FROM ibm-semeru-runtimes:open-17.0.4.1_1-jre-jammy

EXPOSE 8081/tcp

ENV JAVA_OPTS=""

COPY --from=builder /build/BOOT-INF/lib          /app/lib/
COPY --from=builder /build/META-INF              /app/META-INF/
COPY --from=builder /build/BOOT-INF/classes      /app/

ENTRYPOINT ["sh", "-c", "java \
-cp app:app/lib/* \
${JAVA_OPTS} \
com.mthoko.service.config.server.ConfigService \
${0} \
${@}"]
