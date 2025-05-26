package com.ufro.comuniSafe.service;

import com.ufro.comuniSafe.model.Contact;
import com.ufro.comuniSafe.repository.ContactRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ContactService {

    private final ContactRepository repository;

    public ContactService(ContactRepository repository) {
        this.repository = repository;
    }

    public List<Contact> findAll() {
        return repository.findAll();
    }

    public Contact save(Contact contact) {
        return repository.save(contact);
    }
}
