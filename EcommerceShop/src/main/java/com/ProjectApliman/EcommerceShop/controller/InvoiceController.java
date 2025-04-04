package com.ProjectApliman.EcommerceShop.controller;

import com.ProjectApliman.EcommerceShop.model.*;
import com.ProjectApliman.EcommerceShop.repository.*;
import org.springframework.beans.factory.annotation.Autowired;  //spring data jpa
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;  //Spring web

import java.util.List;

@CrossOrigin(origins = "*") // Allows all origins
@RestController  //automatically converts return values to json... no need to requestbody on each method
@RequestMapping("/invoice")
public class InvoiceController {

    @Autowired
    private InvoiceRepository invoiceRepository;

    @GetMapping("/all")
    public ResponseEntity<List<Invoice>> getAllInvoices() {
        List<Invoice> invoices = invoiceRepository.findAll();
        return ResponseEntity.ok(invoices);
    }

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ItemRepository itemRepository;

    @Autowired
    private InvoiceItemRepository invoiceItemRepository;

    @PostMapping("/purchase/{userId}")
    public ResponseEntity<Invoice> createInvoice(@PathVariable Long userId, @RequestBody List<InvoiceItem> purchasedItems) {
        // Find the user
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        // Create a new invoice
        Invoice invoice = new Invoice();
        invoice.setUser(user);
        invoice.setTotalAmount(0);
        invoice = invoiceRepository.save(invoice);

        double totalAmount = 0.0;

        // Process each item
        for (InvoiceItem invoiceItem : purchasedItems) {
            Item item = itemRepository.findById(invoiceItem.getItem().getItemId())
                    .orElseThrow(() -> new RuntimeException("Item not found"));

            // Set item details
            invoiceItem.setItem(item);
            invoiceItem.setInvoice(invoice);
            invoiceItem.setPrice(item.getItemvalue() * invoiceItem.getQuantity());
            totalAmount += invoiceItem.getPrice();
        }

        invoice.setTotalAmount(totalAmount);
        invoice.setItems(purchasedItems);

        invoice = invoiceRepository.save(invoice);
        invoiceItemRepository.saveAll(purchasedItems);

        return ResponseEntity.ok(invoice);
    }

    // Get all invoices by customer name
    @GetMapping("/search/{customerName}")
    public List<Invoice> getInvoicesByCustomerName(@PathVariable String customerName) {
        return invoiceRepository.findByCustomerName(customerName);
    }
    // Get all invoices by customer ID
    @GetMapping("/searchbyID/{customerId}")
    public List<Invoice> getInvoicesByCustomerId(@PathVariable Long customerId) {
        return invoiceRepository.findByCustomerId(customerId);
    }

}