package com.resulthub.api.dataset.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.networknt.schema.JsonSchema;
import com.networknt.schema.JsonSchemaFactory;
import com.networknt.schema.SpecVersion;
import com.networknt.schema.ValidationMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class SchemaValidationService {

    private final ObjectMapper objectMapper;

    public void validateDataAgainstSchema(Map<String, Object> data, Map<String, Object> schemaDefinition) {
        if (schemaDefinition == null || schemaDefinition.isEmpty()) {
            return; // No schema defined, allow anything
        }

        try {
            JsonNode schemaNode = objectMapper.valueToTree(schemaDefinition);
            JsonNode dataNode = objectMapper.valueToTree(data);

            JsonSchemaFactory factory = JsonSchemaFactory.getInstance(SpecVersion.VersionFlag.V7);
            JsonSchema schema = factory.getSchema(schemaNode);

            Set<ValidationMessage> validationResult = schema.validate(dataNode);

            if (!validationResult.isEmpty()) {
                String errors = validationResult.stream()
                        .map(ValidationMessage::getMessage)
                        .collect(Collectors.joining(", "));
                throw new RuntimeException("JSON Schema Validation Failed: " + errors);
            }
        } catch (Exception e) {
            log.error("Schema validation processing error", e);
            throw new RuntimeException(e.getMessage());
        }
    }
}
