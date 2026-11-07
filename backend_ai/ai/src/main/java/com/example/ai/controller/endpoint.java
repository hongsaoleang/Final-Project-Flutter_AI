package com.example.ai.controller;

import com.example.ai.model.testDB;
import com.example.ai.repository.TestDbRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/items")
public class endpoint {

    @Autowired
    private TestDbRepository testDbRepository;

    // Get all records from PostgreSQL
    @GetMapping
    public List<testDB> getAllItems() {
        return testDbRepository.findAll();
    }

    // Save a new record into PostgreSQL
    @PostMapping
    public ResponseEntity<testDB> createItem(@RequestBody testDB item) {
        testDB savedItem = testDbRepository.save(item);
        return ResponseEntity.ok(savedItem);
    }

    // Delete a record by ID
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteItem(@PathVariable Long id) {
        testDbRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }
    }
