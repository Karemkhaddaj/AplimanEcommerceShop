package com.ProjectApliman.EcommerceShop.model;

import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;  //jakarta jpa
import lombok.Data;
import java.util.Date;
import java.util.List;

@Entity
@Data
public class Invoice {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne // Each invoice is linked to one user
    @JoinColumn(name = "user_id", nullable = false)
    private User user; // Linked to a user

    @OneToMany(mappedBy = "invoice", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonManagedReference // Prevents circular reference issues
    private List<InvoiceItem> items; // List of purchased items

    private double totalAmount;
    private Date purchaseDate;

    public Invoice() {
        this.purchaseDate = new Date(); // Set purchase date when invoice is created
    }

}