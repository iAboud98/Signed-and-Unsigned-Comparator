# Signed and Unsigned Number Comparator Design

## Overview
This project involves designing a **structural comparator** for both signed and unsigned 6-bit numbers. The comparator includes features for comparing two numbers and determining if they are equal, greater, or smaller. It is built structurally using a library of basic logic gates and verified through comprehensive testing.

## Features
- Supports **6-bit signed** (2’s complement) and **unsigned** numbers.
- Includes a **selection input** to toggle between signed and unsigned modes.
- Outputs:
  - **Equal**: High when the two numbers are equal.
  - **Greater**: High when the first number is greater.
  - **Smaller**: High when the first number is smaller.
- Structural design implemented using basic gates (e.g., INV, AND, OR, XOR).
- Synchronous operation with added registers and clock signal.
- Error detection mechanism that identifies design errors during verification.

## Project Objectives
1. **Design** a comparator circuit for signed and unsigned numbers.
2. **Implement** the comparator using structural Verilog.
3. **Verify** functionality with comprehensive simulation covering all input cases.
4. **Analyze** latency and determine the maximum operating frequency.
5. Introduce and detect intentional errors for testing robustness.

## Components
The circuit is built using the following logic gates:
- **INV**
- **NAND**
- **NOR**
- **AND**
- **OR**
- **XNOR**
- **XOR**

Registers are used to synchronize inputs and outputs.

## Design and Implementation
1. **Inputs**:
   - `A` (6-bit): First number
   - `B` (6-bit): Second number
   - `S` (1-bit): Selection for signed or unsigned comparison
2. **Outputs**:
   - `Equal`
   - `Greater`
   - `Smaller`
3. The design is fully structural and follows a modular approach for ease of debugging and scalability.
4. Error handling is integrated to flag design issues.

## Verification
- Comprehensive testing for all possible 6-bit input values.
- Error introduced and successfully detected during verification.
- Latency analysis to determine the maximum operating clock frequency.

## Repository Structure
