package com.ufro.model;


import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;


@Data
@NoArgsConstructor
@AllArgsConstructor
public class Comentario {
    private String texto;
    private Date fechaHora;
    private String usuarioId;
}
