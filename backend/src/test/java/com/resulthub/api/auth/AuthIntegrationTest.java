package com.resulthub.api.auth;

import com.resulthub.api.BaseContainerTest;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

public class AuthIntegrationTest extends BaseContainerTest {

    @Autowired
    private TestRestTemplate restTemplate;

    @Test
    void testRegisterAndLoginFlow() {
        // 1. Register User
        Map<String, String> registerRequest = Map.of(
                "name", "Test User",
                "email", "testuser@resulthub.com",
                "password", "SecurePass123!",
                "role", "ROLE_USER"
        );

        ResponseEntity<Map> registerResponse = restTemplate.postForEntity("/api/v1/auth/register", registerRequest, Map.class);
        
        // Assert API boundaries without mocks
        assertThat(registerResponse.getStatusCode()).isNotNull();

        // 2. Login User
        Map<String, String> loginRequest = Map.of(
                "email", "testuser@resulthub.com",
                "password", "SecurePass123!"
        );

        ResponseEntity<Map> loginResponse = restTemplate.postForEntity("/api/v1/auth/login", loginRequest, Map.class);
        
        assertThat(loginResponse.getStatusCode()).isNotNull();
        assertThat(loginResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(loginResponse.getBody()).containsKeys("accessToken", "refreshToken");

        Map<String, String> refreshRequest = Map.of(
                "refreshToken", loginResponse.getBody().get("refreshToken").toString()
        );

        ResponseEntity<Map> refreshResponse = restTemplate.postForEntity("/api/v1/auth/refresh", refreshRequest, Map.class);

        assertThat(refreshResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(refreshResponse.getBody()).containsKeys("accessToken", "refreshToken", "userId");
    }
}
