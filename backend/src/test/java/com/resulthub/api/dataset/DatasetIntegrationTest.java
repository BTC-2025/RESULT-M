package com.resulthub.api.dataset;

import com.resulthub.api.BaseContainerTest;
import com.resulthub.api.dataset.dto.DatasetRequest;
import com.resulthub.api.dataset.entity.Dataset;
import com.resulthub.api.dataset.entity.DatasetRecord;
import com.resulthub.api.dataset.enums.DomainType;
import com.resulthub.api.dataset.repository.DatasetRecordRepository;
import com.resulthub.api.dataset.repository.DatasetRepository;
import com.resulthub.api.dataset.service.DatasetService;
import com.resulthub.api.user.User;
import com.resulthub.api.user.UserRepository;
import com.resulthub.api.user.UserRole;
import com.resulthub.api.workspace.entity.Workspace;
import com.resulthub.api.workspace.entity.WorkspaceMember;
import com.resulthub.api.workspace.enums.VisibilityMode;
import com.resulthub.api.workspace.enums.WorkspaceRole;
import com.resulthub.api.workspace.repository.WorkspaceMemberRepository;
import com.resulthub.api.workspace.repository.WorkspaceRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.util.Map;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

public class DatasetIntegrationTest extends BaseContainerTest {

    @Autowired
    private DatasetRecordRepository datasetRecordRepository;
    
    @Autowired
    private DatasetRepository datasetRepository;

    @Autowired
    private DatasetService datasetService;
    
    @Autowired
    private WorkspaceRepository workspaceRepository;

    @Autowired
    private WorkspaceMemberRepository memberRepository;
    
    @Autowired
    private UserRepository userRepository;

    @Test
    void testJsonbPersistenceAndRetrieval() {
        User user = new User();
        user.setEmail("owner2@example.com");
        user.setName("Owner");
        user.setRole(UserRole.USER);
        user = userRepository.save(user);

        Workspace workspace = new Workspace();
        workspace.setName("Dataset Workspace");
        workspace.setSlug("ds-space");
        workspace.setOwner(user);
        workspace = workspaceRepository.save(workspace);

        Dataset dataset = new Dataset();
        dataset.setName("Test Dataset");
        dataset.setSlug("test-ds");
        dataset.setWorkspace(workspace);
        dataset = datasetRepository.save(dataset);

        DatasetRecord record = new DatasetRecord();
        record.setDataset(dataset);
        
        // This tests the Hypersistence Utils JSONB mapping to PostgreSQL
        Map<String, Object> data = Map.of(
            "rollNumber", "1001",
            "name", "John Doe",
            "score", 95.5
        );
        record.setData(data);

        DatasetRecord saved = datasetRecordRepository.save(record);
        assertThat(saved.getId()).isNotNull();

        Optional<DatasetRecord> retrieved = datasetRecordRepository.findById(saved.getId());
        assertThat(retrieved).isPresent();
        
        Map<String, Object> retrievedData = retrieved.get().getData();
        assertThat(retrievedData).containsEntry("rollNumber", "1001");
        assertThat(retrievedData).containsEntry("name", "John Doe");
        assertThat(retrievedData.get("score")).isEqualTo(95.5);
    }

    @Test
    void privateWorkspaceDatasetsRequireMembershipToRead() {
        User owner = createUser("private-dataset-owner@example.com");
        User outsider = createUser("private-dataset-outsider@example.com");
        Workspace workspace = createWorkspace("Private Dataset Workspace", "private-dataset-workspace", owner, VisibilityMode.PRIVATE);
        addMember(workspace, owner, WorkspaceRole.OWNER);
        Dataset dataset = createDataset(workspace, owner, "private-dataset");

        assertThatThrownBy(() -> datasetService.getDataset(dataset.getId(), null, null))
                .isInstanceOf(ResponseStatusException.class)
                .extracting("statusCode")
                .isEqualTo(HttpStatus.FORBIDDEN);

        assertThatThrownBy(() -> datasetService.getDatasetsByWorkspace(workspace.getId(), PageRequest.of(0, 10), outsider, null))
                .isInstanceOf(ResponseStatusException.class)
                .extracting("statusCode")
                .isEqualTo(HttpStatus.FORBIDDEN);

        assertThat(datasetService.getDataset(dataset.getId(), owner, null).getId())
                .isEqualTo(dataset.getId());
    }

    @Test
    void datasetMutationRequiresEditorRole() {
        User owner = createUser("dataset-editor-owner@example.com");
        User viewer = createUser("dataset-viewer@example.com");
        User admin = createUser("dataset-admin@example.com");
        Workspace workspace = createWorkspace("Dataset Role Workspace", "dataset-role-workspace", owner, VisibilityMode.PUBLIC);
        addMember(workspace, viewer, WorkspaceRole.VIEWER);
        addMember(workspace, admin, WorkspaceRole.ADMIN);

        DatasetRequest request = datasetRequest("Role Checked Dataset", "role-checked-dataset");

        assertThatThrownBy(() -> datasetService.createDataset(workspace.getId(), request, viewer))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("VIEWER cannot modify");

        assertThat(datasetService.createDataset(workspace.getId(), request, admin).getId())
                .isNotNull();
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

    private Dataset createDataset(Workspace workspace, User createdBy, String slug) {
        Dataset dataset = new Dataset();
        dataset.setName(slug);
        dataset.setSlug(slug);
        dataset.setWorkspace(workspace);
        dataset.setCreatedBy(createdBy);
        dataset.setDomainType(DomainType.EDUCATION);
        return datasetRepository.save(dataset);
    }

    private void addMember(Workspace workspace, User user, WorkspaceRole role) {
        WorkspaceMember member = WorkspaceMember.builder()
                .workspace(workspace)
                .user(user)
                .role(role)
                .build();
        memberRepository.save(member);
    }

    private DatasetRequest datasetRequest(String name, String slug) {
        DatasetRequest request = new DatasetRequest();
        request.setName(name);
        request.setSlug(slug);
        request.setDescription("Integration test dataset");
        request.setDomainType(DomainType.EDUCATION);
        return request;
    }
}
