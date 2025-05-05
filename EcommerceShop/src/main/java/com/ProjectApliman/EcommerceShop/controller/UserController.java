package com.ProjectApliman.EcommerceShop.controller;

import com.ProjectApliman.EcommerceShop.model.User;
import com.ProjectApliman.EcommerceShop.repository.UserRepository;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@CrossOrigin(origins = "*")
@RestController
public class UserController {

    private final MeterRegistry meterRegistry;

    @Autowired
    public UserController(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
    }

    @Autowired
    private UserRepository userRepository;

    @PostMapping("/user")
    public User newUser(@RequestBody User newUser) throws InterruptedException {
        var sample = Timer.start(meterRegistry);
        try {
            // Simulate a delay of 5 seconds
            Thread.sleep(5000);
            User saved = userRepository.save(newUser);
            meterRegistry.counter("user_create_success_total").increment();
            sample.stop(meterRegistry.timer("user_create_duration_seconds"));
            return saved;
        } catch (Exception e) {
            meterRegistry.counter("user_create_failed_total").increment();
            sample.stop(meterRegistry.timer("user_create_duration_seconds"));
            throw e;
        }
    }

    @GetMapping("/users")
    public ResponseEntity<List<User>> getAllUsers() {
        var sample = Timer.start(meterRegistry);
        try {
            List<User> users = userRepository.findAll();
            meterRegistry.counter("user_get_all_success_total").increment();
            sample.stop(meterRegistry.timer("user_get_all_duration_seconds"));
            return ResponseEntity.ok(users);
        } catch (Exception e) {
            meterRegistry.counter("user_get_all_failed_total").increment();
            sample.stop(meterRegistry.timer("user_get_all_duration_seconds"));
            throw e;
        }
    }

    @GetMapping("/user/{id}")
    public ResponseEntity<User> getUserById(@PathVariable Long id) {
        var sample = Timer.start(meterRegistry);
        try {
            Optional<User> user = userRepository.findById(id);
            meterRegistry.counter("user_get_by_id_success_total").increment();
            sample.stop(meterRegistry.timer("user_get_by_id_duration_seconds"));
            return user.map(ResponseEntity::ok)
                    .orElseGet(() -> ResponseEntity.notFound().build());
        } catch (Exception e) {
            meterRegistry.counter("user_get_by_id_failed_total").increment();
            sample.stop(meterRegistry.timer("user_get_by_id_duration_seconds"));
            throw e;
        }
    }

    @PutMapping("/user/{id}")
    public ResponseEntity<User> updateUser(@PathVariable Long id, @RequestBody User updatedUser) {
        var sample = Timer.start(meterRegistry);
        try {
            ResponseEntity<User> response = userRepository.findById(id)
                    .map(existingUser -> {
                        existingUser.setUsername(updatedUser.getUsername());
                        existingUser.setName(updatedUser.getName());
                        existingUser.setEmail(updatedUser.getEmail());
                        userRepository.save(existingUser);
                        return ResponseEntity.ok(existingUser);
                    })
                    .orElseGet(() -> ResponseEntity.notFound().build());

            meterRegistry.counter("user_update_success_total").increment();
            sample.stop(meterRegistry.timer("user_update_duration_seconds"));
            return response;
        } catch (Exception e) {
            meterRegistry.counter("user_update_failed_total").increment();
            sample.stop(meterRegistry.timer("user_update_duration_seconds"));
            throw e;
        }
    }

    @GetMapping("/user/search/{name}")
    public List<User> searchUsers(@PathVariable String name) {
        var sample = Timer.start(meterRegistry);
        try {
            List<User> result = userRepository.findByNameContaining(name);
            meterRegistry.counter("user_search_success_total").increment();
            sample.stop(meterRegistry.timer("user_search_duration_seconds"));
            return result;
        } catch (Exception e) {
            meterRegistry.counter("user_search_failed_total").increment();
            sample.stop(meterRegistry.timer("user_search_duration_seconds"));
            throw e;
        }
    }
}
