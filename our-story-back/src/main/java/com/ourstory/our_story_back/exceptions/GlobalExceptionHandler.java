package com.ourstory.our_story_back.exceptions;

import java.util.HashMap;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

  @ExceptionHandler(ResourceNotFoundException.class)
  public ResponseEntity<ErrorResponse> handleResourceNotFoundException(ResourceNotFoundException exception) {
    ErrorResponse errorResponse = new ErrorResponse( 
      exception.getMessage(),
      HttpStatus.NOT_FOUND.value(),
      "Recurso no encontrado"
    );

    return new ResponseEntity<>(errorResponse, HttpStatus.NOT_FOUND);
  }
  
  @ExceptionHandler(ResourceConflictException.class)
  public ResponseEntity<ErrorResponse> handleResourceConflictException(ResourceConflictException exception) {
    ErrorResponse errorResponse = new ErrorResponse( 
      exception.getMessage(),
      HttpStatus.CONFLICT.value(),
      "Recurso en conflicto"
    );

    return new ResponseEntity<>(errorResponse, HttpStatus.NOT_FOUND);
  }

  @ExceptionHandler(UnauthorizedException.class)
  public ResponseEntity<ErrorResponse> handleUnauthorizedException(UnauthorizedException exception) {
    ErrorResponse errorResponse = new ErrorResponse( 
      exception.getMessage(),
      HttpStatus.UNAUTHORIZED.value(),
      "Credenciales inválidas"
    );

    return new ResponseEntity<>(errorResponse, HttpStatus.NOT_FOUND);
  }

  @ExceptionHandler(BadRequestException.class)
  public ResponseEntity<ErrorResponse> handleBadRequestException(BadRequestException exception) {
    ErrorResponse errorResponse = new ErrorResponse( 
      exception.getMessage(),
      HttpStatus.BAD_REQUEST.value(),
      "Solicitud incorrecta"
    );

    return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
  }

  @ExceptionHandler(MethodArgumentNotValidException.class)
  public ResponseEntity<?> handleValidationsExceptions(MethodArgumentNotValidException exception) {
    Map<String, String> errors = new HashMap<>();
    exception.getBindingResult().getFieldErrors()
      .forEach(error -> errors.put(error.getField(), error.getDefaultMessage()));

    String errorMessage = "Errores de validación en los campos" 
      + String.join(", ", errors.keySet());

    ErrorResponse errorResponse = new ErrorResponse( 
      errorMessage,
      HttpStatus.BAD_REQUEST.value(),
      " Validación fallida"
    );

    return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
    
  }
}
