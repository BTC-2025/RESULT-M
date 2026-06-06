package com.resulthub.api.voting.dto;

import com.resulthub.api.voting.entity.VoteBox;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public record VoteBoxResponse(
        UUID id,
        String title,
        String description,
        VoteBox.VoteBoxVisibility visibility,
        boolean allowAnonymous,
        LocalDateTime endsAt,
        UUID linkedWorkspaceId,
        boolean hideResultsUntilEnd,
        long totalVotes,
        LocalDateTime createdAt,
        List<OptionResponse> options,
        boolean hasVoted,
        UUID selectedOptionId
) {
    public record OptionResponse(
            UUID id,
            String optionText,
            Long voteCount // Can be null if hidden
    ) {}
}
