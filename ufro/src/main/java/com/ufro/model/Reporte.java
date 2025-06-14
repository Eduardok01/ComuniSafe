package com.ufro.model;

import lombok.*;
import com.google.cloud.Timestamp;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Reporte {

    private String tipo;
    private String descripcion;
    private Boolean pendiente;
    private Double latitud;
    private Double longitud;
    private String direccion;
    private Timestamp fechaHora;
    private String usuarioId;
}
