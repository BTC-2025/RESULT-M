package com.resulthub.api.voting;

import com.resulthub.api.BaseContainerTest;
import com.resulthub.api.security.JwtService;
import com.resulthub.api.user.User;
import com.resulthub.api.user.UserRepository;
import com.resulthub.api.user.UserRole;
import com.resulthub.api.voting.dto.CreateVoteBoxRequest;
import com.resulthub.api.voting.dto.VoteBoxResponse;
import com.resulthub.api.voting.entity.VoteBox;
import com.resulthub.api.voting.service.VoteBoxService;
import com.resulthub.api.workspace.entity.Workspace;
import com.resulthub.api.workspace.entity.WorkspaceMember;
import com.resulthub.api.workspace.enums.VisibilityMode;
import com.resulthub.api.workspace.enums.WorkspaceRole;
import com.resulthub.api.workspace.repository.WorkspaceMemberRepository;
import com.resulthub.api.workspace.repository.WorkspaceRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

public class VoteBoxControllerIntegrationTest extends BaseContainerTest {

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private VoteBoxService voteBoxService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private WorkspaceRepository workspaceRepository;

    @Autowired
    private WorkspaceMemberRepository memberRepository;

    @Autowired
    private JwtService jwtService;

    @Test
    void passwordProtectedVoteBoxRequiresUnlockTokenForAnonymousAccess() {
        User owner = createUser("password-vote-owner@example.com");
        VoteBoxResponse voteBox = voteBoxService.createVoteBox(
                new CreateVoteBoxRequest(
                        "Protected Poll",
                        "Needs code",
                        VoteBox.VoteBoxVisibility.PASSWORD_PROTECTED,
                        "VOTE123",
                        true,
                        null,
                        null,
                        false,
                        List.of("Yes", "No")
                ),
                owner.getId()
        );

        ResponseEntity<Map> blocked = restTemplate.getForEntity("/api/v1/votes/" + voteBox.id(), Map.class);
        assertThat(blocked.getStatusCode()).isEqualTo(HttpStatus.UNAUTHORIZED);

        ResponseEntity<Map> wrongUnlock = restTemplate.postForEntity(
                "/api/v1/votes/" + voteBox.id() + "/unlock",
                Map.of("accessCode", "WRONG"),
                Map.class
        );
        assertThat(wrongUnlock.getStatusCode()).isEqualTo(HttpStatus.UNAUTHORIZED);

        ResponseEntity<Map> unlock = restTemplate.postForEntity(
                "/api/v1/votes/" + voteBox.id() + "/unlock",
                Map.of("accessCode", "VOTE123"),
                Map.class
        );
        assertThat(unlock.getStatusCode()).isEqualTo(HttpStatus.OK);
        String token = unlock.getBody().get("token").toString();

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Workspace " + token);
        ResponseEntity<Map> allowed = restTemplate.exchange(
                "/api/v1/votes/" + voteBox.id(),
                HttpMethod.GET,
                new HttpEntity<>(headers),
                Map.class
        );

        assertThat(allowed.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(allowed.getBody()).containsEntry("id", voteBox.id().toString());
    }

    @Test
    void privateVoteBoxRequiresCreatorOrLinkedWorkspaceMember() {
        User owner = createUser("private-vote-owner@example.com");
        User member = createUser("private-vote-member@example.com");
        User outsider = createUser("private-vote-outsider@example.com");
        Workspace workspace = createWorkspace(owner);
        addMember(workspace, member, WorkspaceRole.VIEWER);

        VoteBoxResponse voteBox = voteBoxService.createVoteBox(
                new CreateVoteBoxRequest(
                        "Private Poll",
                        "Members only",
                        VoteBox.VoteBoxVisibility.PRIVATE,
                        null,
                        false,
                        null,
                        workspace.getId(),
                        false,
                        List.of("A", "B")
                ),
                owner.getId()
        );

        ResponseEntity<Map> anonymous = restTemplate.getForEntity("/api/v1/votes/" + voteBox.id(), Map.class);
        assertThat(anonymous.getStatusCode()).isEqualTo(HttpStatus.UNAUTHORIZED);

        ResponseEntity<Map> outsiderResponse = restTemplate.exchange(
                "/api/v1/votes/" + voteBox.id(),
                HttpMethod.GET,
                bearerEntity(outsider),
                Map.class
        );
        assertThat(outsiderResponse.getStatusCode()).isEqualTo(HttpStatus.FORBIDDEN);

        ResponseEntity<Map> memberResponse = restTemplate.exchange(
                "/api/v1/votes/" + voteBox.id(),
                HttpMethod.GET,
                bearerEntity(member),
                Map.class
        );
        assertThat(memberResponse.getStatusCode()).isEqualTo(HttpStatus.OK);

        ResponseEntity<Map> ownerResponse = restTemplate.exchange(
                "/api/v1/votes/" + voteBox.id(),
                HttpMethod.GET,
                bearerEntity(owner),
                Map.class
        );
        assertThat(ownerResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
    }

    private HttpEntity<Void> bearerEntity(User user) {
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(jwtService.generateToken(user));
        return new HttpEntity<>(headers);
    }

    private User createUser(String email) {
        User user = new User();
        user.setEmail(email);
        user.setName(email);
        user.setRole(UserRole.USER);
        return userRepository.save(user);
    }

    private Workspace createWorkspace(User owner) {
        Workspace workspace = new Workspace();
        workspace.setName("Private Vote Workspace");
        workspace.setSlug("private-vote-workspace-" + owner.getId());
        workspace.setOwner(owner);
        workspace.setVisibility(VisibilityMode.PRIVATE);
        return workspaceRepository.save(workspace);
    }

    private void addMember(Workspace workspace, User user, WorkspaceRole role) {
        WorkspaceMember member = WorkspaceMember.builder()
                .workspace(workspace)
                .user(user)
                .role(role)
                .build();
        memberRepository.save(member);
    }
}
