package com.ufro.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.sql.Timestamp;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Reporte {

    private String tipo;
    private String descripcion;
    private String estado;
    private Double latitud;
    private Double longitud;
    private String direccion;
    private Timestamp fechaHora;
}
