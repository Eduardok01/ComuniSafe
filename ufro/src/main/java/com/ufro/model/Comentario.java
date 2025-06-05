package com.ufro.model;

import com.google.type.DateTime;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.sql.Timestamp;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Comentario {
    private String id;
    private String texto;
    private Timestamp fechaHora;
    private String usuarioId;
}
