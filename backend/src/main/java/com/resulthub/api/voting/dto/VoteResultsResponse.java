package com.resulthub.api.voting.dto;

import java.util.UUID;

public record VoteResultsResponse(
        UUID optionId,
        String optionText,
        long voteCount,
        double percentage
) {}
