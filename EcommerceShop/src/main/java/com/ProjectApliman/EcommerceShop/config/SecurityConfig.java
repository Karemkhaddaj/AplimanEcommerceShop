package com.ProjectApliman.EcommerceShop.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.annotation.web.configurers.HeadersConfigurer;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf(AbstractHttpConfigurer::disable) // Disable CSRF for testing with Postman
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/user/**", "/users", "/item/**", "/items", "/invoice/**").permitAll() // ALLOW ALL REQUESTS
                        .anyRequest().permitAll() // Ensure all endpoints are open
                )
                .headers(headers -> headers.frameOptions(HeadersConfigurer.FrameOptionsConfig::disable))
                .httpBasic(AbstractHttpConfigurer::disable) // Disable HTTP Basic authentication
                .formLogin(AbstractHttpConfigurer::disable); // Disable login form

        return http.build();
    }
}
