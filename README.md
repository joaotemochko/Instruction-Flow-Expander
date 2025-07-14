# 🧠 Instruction Flow Expander (IFE)

The **Instruction Flow Expander (IFE)** is a microarchitecture component developed in **SystemVerilog**, designed to expand the instruction flow in parallel or out-of-order execution cores. It aims to increase pipeline throughput and efficiency.

This module is part of the **Alchemist** architecture but can be integrated into any CPU project with support for parallel execution, out-of-order (OoO) pipelines, or multiple functional units.

---

## 🚀 Purpose

To expand and organize the instruction stream after the fetch stage by providing:

- Parallel decoding of multiple instructions
- Distribution to issue queues or functional units
- Basic dependency detection
- Support for multi-issue cores (dual or more)

---

## 🛠️ Technologies Used

- **SystemVerilog** — RTL hardware description
- **Icarus Verilog** / **Verilator** — simulation
- **Yosys** + **Surelog** — SystemVerilog parsing and synthesis
- **GTKWave** — waveform visualization (VCD)
- (Optional) **Core-V-Verif** — verification framework

---

## 📁 Project Structure

```
ife/
├── src/
│   ├── ife_controller.sv       # Main control logic
│   ├── ife_decoder.sv          # Instruction decoder
│   ├── ife_dispatcher.sv       # Instruction dispatch logic
│   └── ife_pkg.sv              # Types, parameters, macros
├── testbench/
│   ├── ife_tb.sv               # Main testbench
│   └── test_vectors.sv         # Test cases
├── docs/
│   └── ife_spec.md             # Technical specification
├── README.md
└── Makefile                    # Build and simulation
```

---

## ⚙️ How to Use

### 💡 Integration

The IFE module can be instantiated as part of the decode or dispatch stage in any multi-issue pipeline.

---

## 📚 Documentation

Detailed technical documentation is available at [`docs/ife_spec.md`](docs/ife_spec.md), including:

- Interface (inputs/outputs)
- Communication protocols
- Latency and throughput
- Example usage

---

## ✅ Status

- [ ] Basic structure implemented
- [ ] Functional testbench
- [ ] Register renaming support
- [ ] Priority-based dispatch optimization
- [ ] Integration with Reorder Buffer

---

## 🧪 Roadmap

- Support for compressed instructions (RVC)
- Advanced RAW/WAW/WAR hazard detection
- Reorder buffer awareness
- Parametrizable issue width (dual, quad, etc.)

---

## 🤝 Contributing

At the moment, only my contributions are accepted, when implemented and tested I will accept new contributions.

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

