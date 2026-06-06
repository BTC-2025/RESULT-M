package com.resulthub.api.voting.dto;

import jakarta.validation.constraints.NotBlank;

public record UnlockVoteBoxRequest(
        @NotBlank String accessCode
) {}
