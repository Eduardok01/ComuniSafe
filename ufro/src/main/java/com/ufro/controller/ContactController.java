package com.ufro.controller;

import com.ufro.model.Contact;
import com.ufro.service.ContactService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/contactos")
@CrossOrigin(origins = "*") // Opcional: permite acceso desde el frontend
public class ContactController {

    @Autowired
    private ContactService contactService;

    @PostMapping
    public String guardarContacto(@RequestBody Contact contact) {
        contactService.guardarContactos(contact);
        return "Contacto guardado correctamente.";
    }

    @GetMapping
    public List<Contact> obtenerContactos() {
        return contactService.obtenerTodos();
    }
}
