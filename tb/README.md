# 🕒 Clock Divider / Baud Rate Generator IP Design & Verification

## 📖 Overview
This repository focuses on the **Design and Verification** of a high-precision **Baud Rate Generator (Clock Divider)**. This IP is a fundamental block for UART (Universal Asynchronous Receiver-Transmitter) communication, responsible for dividing a high-speed system clock into a precise sampling clock (Baud Rate).

## 🗂️ Repository Structure

| Directory/File | Description |
| :--- | :--- |
| `rtl/` | Contains the source Verilog RTL code (`baud_gen_design.v`). |
| `tb/` | Contains the SystemVerilog Testbench (`baud_gen_tb.v`) for verification. |
| `README.md` | This document. |

## 🛠️ Design & Verification Flow

### 1. RTL Design
The design implements a synchronous counter-based clock divider. It is parameterized to allow for various division factors, enabling the generation of standard baud rates (e.g., 9600, 115200) from common crystal oscillator frequencies.
* **Input:** System Clock, Reset, Division Factor.
* **Output:** Baud Tick (Baud Rate Clock).

### 2. Verification (Testbench)
The verification was conducted using a SystemVerilog testbench to ensure:
* **Accuracy:** The output frequency matches the expected division ratio.
* **Stability:** The pulse width of the baud tick is consistent across multiple cycles.
* **Reset Behavior:** The generator initializes correctly and recovers from asynchronous/synchronous resets.

## 🚀 Clock Generator Introduction
A **Clock Generator** is the heartbeat of any digital system. In this project, the Baud Rate Generator acts as a specialized clock generator that provides the timing reference for serial data transmission. It ensures that both the transmitter and receiver are synchronized, preventing data corruption during asynchronous communication.

## 🔗 Documentation & Professional Connect
For the full project documentation, including detailed waveforms, architecture diagrams, and synthesis results, please visit the link below:

* **Complete Documentation (LinkedIn):** [www.linkedin.com/in/saikumarkonapala]
* **My Professional Profile:** [www.linkedin.com/in/saikumarkonapala]


---
