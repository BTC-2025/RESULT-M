package com.resulthub.api.voting.dto;

import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public record CastVoteRequest(
        @NotNull UUID optionId,
        String deviceFingerprint // Optional, used for anonymous anti-spam
) {}
