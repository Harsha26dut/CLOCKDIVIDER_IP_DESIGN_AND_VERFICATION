# 🕒 Clock Divider / Baud Rate Generator IP Design & Verification

## 📖 Overview
This repository focuses on the **Design and Verification** of a high-precision **Baud Rate Generator (Clock Divider)**. This IP is a fundamental block for UART (Universal Asynchronous Receiver-Transmitter) communication, responsible for dividing a high-speed system clock into a precise sampling clock (Baud Rate).

## 🗂️ Repository Structure

| Directory/File | Description |
| :--- | :--- |
| `rtl/` | Contains the source Verilog RTL code (`baud_gen_design.v`). |
| `tb/` | Contains the Verilog Testbench (`baud_gen_tb.v`) for verification. |
| `HOW_TO_SIMULATE.txt`| Instructions for user-defined clock frequencies. |
| `README.md` | This document. |

## 🛠️ Design & Verification Flow

### 1. RTL Design
The design implements a synchronous counter-based clock divider. It is highly flexible and uses a parameter `SYS_CLK_FREQ` to define the input clock speed. This allows the IP to be easily ported across different hardware platforms with varying oscillator frequencies.

### 2. Verification (Testbench)
The verification was conducted using a SystemVerilog testbench featuring:
* **Randomized Baud Rates:** To ensure robustness, the testbench randomizes the target baud rate. This verifies the IP's math logic under standard (e.g., 9600, 115200) and non-standard scenarios.
* **Accuracy Check:** Automated checkers compare the output pulse frequency against the theoretical division ratio to ensure zero-drift timing.

## ⚙️ User Customization (Quick Start)
New users can easily adapt this IP to their own systems by making a single-line change:
* **System Clock Change:** Update the `SYS_CLK_FREQ` value in both the RTL and Testbench (e.g., change `50_000_000` to your specific frequency like `100_000_000`).
* **Simulation Guide:** Refer to `HOW_TO_SIMULATE.txt` for detailed steps on re-running the simulation with custom parameters.

## 🚀 Clock Generator Introduction
A **Clock Generator** is the heartbeat of any digital system. In this project, the Baud Rate Generator acts as a specialized clock generator that provides the timing reference for serial data transmission, ensuring perfect synchronization between the transmitter and receiver.

## 🔗 Documentation & Professional Connect
For the full project documentation, including detailed waveforms and architecture diagrams, please visit:

* **Complete Documentation (LinkedIn):** [[www.linkedin.com/in/saikumarkonapala
](https://www.linkedin.com/posts/saikumarkonapala_design-verification-of-frequency-agile-activity-7413816233730600960-_kxO?utm_source=share&utm_medium=member_desktop&rcm=ACoAAFkpLvUBkmtYwqUIh5d25WFZXAZ6izhfEIA)
]
* **LinkedIn Profile:** [www.linkedin.com/in/saikumarkonapala

]

## 🔮 Future Scope
1. **Fractional Division:** Implementing a fractional-N divider to achieve higher precision for non-standard clock frequencies.
2. **Auto-Baud Detection:** Adding logic to automatically detect incoming baud rates from a serial stream.
3. **Low Power Mode:** Integrating clock-gating to save power during idle states when UART transmission is not active.

---
