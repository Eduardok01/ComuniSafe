package com.ufro.dto;

import com.google.cloud.Timestamp;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ReporteConUsuarioDTO {
    private String id;            // ID del reporte (Firestore document ID)
    private String tipo;
    private String descripcion;
    private Boolean pendiente;
    private Double latitud;
    private Double longitud;
    private String direccion;
    private Timestamp fechaHora;
    private String usuarioId;
    private String nombreUsuario;
    private String correoUsuario;
    private String rolUsuario;
}
