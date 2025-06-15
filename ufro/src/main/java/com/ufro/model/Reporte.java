package com.ufro.model;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.google.cloud.Timestamp;   // <--- importar
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

    // Cambiar LocalDateTime por Timestamp de Firestore para evitar error
    private LocalDateTime fechaHora;

    private String usuarioId;
}
