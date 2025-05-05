package com.ProjectApliman.EcommerceShop.controller;

import com.ProjectApliman.EcommerceShop.model.*;
import com.ProjectApliman.EcommerceShop.repository.*;
import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/invoice")
public class InvoiceController {

    private final MeterRegistry meterRegistry;

    @Autowired
    public InvoiceController(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
    }

    @Autowired
    private InvoiceRepository invoiceRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ItemRepository itemRepository;

    @Autowired
    private InvoiceItemRepository invoiceItemRepository;

    @GetMapping("/all")
    public ResponseEntity<List<Invoice>> getAllInvoices() {
        var sample = io.micrometer.core.instrument.Timer.start(meterRegistry);
        try {
            List<Invoice> invoices = invoiceRepository.findAll();

            meterRegistry.counter("invoice_get_all_success_total").increment();
            sample.stop(meterRegistry.timer("invoice_get_all_duration_seconds"));

            return ResponseEntity.ok(invoices);
        } catch (Exception e) {
            meterRegistry.counter("invoice_get_all_failed_total").increment();
            sample.stop(meterRegistry.timer("invoice_get_all_duration_seconds"));
            throw e;
        }
    }

    @PostMapping("/purchase/{userId}")
    public ResponseEntity<Invoice> createInvoice(@PathVariable Long userId, @RequestBody List<InvoiceItem> purchasedItems) {
        var sample = io.micrometer.core.instrument.Timer.start(meterRegistry);

        try {
            User user = userRepository.findById(userId)
                    .orElseThrow(() -> new RuntimeException("User not found"));

            Invoice invoice = new Invoice();
            invoice.setUser(user);
            invoice.setTotalAmount(0);
            invoice = invoiceRepository.save(invoice);

            double totalAmount = 0.0;
            for (InvoiceItem invoiceItem : purchasedItems) {
                Item item = itemRepository.findById(invoiceItem.getItem().getItemId())
                        .orElseThrow(() -> new RuntimeException("Item not found"));
                invoiceItem.setItem(item);
                invoiceItem.setInvoice(invoice);
                invoiceItem.setPrice(item.getItemvalue() * invoiceItem.getQuantity());
                totalAmount += invoiceItem.getPrice();
            }

            invoice.setTotalAmount(totalAmount);
            invoice.setItems(purchasedItems);

            invoice = invoiceRepository.save(invoice);
            invoiceItemRepository.saveAll(purchasedItems);

            //INCREMENT the custom metric if total is below 50
            if (totalAmount < 50) {
                meterRegistry.counter("invoice_low_amount_total").increment();
            }

            meterRegistry.counter("invoice_creation_success_total").increment();
            sample.stop(meterRegistry.timer("invoice_creation_duration_seconds"));

            return ResponseEntity.ok(invoice);
        } catch (Exception e) {
            meterRegistry.counter("invoice_creation_failed_total").increment();
            sample.stop(meterRegistry.timer("invoice_creation_duration_seconds"));
            throw e;
        }
    }

    @GetMapping("/search/{customerName}")
    public List<Invoice> getInvoicesByCustomerName(@PathVariable String customerName) {
        var sample = io.micrometer.core.instrument.Timer.start(meterRegistry);

        try {
            List<Invoice> result = invoiceRepository.findByCustomerName(customerName);
            meterRegistry.counter("invoice_search_by_name_success_total").increment();
            sample.stop(meterRegistry.timer("invoice_search_by_name_duration_seconds"));
            return result;
        } catch (Exception e) {
            meterRegistry.counter("invoice_search_by_name_failed_total").increment();
            sample.stop(meterRegistry.timer("invoice_search_by_name_duration_seconds"));
            throw e;
        }
    }

    @GetMapping("/searchbyID/{customerId}")
    public List<Invoice> getInvoicesByCustomerId(@PathVariable Long customerId) {
        var sample = io.micrometer.core.instrument.Timer.start(meterRegistry);

        try {
            List<Invoice> result = invoiceRepository.findByCustomerId(customerId);
            meterRegistry.counter("invoice_search_by_id_success_total").increment();
            sample.stop(meterRegistry.timer("invoice_search_by_id_duration_seconds"));
            return result;
        } catch (Exception e) {
            meterRegistry.counter("invoice_search_by_id_failed_total").increment();
            sample.stop(meterRegistry.timer("invoice_search_by_id_duration_seconds"));
            throw e;
        }
    }
}