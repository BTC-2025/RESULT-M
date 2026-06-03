package com.resulthub.api.dataset;

import com.resulthub.api.BaseContainerTest;
import com.resulthub.api.dataset.entity.Dataset;
import com.resulthub.api.dataset.entity.DatasetRecord;
import com.resulthub.api.dataset.repository.DatasetRecordRepository;
import com.resulthub.api.dataset.repository.DatasetRepository;
import com.resulthub.api.user.User;
import com.resulthub.api.user.UserRepository;
import com.resulthub.api.user.UserRole;
import com.resulthub.api.workspace.entity.Workspace;
import com.resulthub.api.workspace.repository.WorkspaceRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.Map;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

public class DatasetIntegrationTest extends BaseContainerTest {

    @Autowired
    private DatasetRecordRepository datasetRecordRepository;
    
    @Autowired
    private DatasetRepository datasetRepository;
    
    @Autowired
    private WorkspaceRepository workspaceRepository;
    
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
}
