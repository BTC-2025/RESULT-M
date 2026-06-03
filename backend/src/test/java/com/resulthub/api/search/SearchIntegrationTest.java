package com.resulthub.api.search;

import com.resulthub.api.BaseContainerTest;
import com.resulthub.api.dataset.entity.Dataset;
import com.resulthub.api.dataset.entity.DatasetRecord;
import com.resulthub.api.dataset.enums.DatasetStatus;
import com.resulthub.api.dataset.repository.DatasetRecordRepository;
import com.resulthub.api.dataset.repository.DatasetRepository;
import com.resulthub.api.search.dto.SearchResult;
import com.resulthub.api.search.repository.SearchRepository;
import com.resulthub.api.user.User;
import com.resulthub.api.user.UserRepository;
import com.resulthub.api.user.UserRole;
import com.resulthub.api.workspace.entity.Workspace;
import com.resulthub.api.workspace.repository.WorkspaceRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

public class SearchIntegrationTest extends BaseContainerTest {

    @Autowired
    private SearchRepository searchRepository;

    @Autowired
    private DatasetRecordRepository datasetRecordRepository;
    
    @Autowired
    private DatasetRepository datasetRepository;
    
    @Autowired
    private WorkspaceRepository workspaceRepository;
    
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
        List<SearchResult> results = searchRepository.globalSearch("STU-999", user.getId(), 0, 10);
        
        // Assert native SQL execution against PostgreSQL context succeeds
        assertThat(results).isNotNull();
    }
}
