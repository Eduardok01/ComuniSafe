package com.ufro.model;


import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Contact {

    private String id;
    private String name;
    private String phone;
    private String email;

}
