package com.resulthub.api.voting;

import com.resulthub.api.BaseContainerTest;
import com.resulthub.api.outbox.repository.WriteOutboxEventRepository;
import com.resulthub.api.user.User;
import com.resulthub.api.user.UserRepository;
import com.resulthub.api.user.UserRole;
import com.resulthub.api.voting.dto.CreateVoteBoxRequest;
import com.resulthub.api.voting.dto.VoteBoxResponse;
import com.resulthub.api.voting.entity.VoteBox;
import com.resulthub.api.voting.service.VoteBoxService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

public class VoteBoxServiceIntegrationTest extends BaseContainerTest {

    @Autowired
    private VoteBoxService voteBoxService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private WriteOutboxEventRepository outboxRepository;

    @Test
    void userCanVoteOnceAndCountsAreUpdated() {
        User owner = createUser("vote-owner@example.com");
        User voter = createUser("vote-voter@example.com");
        VoteBoxResponse voteBox = createVoteBox(owner, true);
        VoteBoxResponse.OptionResponse firstOption = voteBox.options().getFirst();
        long outboxBefore = outboxRepository.count();

        voteBoxService.castVote(voteBox.id(), firstOption.id(), voter.getId(), "10.0.0.1", "device-a");

        VoteBoxResponse afterVote = voteBoxService.getVoteBoxById(voteBox.id(), voter.getId());
        assertThat(afterVote.totalVotes()).isEqualTo(1);
        assertThat(afterVote.hasVoted()).isTrue();
        assertThat(afterVote.selectedOptionId()).isEqualTo(firstOption.id());
        assertThat(afterVote.options().getFirst().voteCount()).isEqualTo(1);

        assertThatThrownBy(() -> voteBoxService.castVote(
                voteBox.id(),
                voteBox.options().get(1).id(),
                voter.getId(),
                "10.0.0.2",
                "device-b"
        ))
                .isInstanceOf(ResponseStatusException.class)
                .extracting("statusCode")
                .isEqualTo(HttpStatus.CONFLICT);
        assertThat(outboxRepository.count()).isEqualTo(outboxBefore + 1);
    }

    @Test
    void anonymousDuplicateDeviceVoteIsRejectedWithinLimitWindow() {
        User owner = createUser("anonymous-vote-owner@example.com");
        VoteBoxResponse voteBox = createVoteBox(owner, true);

        voteBoxService.castVote(voteBox.id(), voteBox.options().getFirst().id(), null, "10.0.0.3", "same-device");

        assertThatThrownBy(() -> voteBoxService.castVote(
                voteBox.id(),
                voteBox.options().get(1).id(),
                null,
                "10.0.0.4",
                "same-device"
        ))
                .isInstanceOf(ResponseStatusException.class)
                .extracting("statusCode")
                .isEqualTo(HttpStatus.TOO_MANY_REQUESTS);
    }

    @Test
    void anonymousDuplicateIpVoteIsRejectedWithinLimitWindow() {
        User owner = createUser("anonymous-ip-vote-owner@example.com");
        VoteBoxResponse voteBox = createVoteBox(owner, true);

        voteBoxService.castVote(voteBox.id(), voteBox.options().getFirst().id(), null, "10.0.0.5", "device-c");

        assertThatThrownBy(() -> voteBoxService.castVote(
                voteBox.id(),
                voteBox.options().get(1).id(),
                null,
                "10.0.0.5",
                "device-d"
        ))
                .isInstanceOf(ResponseStatusException.class)
                .extracting("statusCode")
                .isEqualTo(HttpStatus.TOO_MANY_REQUESTS);
    }

    private VoteBoxResponse createVoteBox(User owner, boolean allowAnonymous) {
        return voteBoxService.createVoteBox(
                new CreateVoteBoxRequest(
                        "Service Quality Poll",
                        "Choose the better option",
                        VoteBox.VoteBoxVisibility.PUBLIC,
                        null,
                        allowAnonymous,
                        null,
                        null,
                        false,
                        List.of("Option A", "Option B")
                ),
                owner.getId()
        );
    }

    private User createUser(String email) {
        User user = new User();
        user.setEmail(email);
        user.setName(email);
        user.setRole(UserRole.USER);
        return userRepository.save(user);
    }
}
