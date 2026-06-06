package com.resulthub.api.workspace;

import com.resulthub.api.BaseContainerTest;
import com.resulthub.api.dataset.entity.Dataset;
import com.resulthub.api.dataset.enums.DatasetStatus;
import com.resulthub.api.dataset.enums.DomainType;
import com.resulthub.api.dataset.repository.DatasetRepository;
import com.resulthub.api.user.User;
import com.resulthub.api.user.UserRepository;
import com.resulthub.api.user.UserRole;
import com.resulthub.api.workspace.entity.Workspace;
import com.resulthub.api.workspace.entity.WorkspaceMember;
import com.resulthub.api.workspace.enums.VisibilityMode;
import com.resulthub.api.workspace.enums.WorkspaceRole;
import com.resulthub.api.workspace.repository.WorkspaceMemberRepository;
import com.resulthub.api.workspace.repository.WorkspaceRepository;
import com.resulthub.api.workspace.service.WorkspaceService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;

import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

public class WorkspaceIntegrationTest extends BaseContainerTest {

    @Autowired
    private WorkspaceRepository workspaceRepository;

    @Autowired
    private WorkspaceService workspaceService;

    @Autowired
    private WorkspaceMemberRepository memberRepository;
    
    @Autowired
    private UserRepository userRepository;

    @Autowired
    private DatasetRepository datasetRepository;

    @Test
    void testWorkspaceCreationAndRetrieval() {
        User user = new User();
        user.setEmail("owner1@example.com");
        user.setName("Owner");
        user.setRole(UserRole.USER);
        user = userRepository.save(user);

        Workspace workspace = new Workspace();
        workspace.setName("Test University");
        workspace.setSlug("test-univ");
        workspace.setOwner(user);

        Workspace saved = workspaceRepository.save(workspace);

        assertThat(saved.getId()).isNotNull();

        Optional<Workspace> retrieved = workspaceRepository.findById(saved.getId());
        assertThat(retrieved).isPresent();
        assertThat(retrieved.get().getName()).isEqualTo("Test University");
    }

    @Test
    void testPublicWorkspaceDomainFilterUsesPublishedDatasets() {
        User user = new User();
        user.setEmail("domain-filter-owner@example.com");
        user.setName("Domain Owner");
        user.setRole(UserRole.USER);
        user = userRepository.save(user);

        Workspace sportsWorkspace = createWorkspace("Sports Domain Workspace", "sports-domain-ws", user, VisibilityMode.PUBLIC);
        Workspace educationWorkspace = createWorkspace("Education Domain Workspace", "education-domain-ws", user, VisibilityMode.PUBLIC);
        Workspace draftSportsWorkspace = createWorkspace("Draft Sports Domain Workspace", "draft-sports-domain-ws", user, VisibilityMode.PUBLIC);
        Workspace privateSportsWorkspace = createWorkspace("Private Sports Domain Workspace", "private-sports-domain-ws", user, VisibilityMode.PRIVATE);

        createDataset(sportsWorkspace, "sports-domain-dataset", DomainType.SPORTS, DatasetStatus.PUBLISHED);
        createDataset(educationWorkspace, "education-domain-dataset", DomainType.EDUCATION, DatasetStatus.PUBLISHED);
        createDataset(draftSportsWorkspace, "draft-sports-domain-dataset", DomainType.SPORTS, DatasetStatus.DRAFT);
        createDataset(privateSportsWorkspace, "private-sports-domain-dataset", DomainType.SPORTS, DatasetStatus.PUBLISHED);

        Page<Workspace> result = workspaceRepository.findByVisibilityAndPublishedDomainAndNotDeleted(
                VisibilityMode.PUBLIC,
                DatasetStatus.PUBLISHED,
                DomainType.SPORTS,
                PageRequest.of(0, 20)
        );

        assertThat(result.getContent()).extracting(Workspace::getId)
                .contains(sportsWorkspace.getId())
                .doesNotContain(educationWorkspace.getId(), draftSportsWorkspace.getId(), privateSportsWorkspace.getId());
    }

    @Test
    void privateWorkspaceRequiresMembership() {
        User owner = createUser("private-workspace-owner@example.com");
        User outsider = createUser("private-workspace-outsider@example.com");
        Workspace workspace = createWorkspace("Private Workspace", "private-workspace", owner, VisibilityMode.PRIVATE);
        addMember(workspace, owner, WorkspaceRole.OWNER);

        assertThatThrownBy(() -> workspaceService.getWorkspace(workspace.getId(), null, null))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Access denied");

        assertThatThrownBy(() -> workspaceService.getWorkspace(workspace.getId(), outsider, null))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Access denied");

        assertThat(workspaceService.getWorkspace(workspace.getId(), owner, null).getId())
                .isEqualTo(workspace.getId());
    }

    @Test
    void passwordProtectedWorkspaceAllowsCorrectAccessCodeOrMember() {
        User owner = createUser("password-workspace-owner@example.com");
        User member = createUser("password-workspace-member@example.com");
        Workspace workspace = createWorkspace("Password Workspace", "password-workspace", owner, VisibilityMode.PASSWORD_PROTECTED);
        workspace.setAccessCode("OPEN123");
        workspace = workspaceRepository.save(workspace);
        UUID workspaceId = workspace.getId();
        addMember(workspace, member, WorkspaceRole.VIEWER);

        assertThatThrownBy(() -> workspaceService.getWorkspace(workspaceId, null, "WRONG"))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Invalid access code");

        assertThat(workspaceService.getWorkspace(workspaceId, null, "OPEN123").getId())
                .isEqualTo(workspaceId);
        assertThat(workspaceService.getWorkspace(workspaceId, member, null).getId())
                .isEqualTo(workspaceId);
    }

    private User createUser(String email) {
        User user = new User();
        user.setEmail(email);
        user.setName(email);
        user.setRole(UserRole.USER);
        return userRepository.save(user);
    }

    private Workspace createWorkspace(String name, String slug, User owner, VisibilityMode visibility) {
        Workspace workspace = new Workspace();
        workspace.setName(name);
        workspace.setSlug(slug);
        workspace.setOwner(owner);
        workspace.setVisibility(visibility);
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

    private void createDataset(Workspace workspace, String slug, DomainType domainType, DatasetStatus status) {
        Dataset dataset = new Dataset();
        dataset.setName(slug);
        dataset.setSlug(slug);
        dataset.setWorkspace(workspace);
        dataset.setDomainType(domainType);
        dataset.setStatus(status);
        datasetRepository.save(dataset);
    }
}
