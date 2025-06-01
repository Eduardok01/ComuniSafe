package com.ufro.model;

public class TestData {
    private String nombre;
    private int edad;

    // Constructor vacío (necesario para deserialización JSON)
    public TestData() {}

    // Getters y setters
    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public int getEdad() {
        return edad;
    }

    public void setEdad(int edad) {
        this.edad = edad;
    }
}
