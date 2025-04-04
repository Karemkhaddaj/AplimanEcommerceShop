package com.ProjectApliman.EcommerceShop.repository;

import com.ProjectApliman.EcommerceShop.model.Invoice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface InvoiceRepository extends JpaRepository<Invoice, Long> {

    // Custom query to find invoices by customer ID
    @Query("SELECT i FROM Invoice i WHERE i.user.id = :customerId")
    List<Invoice> findByCustomerId(@Param("customerId") Long customerId);

    // Custom query to find invoices by customer's name (case-insensitive)
    @Query("SELECT i FROM Invoice i WHERE LOWER(i.user.name) LIKE LOWER(CONCAT('%', :customerName, '%'))")
    List<Invoice> findByCustomerName(@Param("customerName") String customerName);
}
