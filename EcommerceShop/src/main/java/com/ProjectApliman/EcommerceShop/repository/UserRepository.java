package com.ProjectApliman.EcommerceShop.repository;

import com.ProjectApliman.EcommerceShop.model.Item;
import com.ProjectApliman.EcommerceShop.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface UserRepository extends JpaRepository<User,Long> {

    // Custom query to search users by name (case-insensitive)
    @Query("SELECT u FROM User u WHERE LOWER(u.name) LIKE LOWER(CONCAT('%', :name, '%'))")
    List<User> findByNameContaining(@Param("name") String name);

    User name(String name);
}