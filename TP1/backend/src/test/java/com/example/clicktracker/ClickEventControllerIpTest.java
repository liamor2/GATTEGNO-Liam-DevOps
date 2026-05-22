package com.example.clicktracker;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class ClickEventControllerIpTest {

    @Test
    void shouldUseFirstIpFromXForwardedFor() {
        jakarta.servlet.http.HttpServletRequest request = mock(jakarta.servlet.http.HttpServletRequest.class);
        when(request.getHeader("X-Forwarded-For")).thenReturn("198.51.100.12, 10.0.0.1");

        String ip = ClickEventController.resolveClientIp(request);

        assertThat(ip).isEqualTo("198.51.100.12");
    }

    @Test
    void shouldFallbackToRemoteAddrWhenNoForwardedHeader() {
        jakarta.servlet.http.HttpServletRequest request = mock(jakarta.servlet.http.HttpServletRequest.class);
        when(request.getHeader("X-Forwarded-For")).thenReturn(null);
        when(request.getRemoteAddr()).thenReturn("127.0.0.1");

        String ip = ClickEventController.resolveClientIp(request);

        assertThat(ip).isEqualTo("127.0.0.1");
    }
}
