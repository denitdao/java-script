package com.denitdao.learn.javascript;

import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

// mvn -DskipTests -Pnative native:compile
@Slf4j
@SpringBootApplication
public class Main implements CommandLineRunner {

    private final ExecutorService executor = Executors.newVirtualThreadPerTaskExecutor();

    public static void main(String[] args) {
        SpringApplication.run(Main.class, args);
    }

    @Override
    public void run(String... args) {
        log.info("Running application with threads.");

        List<Future<Integer>> futures = new ArrayList<>(1000);

        for (int i = 1; i <= 1000; i++) {
            int fi = i;
            futures.add(executor.submit(() -> fi * fi));
        }

        int sum = futures.stream().mapToInt(future -> hideExceptions(future::get)).sum();


        log.info("Sum of squares: {}", sum);
    }

    private <T> T hideExceptions(Callable<T> callable) {
        try {
            return callable.call();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
