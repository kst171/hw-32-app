package com.demo;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

@DisplayName("Calculator Tests")
public class CalculatorTest {

    private Calculator calc;

    @BeforeEach
    void setUp() {
        calc = new Calculator();
    }

    @Test
    @DisplayName("Addition: 2 + 3 = 5")
    void testAdd() {
        assertEquals(5, calc.add(2, 3));
    }

    @Test
    @DisplayName("Subtraction: 10 - 4 = 6")
    void testSubtract() {
        assertEquals(6, calc.subtract(10, 4));
    }

    @Test
    @DisplayName("Multiplication: 3 * 4 = 12")
    void testMultiply() {
        assertEquals(12, calc.multiply(3, 4));
    }

    @Test
    @DisplayName("Division: 10 / 2 = 5.0")
    void testDivide() {
        assertEquals(5.0, calc.divide(10, 2));
    }

    @Test
    @DisplayName("Division by zero throws ArithmeticException")
    void testDivideByZero() {
        assertThrows(ArithmeticException.class, () -> calc.divide(5, 0));
    }
}
