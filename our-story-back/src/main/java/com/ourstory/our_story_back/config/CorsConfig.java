package com.ourstory.our_story_back.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;
import java.util.List;

@Configuration
public class CorsConfig {

  @Bean
  public CorsConfigurationSource corsConfigurationSource() {
    CorsConfiguration configuration = new CorsConfiguration();
    
    // Permitir todas las origenes para desarrollo
    // En producción, especifica los dominios exactos
    configuration.setAllowedOriginPatterns(Arrays.asList("*"));
    
    // Alternativamente, para desarrollo local puedes usar:
    // configuration.setAllowedOrigins(Arrays.asList(
    //   "http://localhost:*",
    //   "http://10.0.2.2:*",  // Android emulator
    //   "http://192.168.*.*:*" // Local network
    // ));
    
    // Métodos HTTP permitidos
    configuration.setAllowedMethods(Arrays.asList(
      "GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"
    ));
    
    // Headers permitidos
    configuration.setAllowedHeaders(Arrays.asList(
      "Authorization",
      "Content-Type",
      "Accept",
      "X-Requested-With",
      "remember-me"
    ));
    
    // Headers expuestos (que el cliente puede leer)
    configuration.setExposedHeaders(Arrays.asList(
      "Authorization",
      "Set-Cookie"
    ));
    
    // Permitir credenciales (cookies, authorization headers)
    configuration.setAllowCredentials(true);
    
    // Tiempo de caché para preflight requests (OPTIONS)
    configuration.setMaxAge(3600L);
    
    UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
    source.registerCorsConfiguration("/**", configuration);
    
    return source;
  }
}
