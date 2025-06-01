package com.ufro.model;


import lombok.*;


@Data
@NoArgsConstructor
@AllArgsConstructor
public class Usuario {

    private String id;

    private String name;
    private String phone;
    private String correo;
    private String contrañesa;
    private Boolean isAdmin;

}
