package com.resulthub.api.auth.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class OrgRegisterRequest {
    @NotBlank(message = "Organization Name is required")
    private String name;

    @NotBlank(message = "Organization Type is required")
    private String organizationType;

    @NotBlank(message = "Email is required")
    @Email(message = "Valid email is required")
    private String email;

    @NotBlank(message = "Password is required")
    @Size(min = 8, message = "Password must be at least 8 characters")
    private String password;

    private String phoneNumber;
    private String website;
    private String city;
}
