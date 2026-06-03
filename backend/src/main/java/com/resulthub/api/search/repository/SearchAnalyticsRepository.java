package com.resulthub.api.search.repository;

import com.resulthub.api.search.entity.SearchAnalytics;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface SearchAnalyticsRepository extends JpaRepository<SearchAnalytics, UUID> {
}
