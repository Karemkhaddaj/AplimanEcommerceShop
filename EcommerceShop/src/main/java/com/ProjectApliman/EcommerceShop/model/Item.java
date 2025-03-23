package com.ProjectApliman.EcommerceShop.model;

import jakarta.persistence.*;

@Entity
public class Item {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) // Ensure MySQL manages the ID properly
    private Long itemId;

    private String itemname;
    private String itemdescription;
    private double itemvalue;
    private String itemimage;

    public Long getItemId() {
        return itemId;
    }

    public void setItemId(Long itemId) {
        this.itemId = itemId;
    }

    public String getItemname() {
        return itemname;
    }

    public void setItemname(String itemname) {
        this.itemname = itemname;
    }

    public String getItemdescription() {
        return itemdescription;
    }

    public void setItemdescription(String itemdescription) {
        this.itemdescription = itemdescription;
    }

    public double getItemvalue() {
        return itemvalue;
    }

    public void setItemvalue(double itemvalue) {
        this.itemvalue = itemvalue;
    }
    public String getItemimage() {
        return itemimage;
    }

    public void setItemimage(String itemimage) {
        this.itemimage = itemimage;
    }
}
