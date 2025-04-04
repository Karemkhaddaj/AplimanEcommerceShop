package com.ProjectApliman.EcommerceShop.model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
public class Item {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) // Ensure MySQL manages the ID properly
    private Long itemId;

    private String itemname;
    private String itemdescription;
    private double itemvalue;
    private String itemimage;

}