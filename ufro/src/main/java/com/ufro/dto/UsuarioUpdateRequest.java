package com.ufro.dto;

public class UsuarioUpdateRequest {
    private String name;
    private String correo;
    private String phone;

    // Getters y setters
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getCorreo() { return correo; }
    public void setCorreo(String correo) { this.correo = correo; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
}
