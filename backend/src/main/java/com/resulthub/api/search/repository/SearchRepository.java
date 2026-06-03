package com.resulthub.api.search.repository;

import com.resulthub.api.search.dto.SearchResult;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
@RequiredArgsConstructor
public class SearchRepository {

    private final NamedParameterJdbcTemplate jdbcTemplate;

    public List<SearchResult> globalSearch(String query, UUID targetWorkspaceId, UUID userId, int offset, int limit) {
        String sql = """
            WITH search_query AS (
                SELECT websearch_to_tsquery('english', :query) AS q
            ),
            workspace_matches AS (
                SELECT w.id, 'WORKSPACE' as type, w.name as title, w.description,
                       ts_rank_cd(w.search_vector, sq.q) AS rank,
                       w.id as workspace_id, NULL::uuid as dataset_id, NULL as domain_type
                FROM workspaces w, search_query sq
                WHERE sq.q @@ w.search_vector
                  AND w.deleted_at IS NULL
                  AND (
                      (:targetWorkspaceId IS NULL AND w.visibility = 'PUBLIC')
                      OR 
                      (:targetWorkspaceId IS NOT NULL AND w.id = :targetWorkspaceId::uuid AND :userId IS NOT NULL AND EXISTS (
                          SELECT 1 FROM workspace_members wm WHERE wm.workspace_id = w.id AND wm.user_id = :userId::uuid
                      ))
                  )
            ),
            dataset_matches AS (
                SELECT d.id, 'DATASET' as type, d.name as title, d.description,
                       ts_rank_cd(d.search_vector, sq.q) AS rank,
                       d.workspace_id, d.id as dataset_id, cast(d.domain_type as text) as domain_type
                FROM datasets d
                INNER JOIN workspaces w ON d.workspace_id = w.id, search_query sq
                WHERE sq.q @@ d.search_vector
                  AND d.deleted_at IS NULL AND w.deleted_at IS NULL
                  AND d.status = 'PUBLISHED'
                  AND (
                      (:targetWorkspaceId IS NULL AND w.visibility = 'PUBLIC')
                      OR 
                      (:targetWorkspaceId IS NOT NULL AND w.id = :targetWorkspaceId::uuid AND :userId IS NOT NULL AND EXISTS (
                          SELECT 1 FROM workspace_members wm WHERE wm.workspace_id = w.id AND wm.user_id = :userId::uuid
                      ))
                  )
            ),
            record_matches AS (
                SELECT r.id, 'RECORD' as type, coalesce(r.record_title, r.record_key) as title, left(r.data::text, 200) as description,
                       ts_rank_cd(r.search_vector, sq.q) AS rank,
                       d.workspace_id, d.id as dataset_id, cast(d.domain_type as text) as domain_type
                FROM dataset_records r
                INNER JOIN datasets d ON r.dataset_id = d.id
                INNER JOIN workspaces w ON d.workspace_id = w.id, search_query sq
                WHERE sq.q @@ r.search_vector
                  AND r.deleted_at IS NULL AND d.deleted_at IS NULL AND w.deleted_at IS NULL
                  AND d.status = 'PUBLISHED'
                  AND (
                      (:targetWorkspaceId IS NULL AND w.visibility = 'PUBLIC')
                      OR 
                      (:targetWorkspaceId IS NOT NULL AND w.id = :targetWorkspaceId::uuid AND :userId IS NOT NULL AND EXISTS (
                          SELECT 1 FROM workspace_members wm WHERE wm.workspace_id = w.id AND wm.user_id = :userId::uuid
                      ))
                  )
            )
            SELECT * FROM workspace_matches
            UNION ALL
            SELECT * FROM dataset_matches
            UNION ALL
            SELECT * FROM record_matches
            ORDER BY rank DESC
            LIMIT :limit OFFSET :offset
        """;

        MapSqlParameterSource params = new MapSqlParameterSource()
                .addValue("query", query)
                .addValue("targetWorkspaceId", targetWorkspaceId != null ? targetWorkspaceId.toString() : null)
                .addValue("userId", userId != null ? userId.toString() : null)
                .addValue("limit", limit)
                .addValue("offset", offset);

        return jdbcTemplate.query(sql, params, (rs, rowNum) -> SearchResult.builder()
                .id(UUID.fromString(rs.getString("id")))
                .type(rs.getString("type"))
                .title(rs.getString("title"))
                .description(rs.getString("description"))
                .relevanceScore(rs.getDouble("rank"))
                .workspaceId(rs.getString("workspace_id") != null ? UUID.fromString(rs.getString("workspace_id")) : null)
                .datasetId(rs.getString("dataset_id") != null ? UUID.fromString(rs.getString("dataset_id")) : null)
                .domainType(rs.getString("domain_type"))
                .build());
    }
}
