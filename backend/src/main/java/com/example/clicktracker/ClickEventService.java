package com.example.clicktracker;

import org.springframework.stereotype.Service;

import java.time.Instant;

@Service
public class ClickEventService {

    private final ClickEventRepository repository;

    public ClickEventService(ClickEventRepository repository) {
        this.repository = repository;
    }

    public ClickEvent recordClick(String ipAddress) {
        ClickEvent event = new ClickEvent(Instant.now(), ipAddress);
        return repository.save(event);
    }
}
