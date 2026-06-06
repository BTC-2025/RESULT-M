package com.resulthub.api.complaint.dto;

import com.resulthub.api.complaint.entity.ComplaintVote;

public record CastVoteRequest(
        ComplaintVote.VoteType voteType
) {
}
