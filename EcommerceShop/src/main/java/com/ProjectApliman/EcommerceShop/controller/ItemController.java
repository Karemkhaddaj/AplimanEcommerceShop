package com.ProjectApliman.EcommerceShop.controller;

import com.ProjectApliman.EcommerceShop.model.Item;
import com.ProjectApliman.EcommerceShop.repository.ItemRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@CrossOrigin(origins = "*") // Allows all origins
@RestController
public class ItemController {

    @Autowired
    private ItemRepository itemRepository;

    //  Add new Item
    @PostMapping("/item")
    Item newItem(@RequestBody Item newItem){
        return itemRepository.save(newItem);
    }
    //  List all Items
    @GetMapping("/items")
    List<Item> getAllItems() {
        return itemRepository.findAll();
    }
    // READ Single Item by ID
    @GetMapping("/item/{id}")
    public ResponseEntity<Item> getItemById(@PathVariable Long id) {
        Optional<Item> item = itemRepository.findById(id);
        return item.map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
    // UPDATE Item by ID
    @PutMapping("/item/{id}")
    public ResponseEntity<Item> updateItem(@PathVariable Long id, @RequestBody Item updatedItem) {
        return itemRepository.findById(id)
                .map(existingItem -> {
                    existingItem.setItemname(updatedItem.getItemname());
                    existingItem.setItemdescription(updatedItem.getItemdescription());
                    existingItem.setItemvalue(updatedItem.getItemvalue());
                    existingItem.setItemimage(updatedItem.getItemimage());
                    return ResponseEntity.ok(itemRepository.save(existingItem));
                })
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
    @DeleteMapping("/item/{id}")
    public ResponseEntity<Void> deleteItem(@PathVariable Long id) {
        try {
            if (!itemRepository.existsById(id)) {
                return ResponseEntity.notFound().build(); // 404 if doesn't exist
            }
            itemRepository.deleteById(id);
            return ResponseEntity.noContent().build(); // 204 on success
        } catch (DataIntegrityViolationException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT).build(); // 409 if constrained
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build(); // 500 for other errors
        }
    }
    // Search items by name
    @GetMapping("/item/search/{name}")
    public List<Item> searchItems(@PathVariable String name) {
        return itemRepository.findByItemnameContaining(name);
    }
}