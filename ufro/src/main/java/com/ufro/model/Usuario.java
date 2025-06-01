package com.ufro.model;


import lombok.*;


@Data
@NoArgsConstructor
@AllArgsConstructor
public class Usuario {
    private String name;
    private String phone;
    private String correo;
    private String contrasena;
    private int edad;
}
