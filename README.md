# Analog Lead Compensator Controller (Plant + Compensator)

This repository documents an end-to-end control + hardware workflow: **designing a lead compensator**, validating it at **model-level (MATLAB/Simulink)** and **circuit-level (SPICE tools)**, and implementing it as an **op-amp analog controller** on a **KiCad PCB**.

A benchmark plant model is used as the baseline system:

$$
G(s)=\frac{2}{s(s+1)}
$$

---

## System overview (what is being built)
The project compares two closed-loop configurations under the same input:

1. **Uncompensated loop:** plant-only closed-loop response  
2. **Compensated loop:** plant + lead compensator closed-loop response  

This block-level structure is implemented and cross-validated across tools:

<p align="center">
  <img src="docs/images/block-diagram.png" width="900">
</p>

---

## What this project is (and why it matters)
A **lead compensator** adds **phase lead** in a chosen frequency range. Practically, it helps achieve:
- **faster transient response** (shorter settling time),
- **reduced overshoot**,
- improved stability margins when the baseline plant dynamics are “too slow” or “too oscillatory”.

### Why this plant?
The plant

`G(s) = 2 / (s(s+1))`

was chosen deliberately because it is a **clean benchmark** that exposes the core trade-offs a lead compensator is meant to address:
- The `1/s` term introduces an **integrator**, which is a common structure when the system output represents an accumulated quantity (position/angle/level).
- The `1/(s+1)` term adds a **dominant first-order lag**, a very typical dynamic limitation in real systems.
- Together, this plant is simple enough to analyze clearly, yet rich enough to show meaningful improvements in transient behavior when compensation is applied.

In short: it’s an intentional baseline that makes controller impact measurable and transferable.

---

## Design goals
The project is built around a single, clear comparison:
- **Uncompensated (plant-only)** response
vs.
- **Compensated (plant + lead compensator)** response

with the intent to improve transient performance (reduced overshoot, faster settling) while keeping the design implementable in analog hardware.

---

## Control design method (Root Locus)
The compensator was selected using **Root Locus–based design**, specifically:
- **Dominant pole targeting:** choose desired dominant closed-loop pole locations that meet transient expectations (overshoot/settling trade-off).
- **Angle condition:** determine where a compensator zero/pole should be placed so the desired pole location satisfies the Root Locus angle requirement.
- **Magnitude condition:** compute the required gain so the point lies on the locus.

This approach links performance objectives directly to pole locations and results in a compensator that is both analyzable and implementable.

---

## Verification workflow (MATLAB → Simulink → SPICE tools)
This project intentionally uses multiple tools because each one answers a different question. Using only one would leave blind spots.

### 1) MATLAB (calculation sanity-check)
MATLAB is used to verify the math: pole/zero placement logic, gain consistency, and quick numeric checks. This prevents “it looks right” errors before simulation.

### 2) Simulink (system-level behavior)
Simulink is used to observe **signals and step responses** in a clean block-diagram environment and to compare compensated vs. uncompensated outputs under the same stimulus.

<p align="center">
  <img src="docs/images/plant-comp-out.png" width="900">
</p>

### 3) LTspice (ideal circuit-level cross-check)
LTspice is used to rebuild the control structure as **ideal analog circuits**, for two reasons:
- It verifies the design **at circuit level** (not only transfer-function level).
- It enables quick iteration and clean A/B comparison of plant-only vs. compensated behavior.

### 4) Proteus (practical pre-PCB simulation + switching)
Proteus is used as the “last realism check” before committing to PCB:
- It supports a **switch-based** workflow: using a DPDT switch model to **toggle between plant-only and compensated paths**, enabling direct comparison with the same source/instrumentation.
- It is also convenient for validating the integrated circuit behavior and wiring logic in a more “lab-like” simulation setup.

In short:
- **LTspice (SPICE tool)** = ideal, controlled circuit verification and fast iteration  
- **Proteus (SPICE tool)** = integrated validation with switching and final pre-PCB confidence

---

## Hardware implementation (Analog + PCB)
After validating behavior in simulation, the controller is implemented using **op-amp analog circuitry** and captured in KiCad as:
- schematic,
- PCB layout and routing,
- manufacturing-ready board representation.

A key constraint throughout the hardware step is **real-world component availability**:
- Some ideal resistor values from initial calculations are not standard off-the-shelf values.
- Where needed, values are realized using **series/parallel combinations** (documented/verified at simulation stage before PCB finalization).

<p align="center">
  <img src="docs/images/board-3d-isometric.png" width="900">
</p>

> Fabrication note: The current PCB is a **2-layer** design. If single-sided fabrication is required, it will generally need rerouting and/or jumpers.

---

## Reproducibility (how to run / view everything)
This repo is structured so each stage can be opened independently.

### MATLAB / Simulink
Folder: `matlab-simulink/`
- `lead_compensator.m` → calculation/verification script
- `plant_comp.slx` → compensated system model
- `uncomp_step_response.slx` → baseline (plant-only) response model

Open in MATLAB/Simulink and run the script/models to reproduce the response comparison.

### LTspice
Folder: `ltspice/`
- `lead-compensator.asc` → circuit file

Open in LTspice and run the transient simulation to inspect waveforms.

### Proteus
Folder: `proteus/`
- `lead-compensator.pdsprj` → project file (includes switch-based comparison setup)

Open in Proteus, run simulation, and toggle the switch to compare modes.

### KiCad
Folder: `kicad/`
- `lead_compensator.kicad_sch` → schematic
- `lead_compensator.kicad_pcb` → PCB layout
- `lead_compensator.kicad_pro` → project settings

Open the `.kicad_pro` project file in KiCad, then inspect schematic/PCB.

---

## Repository structure
- `docs/images/` → curated images used in README
- `kicad/` → KiCad schematic + PCB
- `matlab-simulink/` → MATLAB + Simulink models
- `ltspice/` → LTspice circuit (SPICE tool)
- `proteus/` → Proteus project (SPICE tool)

---

## Tools
**MATLAB, Simulink, LTspice (SPICE tool), Proteus (SPICE tool), KiCad**

---

## Keywords (for recruiters and technical readers)
Root Locus, dominant poles, angle condition, magnitude condition, lead compensator, transient response, overshoot, settling time, circuit-level validation, op-amp analog implementation, PCB design, DRC-clean layout, end-to-end engineering workflow.
