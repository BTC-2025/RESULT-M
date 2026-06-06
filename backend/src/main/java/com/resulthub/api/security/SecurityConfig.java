package com.resulthub.api.security;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.authentication.HttpStatusEntryPoint;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.http.HttpStatus;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
@EnableMethodSecurity
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthFilter;
    private final WorkspaceTokenFilter workspaceTokenFilter;
    private final VoteBoxTokenFilter voteBoxTokenFilter;
    private final AuthenticationProvider authenticationProvider;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(AbstractHttpConfigurer::disable)
            .authorizeHttpRequests(auth -> auth
                .requestMatchers(
                    "/api/v1/auth/**",
                    "/v3/api-docs/**",
                    "/swagger-ui/**"
                ).permitAll()
                .requestMatchers(org.springframework.http.HttpMethod.GET, "/api/v1/complaints/**").permitAll()
                .requestMatchers(org.springframework.http.HttpMethod.POST, "/api/v1/complaints").permitAll()
                .requestMatchers(org.springframework.http.HttpMethod.GET).permitAll()
                .requestMatchers(org.springframework.http.HttpMethod.POST, "/api/v1/workspaces/*/unlock").permitAll()
                .requestMatchers(org.springframework.http.HttpMethod.POST, "/api/v1/votes").permitAll()
                .requestMatchers(org.springframework.http.HttpMethod.POST, "/api/v1/votes/*/unlock").permitAll()
                .requestMatchers(org.springframework.http.HttpMethod.POST, "/api/v1/votes/*/cast").permitAll()
                .anyRequest().authenticated()
            )
            .sessionManagement(sess -> sess.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .exceptionHandling(ex -> ex.authenticationEntryPoint(new HttpStatusEntryPoint(HttpStatus.UNAUTHORIZED)))
            .authenticationProvider(authenticationProvider)
            .addFilterBefore(voteBoxTokenFilter, UsernamePasswordAuthenticationFilter.class)
            .addFilterBefore(workspaceTokenFilter, UsernamePasswordAuthenticationFilter.class)
            .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class)
            .oauth2Login(oauth2 -> oauth2
                .authorizationEndpoint(auth -> auth.baseUri("/oauth2/authorization"))
                // In a full implementation, you would add a custom OAuth2UserService here to link Google accounts to your users table
            );

        return http.build();
    }
}
