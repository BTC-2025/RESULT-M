package com.resulthub.api.auth;

import com.resulthub.api.auth.dto.AuthRequest;
import com.resulthub.api.auth.dto.AuthResponse;
import com.resulthub.api.auth.dto.RefreshTokenRequest;
import com.resulthub.api.auth.dto.RegisterRequest;
import com.resulthub.api.auth.dto.OrgRegisterRequest;
import com.resulthub.api.auth.dto.ForgotPasswordRequest;
import com.resulthub.api.auth.dto.VerifyOtpRequest;
import com.resulthub.api.auth.dto.ResetPasswordRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService service;

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(
            @Valid @RequestBody RegisterRequest request
    ) {
        return ResponseEntity.ok(service.register(request));
    }

    @PostMapping("/register/organization")
    public ResponseEntity<AuthResponse> registerOrganization(
            @Valid @RequestBody OrgRegisterRequest request
    ) {
        return ResponseEntity.ok(service.registerOrganization(request));
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> authenticate(
            @Valid @RequestBody AuthRequest request
    ) {
        return ResponseEntity.ok(service.authenticate(request));
    }

    @PostMapping("/refresh")
    public ResponseEntity<AuthResponse> refresh(
            @Valid @RequestBody RefreshTokenRequest request
    ) {
        return ResponseEntity.ok(service.refresh(request));
    }

    @PostMapping("/logout")
    public ResponseEntity<String> logout() {
        // Since JWT is stateless, actual logout entails client-side deletion of token.
        // In a stateful token implementation, we would add it to a Redis denylist here.
        SecurityContextHolder.clearContext();
        return ResponseEntity.ok("Successfully logged out");
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<String> forgotPassword(
            @Valid @RequestBody ForgotPasswordRequest request
    ) {
        service.forgotPassword(request);
        return ResponseEntity.ok("OTP sent successfully");
    }

    @PostMapping("/verify-otp")
    public ResponseEntity<String> verifyOtp(
            @Valid @RequestBody VerifyOtpRequest request
    ) {
        service.verifyOtp(request);
        return ResponseEntity.ok("OTP verified successfully");
    }

    @PostMapping("/reset-password")
    public ResponseEntity<String> resetPassword(
            @Valid @RequestBody ResetPasswordRequest request
    ) {
        service.resetPassword(request);
        return ResponseEntity.ok("Password reset successfully");
    }
}
