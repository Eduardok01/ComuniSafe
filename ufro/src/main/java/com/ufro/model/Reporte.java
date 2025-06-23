package com.ufro.model;

import lombok.*;

import java.util.Date;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Reporte {
    private String id;
    private String tipo;
    private String descripcion;
    private Boolean pendiente;
    private Double latitud;
    private Double longitud;
    private String direccion;
    private Date fechaHora;
    private String usuarioId;

    private String photoUrl;
}
