package com.ufro.controller;


import com.ufro.model.Reporte;
import com.ufro.service.ReporteService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.concurrent.ExecutionException;

@RestController
@RequestMapping("/api/reportes")
@CrossOrigin(origins = "*") // Permitir peticiones desde el frontend
public class ReporteController {

    @Autowired
    private ReporteService reporteService;

    @PostMapping
    public String crearReporte(@RequestBody Reporte reporte) throws ExecutionException, InterruptedException {
        return reporteService.crearReporte(reporte);
    }

    @PutMapping("/{id}/estado")
    public String actualizarEstado(@PathVariable String id) throws ExecutionException, InterruptedException {
        return reporteService.actualizarEstado(id);
    }

    @GetMapping("/{id}")
    public Reporte obtenerReporte(@PathVariable String id) throws ExecutionException, InterruptedException {
        return reporteService.obtenerReporte(id);
    }

    @GetMapping
    public List<Reporte> obtenerTodosLosReportes() throws ExecutionException, InterruptedException {
        return reporteService.obtenerTodosLosReportes();
    }
}
