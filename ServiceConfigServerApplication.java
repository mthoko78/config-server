package za.co.frg.hr.integration.service.config.server;

import org.slf4j.MDC;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.config.server.EnableConfigServer;

import java.io.BufferedReader;
import java.io.InputStreamReader;

import lombok.SneakyThrows;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@EnableConfigServer
@SpringBootApplication
public class ServiceConfigServerApplication {
    
    public static void main(String[] args) {
        addLinuxUserToLogs();
        SpringApplication.run(ServiceConfigServerApplication.class, args);
    }

    @SneakyThrows
    private static void addLinuxUserToLogs() {
        try {
            var proc = Runtime.getRuntime().exec("whoami");
            var stdin = new BufferedReader(new InputStreamReader(proc.getInputStream()));
            var username = stdin.readLine();

            log.info("Running service with Linux user: {}", username);
            MDC.put("linux-user", username);
        } catch (Exception e) {
            log.warn("Could not determine Linux user");
        }
    }

}
