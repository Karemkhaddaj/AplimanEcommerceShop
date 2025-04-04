package com.ProjectApliman.EcommerceShop.repository;

import com.ProjectApliman.EcommerceShop.model.InvoiceItem;
import org.springframework.data.jpa.repository.JpaRepository;

public interface InvoiceItemRepository extends JpaRepository<InvoiceItem, Long> {
}
