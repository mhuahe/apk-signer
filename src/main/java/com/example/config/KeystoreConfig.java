package com.example.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.HashMap;
import java.util.Map;

@Configuration
public class KeystoreConfig {
    
    @Bean
    @ConfigurationProperties(prefix = "keystore")
    public KeystoreProperties keystoreProperties() {
        return new KeystoreProperties();
    }
    
    public static class KeystoreProperties {
        private Map<String, String> password = new HashMap<>();
        private Map<String, String> alias = new HashMap<>();
        
        public Map<String, String> getPassword() {
            return password;
        }
        
        public void setPassword(Map<String, String> password) {
            this.password = password;
        }
        
        public Map<String, String> getAlias() {
            return alias;
        }
        
        public void setAlias(Map<String, String> alias) {
            this.alias = alias;
        }
    }
} 