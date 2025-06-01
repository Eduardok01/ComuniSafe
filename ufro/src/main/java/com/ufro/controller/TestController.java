package com.ufro.controller;

import com.ufro.model.TestData;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
public class TestController {

    @PostMapping("/test")
    public ResponseEntity<String> recibirDatos(@RequestBody TestData data) {
        // Aquí puedes procesar los datos recibidos
        String respuesta = "Recibido: Nombre = " + data.getNombre() + ", Edad = " + data.getEdad();
        return ResponseEntity.ok(respuesta);
    }
}
