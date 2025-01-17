package com.example;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

/**
 * 启动类
 *
 * @author ThinkPad
 * @since 2025/1/16
 */
@SpringBootApplication
public class ApkSignerApplication extends SpringBootServletInitializer {

    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(ApkSignerApplication.class);
    }

    public static void main(String[] args) {
        SpringApplication.run(ApkSignerApplication.class, args);
    }
} 