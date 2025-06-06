package com.ufro.model;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Usuario {
    private String uid;
    private String name;
    private String phone;
    private String correo;
    private String rol; // admin / usuario
}
