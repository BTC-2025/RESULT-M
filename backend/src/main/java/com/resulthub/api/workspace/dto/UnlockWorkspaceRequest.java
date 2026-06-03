package com.resulthub.api.workspace.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UnlockWorkspaceRequest {

    @NotBlank(message = "Access code cannot be empty")
    private String accessCode;

}
