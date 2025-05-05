package com.ProjectApliman.EcommerceShop.controller;

import com.ProjectApliman.EcommerceShop.model.Item;
import com.ProjectApliman.EcommerceShop.repository.ItemRepository;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@CrossOrigin(origins = "*")
@RestController
public class ItemController {

    private final MeterRegistry meterRegistry;

    @Autowired
    public ItemController(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
    }

    @Autowired
    private ItemRepository itemRepository;

    @PostMapping("/item")
    public Item newItem(@RequestBody Item newItem) {
        var sample = Timer.start(meterRegistry);
        try {
            Item saved = itemRepository.save(newItem);
            meterRegistry.counter("item_create_success_total").increment();
            sample.stop(meterRegistry.timer("item_create_duration_seconds"));
            return saved;
        } catch (Exception e) {
            meterRegistry.counter("item_create_failed_total").increment();
            sample.stop(meterRegistry.timer("item_create_duration_seconds"));
            throw e;
        }
    }

    @GetMapping("/items")
    public List<Item> getAllItems() {
        var sample = Timer.start(meterRegistry);
        try {
            List<Item> items = itemRepository.findAll();
            meterRegistry.counter("item_get_all_success_total").increment();
            sample.stop(meterRegistry.timer("item_get_all_duration_seconds"));
            return items;
        } catch (Exception e) {
            meterRegistry.counter("item_get_all_failed_total").increment();
            sample.stop(meterRegistry.timer("item_get_all_duration_seconds"));
            throw e;
        }
    }

    @GetMapping("/item/{id}")
    public ResponseEntity<Item> getItemById(@PathVariable Long id) {
        var sample = Timer.start(meterRegistry);
        try {
            Optional<Item> item = itemRepository.findById(id);
            meterRegistry.counter("item_get_by_id_success_total").increment();
            sample.stop(meterRegistry.timer("item_get_by_id_duration_seconds"));
            return item.map(ResponseEntity::ok)
                    .orElseGet(() -> ResponseEntity.notFound().build());
        } catch (Exception e) {
            meterRegistry.counter("item_get_by_id_failed_total").increment();
            sample.stop(meterRegistry.timer("item_get_by_id_duration_seconds"));
            throw e;
        }
    }

    @PutMapping("/item/{id}")
    public ResponseEntity<Item> updateItem(@PathVariable Long id, @RequestBody Item updatedItem) {
        var sample = Timer.start(meterRegistry);
        try {
            ResponseEntity<Item> response = itemRepository.findById(id)
                    .map(existingItem -> {
                        existingItem.setItemname(updatedItem.getItemname());
                        existingItem.setItemdescription(updatedItem.getItemdescription());
                        existingItem.setItemvalue(updatedItem.getItemvalue());
                        existingItem.setItemimage(updatedItem.getItemimage());
                        return ResponseEntity.ok(itemRepository.save(existingItem));
                    })
                    .orElseGet(() -> ResponseEntity.notFound().build());

            meterRegistry.counter("item_update_success_total").increment();
            sample.stop(meterRegistry.timer("item_update_duration_seconds"));
            return response;
        } catch (Exception e) {
            meterRegistry.counter("item_update_failed_total").increment();
            sample.stop(meterRegistry.timer("item_update_duration_seconds"));
            throw e;
        }
    }

    @DeleteMapping("/item/{id}")
    public ResponseEntity<Void> deleteItem(@PathVariable Long id) {
        var sample = Timer.start(meterRegistry);
        try {
            if (!itemRepository.existsById(id)) {
                meterRegistry.counter("item_delete_failed_total").increment();
                sample.stop(meterRegistry.timer("item_delete_duration_seconds"));
                return ResponseEntity.notFound().build();
            }
            itemRepository.deleteById(id);
            meterRegistry.counter("item_delete_success_total").increment();
            sample.stop(meterRegistry.timer("item_delete_duration_seconds"));
            return ResponseEntity.noContent().build();
        } catch (DataIntegrityViolationException e) {
            meterRegistry.counter("item_delete_failed_total").increment();
            sample.stop(meterRegistry.timer("item_delete_duration_seconds"));
            return ResponseEntity.status(HttpStatus.CONFLICT).build();
        } catch (Exception e) {
            meterRegistry.counter("item_delete_failed_total").increment();
            sample.stop(meterRegistry.timer("item_delete_duration_seconds"));
            return ResponseEntity.internalServerError().build();
        }
    }

    @GetMapping("/item/search/{name}")
    public List<Item> searchItems(@PathVariable String name) {
        var sample = Timer.start(meterRegistry);
        try {
            List<Item> result = itemRepository.findByItemnameContaining(name);
            meterRegistry.counter("item_search_success_total").increment();
            sample.stop(meterRegistry.timer("item_search_duration_seconds"));
            return result;
        } catch (Exception e) {
            meterRegistry.counter("item_search_failed_total").increment();
            sample.stop(meterRegistry.timer("item_search_duration_seconds"));
            throw e;
        }
    }
}
