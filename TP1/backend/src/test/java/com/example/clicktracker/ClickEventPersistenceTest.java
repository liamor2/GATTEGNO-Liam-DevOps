package com.example.clicktracker;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
class ClickEventPersistenceTest {

    @Autowired
    private ClickEventService service;

    @Autowired
    private ClickEventRepository repository;

    @Test
    void shouldPersistClickWithTimestampAndIp() {
        ClickEvent event = service.recordClick("192.0.2.20");

        assertThat(event.getId()).isNotNull();
        assertThat(event.getPressedAt()).isNotNull();
        assertThat(event.getIpAddress()).isEqualTo("192.0.2.20");
        assertThat(repository.findById(event.getId())).isPresent();
    }
}
