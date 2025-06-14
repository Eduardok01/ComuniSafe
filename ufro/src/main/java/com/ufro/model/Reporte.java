package com.ufro.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

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
    private LocalDateTime fechaHora; // ✅ cambiado a LocalDateTime
    private String usuarioId;
}
