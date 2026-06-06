package com.resulthub.api.search;

import com.resulthub.api.BaseContainerTest;
import com.resulthub.api.dataset.entity.Dataset;
import com.resulthub.api.dataset.entity.DatasetRecord;
import com.resulthub.api.dataset.enums.DatasetStatus;
import com.resulthub.api.dataset.repository.DatasetRecordRepository;
import com.resulthub.api.dataset.repository.DatasetRepository;
import com.resulthub.api.search.dto.PaginatedSearchResponse;
import com.resulthub.api.search.dto.SearchResult;
import com.resulthub.api.search.repository.SearchRepository;
import com.resulthub.api.search.service.SearchService;
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

import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

public class SearchIntegrationTest extends BaseContainerTest {

    @Autowired
    private SearchRepository searchRepository;

    @Autowired
    private SearchService searchService;

    @Autowired
    private DatasetRecordRepository datasetRecordRepository;
    
    @Autowired
    private DatasetRepository datasetRepository;
    
    @Autowired
    private WorkspaceRepository workspaceRepository;

    @Autowired
    private WorkspaceMemberRepository workspaceMemberRepository;
    
    @Autowired
    private UserRepository userRepository;

    @Test
    void testJsonbSearchWithGinIndex() {
        User user = new User();
        user.setEmail("searchuser@example.com");
        user.setName("Searcher");
        user.setRole(UserRole.USER);
        user = userRepository.save(user);

        Workspace workspace = new Workspace();
        workspace.setName("Search Workspace");
        workspace.setSlug("search-ws");
        workspace.setOwner(user);
        workspace = workspaceRepository.save(workspace);

        Dataset dataset = new Dataset();
        dataset.setName("Search Dataset");
        dataset.setSlug("search-ds");
        dataset.setWorkspace(workspace);
        dataset.setStatus(DatasetStatus.PUBLISHED);
        dataset = datasetRepository.save(dataset);

        DatasetRecord record = new DatasetRecord();
        record.setDataset(dataset);
        record.setData(Map.of("studentId", "STU-999", "grade", "A+"));
        datasetRecordRepository.save(record);

        // Perform a search query leveraging PostgreSQL GIN indexes on the JSONB columns
        List<SearchResult> results = searchRepository.globalSearch("STU-999", null, false, 0, 10);
        
        // Assert native SQL execution against PostgreSQL context succeeds
        assertThat(results).isNotNull();
    }

    @Test
    void globalSearchDoesNotLeakPrivateWorkspaceResults() {
        User owner = createUser("private-search-owner@example.com");
        Workspace privateWorkspace = createWorkspace(
                "Private Search Workspace",
                "private-search-ws",
                owner,
                VisibilityMode.PRIVATE
        );
        createPublishedDatasetRecord(privateWorkspace, owner, "Private Dataset", "private-ds", "secrethiddenneedle");

        PaginatedSearchResponse response = searchService.globalSearch(
                "secrethiddenneedle",
                null,
                0,
                10,
                null,
                null
        );

        assertThat(response.getResults())
                .noneMatch(result -> privateWorkspace.getId().equals(result.getWorkspaceId()));
    }

    @Test
    void scopedSearchAllowsPublicWorkspaceWithoutLogin() {
        User owner = createUser("public-scoped-owner@example.com");
        Workspace publicWorkspace = createWorkspace(
                "Public Scoped Search Workspace",
                "public-scoped-search-ws",
                owner,
                VisibilityMode.PUBLIC
        );
        createPublishedDatasetRecord(publicWorkspace, owner, "Public Dataset", "public-scoped-ds", "publicscopedneedle");

        PaginatedSearchResponse response = searchService.globalSearch(
                "publicscopedneedle",
                publicWorkspace.getId(),
                0,
                10,
                null,
                null
        );

        assertThat(response.getResults())
                .anyMatch(result -> publicWorkspace.getId().equals(result.getWorkspaceId()));
    }

    @Test
    void scopedSearchRejectsPrivateWorkspaceForNonMember() {
        User owner = createUser("private-scoped-owner@example.com");
        User outsider = createUser("private-scoped-outsider@example.com");
        Workspace privateWorkspace = createWorkspace(
                "Private Scoped Search Workspace",
                "private-scoped-search-ws",
                owner,
                VisibilityMode.PRIVATE
        );
        createPublishedDatasetRecord(privateWorkspace, owner, "Private Scoped Dataset", "private-scoped-ds", "privatescopedneedle");

        assertThatThrownBy(() -> searchService.globalSearch(
                "privatescopedneedle",
                privateWorkspace.getId(),
                0,
                10,
                outsider,
                null
        )).hasMessageContaining("403 FORBIDDEN");
    }

    @Test
    void scopedSearchAllowsPrivateWorkspaceMember() {
        User owner = createUser("private-member-owner@example.com");
        User member = createUser("private-member-viewer@example.com");
        Workspace privateWorkspace = createWorkspace(
                "Private Member Search Workspace",
                "private-member-search-ws",
                owner,
                VisibilityMode.PRIVATE
        );
        workspaceMemberRepository.save(WorkspaceMember.builder()
                .workspace(privateWorkspace)
                .user(member)
                .role(WorkspaceRole.VIEWER)
                .build());
        createPublishedDatasetRecord(privateWorkspace, owner, "Private Member Dataset", "private-member-ds", "memberprivateneedle");

        PaginatedSearchResponse response = searchService.globalSearch(
                "memberprivateneedle",
                privateWorkspace.getId(),
                0,
                10,
                member,
                null
        );

        assertThat(response.getResults())
                .anyMatch(result -> privateWorkspace.getId().equals(result.getWorkspaceId()));
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

    private void createPublishedDatasetRecord(
            Workspace workspace,
            User owner,
            String datasetName,
            String datasetSlug,
            String searchableValue
    ) {
        Dataset dataset = new Dataset();
        dataset.setName(datasetName);
        dataset.setSlug(datasetSlug);
        dataset.setWorkspace(workspace);
        dataset.setCreatedBy(owner);
        dataset.setStatus(DatasetStatus.PUBLISHED);
        dataset = datasetRepository.save(dataset);

        DatasetRecord record = new DatasetRecord();
        record.setDataset(dataset);
        record.setRecordKey(searchableValue);
        record.setRecordTitle(searchableValue);
        record.setData(Map.of("searchValue", searchableValue));
        datasetRecordRepository.save(record);
    }
}
