package com.ProjectApliman.EcommerceShop.controller;

import com.ProjectApliman.EcommerceShop.model.User;
import com.ProjectApliman.EcommerceShop.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@CrossOrigin(origins = "*") // Allows all origins
@RestController
public class UserController {

    @Autowired
    private UserRepository userRepository;

    // Add new User
    @PostMapping("/user")
    User newUser(@RequestBody User newUser){  // @RequestBody converts incoming JSON to User object
        return userRepository.save(newUser);
    }
    // List all users
    @GetMapping("/users")
    List<User> getAllUsers(){
        return userRepository.findAll();
    }
    // READ Single User by ID
    @GetMapping("/user/{id}")
    public ResponseEntity<User> getUserById(@PathVariable Long id) {
        Optional<User> user = userRepository.findById(id);
        return user.map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
    // UPDATE User by ID
    @PutMapping("/user/{id}")
    public ResponseEntity<User> updateUser(@PathVariable Long id, @RequestBody User updatedUser) {
        return userRepository.findById(id)
                .map(existingUser -> {
                    existingUser.setUsername(updatedUser.getUsername());
                    existingUser.setName(updatedUser.getName());
                    existingUser.setEmail(updatedUser.getEmail());
                    // Save the updated user
                    userRepository.save(existingUser);
                    return ResponseEntity.ok(existingUser);
                })
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
    // Search users by name
    @GetMapping("/user/search/{name}")
    public List<User> searchUsers(@PathVariable String name) {
        return userRepository.findByNameContaining(name);
    }
}