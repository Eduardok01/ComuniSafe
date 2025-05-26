package com.ufro.comuniSafe.controller;

import com.ufro.comuniSafe.model.Contact;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/contacts")
public class ContactController {

    private final com.ufro.comuniSafe.service.ContactService service;


    public ContactController(com.ufro.comuniSafe.service.ContactService service) {
        this.service = service;
    }

    @GetMapping
    public List<Contact> getAllContacts() {
        return service.findAll();
    }

    @PostMapping
    public Contact createContact(@RequestBody Contact contact) {
        return service.save(contact);
    }
}
