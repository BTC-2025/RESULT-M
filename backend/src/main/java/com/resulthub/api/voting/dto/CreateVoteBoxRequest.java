package com.resulthub.api.voting.dto;

import com.resulthub.api.voting.entity.VoteBox;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public record CreateVoteBoxRequest(
        @NotBlank @Size(max = 255) String title,
        @NotBlank String description,
        @NotNull VoteBox.VoteBoxVisibility visibility,
        String accessCode,
        boolean allowAnonymous,
        LocalDateTime endsAt,
        UUID linkedWorkspaceId,
        boolean hideResultsUntilEnd,
        @NotEmpty @Size(min = 2, max = 50) List<@NotBlank String> options
) {}
