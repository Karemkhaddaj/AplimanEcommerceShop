package com.ProjectApliman.EcommerceShop.repository;

import com.ProjectApliman.EcommerceShop.model.Item;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ItemRepository extends JpaRepository<Item,Long> {

    // Custom query to search items by name (case-insensitive)
    @Query("SELECT i FROM Item i WHERE LOWER(i.itemname) LIKE LOWER(CONCAT('%', :name, '%'))")
    List<Item> findByItemnameContaining(@Param("name") String name);
}
