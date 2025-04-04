package com.ProjectApliman.EcommerceShop.model;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
public class InvoiceItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "invoice_id", nullable = false)
    @JsonBackReference // Prevents circular reference issues
    private Invoice invoice; // Linked to an invoice

    @ManyToOne
    @JoinColumn(name = "item_id", nullable = false)
    private Item item; // The actual item purchased

    private int quantity;
    private double price; // itemValue * quantity


}