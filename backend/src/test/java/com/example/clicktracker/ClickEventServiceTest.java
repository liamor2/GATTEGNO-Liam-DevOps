package com.example.clicktracker;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class ClickEventServiceTest {

    @Test
    void shouldSetIpAndTimestampWhenRecordingClick() {
        ClickEventRepository repository = mock(ClickEventRepository.class);
        when(repository.save(any(ClickEvent.class))).thenAnswer(invocation -> {
            ClickEvent saved = invocation.getArgument(0);
            return saved;
        });

        ClickEventService service = new ClickEventService(repository);
        ClickEvent event = service.recordClick("203.0.113.50");

        assertThat(event.getIpAddress()).isEqualTo("203.0.113.50");
        assertThat(event.getPressedAt()).isNotNull();
    }
}
