package com.resulthub.api.complaint;

import com.resulthub.api.BaseContainerTest;
import com.resulthub.api.complaint.dto.CastVoteRequest;
import com.resulthub.api.complaint.dto.ComplaintCommentResponse;
import com.resulthub.api.complaint.dto.ComplaintResponse;
import com.resulthub.api.complaint.dto.CreateComplaintRequest;
import com.resulthub.api.complaint.entity.Complaint;
import com.resulthub.api.complaint.entity.ComplaintVote;
import com.resulthub.api.complaint.repository.ComplaintRepository;
import com.resulthub.api.complaint.service.ComplaintMediaService;
import com.resulthub.api.complaint.service.ComplaintService;
import com.resulthub.api.outbox.repository.WriteOutboxEventRepository;
import com.resulthub.api.user.User;
import com.resulthub.api.user.UserRepository;
import com.resulthub.api.user.UserRole;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.mock.web.MockMultipartFile;

import static org.assertj.core.api.Assertions.assertThat;

public class ComplaintServiceIntegrationTest extends BaseContainerTest {

    @Autowired
    private ComplaintService complaintService;

    @Autowired
    private ComplaintMediaService mediaService;

    @Autowired
    private ComplaintRepository complaintRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private WriteOutboxEventRepository outboxRepository;

    @Test
    void complaintVoteToggleAndChangeKeepCountersConsistent() {
        User creator = createUser("complaint-creator@example.com");
        User voter = createUser("complaint-voter@example.com");
        Complaint complaint = createComplaint(creator, "Broken street light");
        long outboxBefore = outboxRepository.count();

        complaintService.castVote(
                complaint.getId(),
                new CastVoteRequest(ComplaintVote.VoteType.UP),
                voter.getId()
        );

        Complaint afterUpvote = reload(complaint);
        assertThat(afterUpvote.getUpvotes()).isEqualTo(1);
        assertThat(afterUpvote.getDownvotes()).isZero();

        complaintService.castVote(
                complaint.getId(),
                new CastVoteRequest(ComplaintVote.VoteType.DOWN),
                voter.getId()
        );

        Complaint afterChange = reload(complaint);
        assertThat(afterChange.getUpvotes()).isZero();
        assertThat(afterChange.getDownvotes()).isEqualTo(1);

        complaintService.castVote(
                complaint.getId(),
                new CastVoteRequest(ComplaintVote.VoteType.DOWN),
                voter.getId()
        );

        Complaint afterToggleOff = reload(complaint);
        assertThat(afterToggleOff.getUpvotes()).isZero();
        assertThat(afterToggleOff.getDownvotes()).isZero();
        assertThat(outboxRepository.count()).isEqualTo(outboxBefore + 3);
    }

    @Test
    void flagThresholdMovesOpenComplaintUnderReview() {
        User creator = createUser("complaint-flag-creator@example.com");
        Complaint complaint = createComplaint(creator, "Overflowing drainage");
        long outboxBefore = outboxRepository.count();

        for (int i = 0; i < 10; i++) {
            complaintService.flagComplaint(complaint.getId());
        }

        Complaint flagged = reload(complaint);
        assertThat(flagged.getFlagCount()).isEqualTo(10);
        assertThat(flagged.getStatus()).isEqualTo(Complaint.ComplaintStatus.UNDER_REVIEW);
        assertThat(outboxRepository.count()).isEqualTo(outboxBefore + 10);
    }

    @Test
    void createComplaintWithMediaCommentAndStatusUpdatePersistsWorkflow() throws Exception {
        User creator = createUser("complaint-workflow-creator@example.com");
        MockMultipartFile image = new MockMultipartFile(
                "files",
                "evidence.png",
                "image/png",
                "png-data".getBytes()
        );

        ComplaintResponse created = complaintService.createComplaint(
                new CreateComplaintRequest(
                        "Water leak near bus stop",
                        "Pipe has been leaking for two days",
                        "Civic",
                        null,
                        null,
                        "Central bus stop",
                        false
                ),
                new MockMultipartFile[]{image},
                creator.getId()
        );

        assertThat(created.id()).isNotNull();
        assertThat(created.mediaUrls()).containsExactly(created.id() + "/evidence.png");
        assertThat(created.commentCount()).isZero();

        Resource storedMedia = mediaService.loadMediaAsResource(created.id().toString(), "evidence.png");
        assertThat(storedMedia.exists()).isTrue();
        assertThat(storedMedia.contentLength()).isEqualTo("png-data".getBytes().length);

        ComplaintCommentResponse comment = complaintService.addComment(
                created.id(),
                "Authorities notified",
                true,
                creator.getId()
        );

        assertThat(comment.id()).isNotNull();
        assertThat(comment.content()).isEqualTo("Authorities notified");
        assertThat(comment.creatorName()).isEqualTo("Anonymous");
        assertThat(complaintService.getComplaintById(created.id(), creator.getId()).commentCount()).isEqualTo(1);

        complaintService.updateStatus(created.id(), Complaint.ComplaintStatus.RESOLVED);

        Complaint resolved = complaintRepository.findById(created.id()).orElseThrow();
        assertThat(resolved.getStatus()).isEqualTo(Complaint.ComplaintStatus.RESOLVED);
    }

    private User createUser(String email) {
        User user = new User();
        user.setEmail(email);
        user.setName(email);
        user.setRole(UserRole.USER);
        return userRepository.save(user);
    }

    private Complaint createComplaint(User creator, String title) {
        Complaint complaint = Complaint.builder()
                .creator(creator)
                .category("Civic")
                .title(title)
                .description("Integration test complaint")
                .isAnonymous(false)
                .build();
        return complaintRepository.save(complaint);
    }

    private Complaint reload(Complaint complaint) {
        return complaintRepository.findById(complaint.getId()).orElseThrow();
    }
}
