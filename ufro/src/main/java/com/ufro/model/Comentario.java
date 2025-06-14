package com.ufro.model;

import com.google.cloud.Timestamp;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;


@Data
@NoArgsConstructor
@AllArgsConstructor
public class Comentario {
    private String texto;
    private Timestamp fechaHora;
    private String usuarioId;
}
