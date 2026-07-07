# Dual-Clock Asynchronous FIFO

A parameterized dual-clock asynchronous FIFO in Verilog, using Gray-coded pointers and double-flop synchronizers for safe clock-domain crossing between an independent write clock and read clock.

## Parameters

| Parameter | Value | Meaning |
|---|---|---|
| `DSIZE` | 8 | Data width (bits) |
| `ASIZE` | 3 | Address width (bits) → Depth = 2^ASIZE |
| Depth | 8 | Number of entries |
| `wclk` | 100 MHz | Write-domain clock |
| `rclk` | ~71 MHz | Read-domain clock (independent, asynchronous to `wclk`) |

Target: Xilinx Artix-7, Vivado 2020+

## Why This Design Exists

Crossing data between two clock domains that have no fixed phase relationship is unsafe with plain binary counters — a binary pointer can have multiple bits changing at once, and a synchronizer sampling mid-transition can capture a completely wrong value (not just an off-by-one). Gray-coded pointers guarantee only a single bit changes between any two adjacent values, so a metastable sample resolves to either the old or the new value — never garbage.

## Architecture Overview

- **`fifomem`** — the actual dual-port memory array (write port on `wclk`, read port on `rclk`)
- **`wptr_full`** — write-pointer logic (binary + Gray), full-flag generation
- **`rptr_empty`** — read-pointer logic (binary + Gray), empty-flag generation
- **`sync_r2w`** — double-flop synchronizer bringing the Gray read pointer into the write clock domain
- **`sync_w2r`** — double-flop synchronizer bringing the Gray write pointer into the read clock domain
- **`async_fifo_top`** — top-level integration of all of the above

## The Math Behind Full and Empty Flags

With Gray-coded pointers of width `ASIZE+1` (one extra MSB beyond the address bits):
- **Empty**: synchronized write pointer (in read domain) equals the read pointer exactly (all bits, including the extra MSB).
- **Full**: synchronized read pointer (in write domain) equals the write pointer with the top two MSBs inverted relative to the rest matching — i.e., the wrap bit differs but the address bits match. This extra MSB is what disambiguates "pointers equal because full" from "pointers equal because empty."

## Gray Code — The Core Trick

Binary → Gray conversion (`gray = binary ^ (binary >> 1)`) ensures adjacent counter values differ in exactly one bit. This is what makes it safe to synchronize a multi-bit counter across a clock boundary with simple double-flop synchronizers, since only one bit is ever in flux at the sampling edge.

## Verification

7 self-checking test cases exercising:
1. Basic write/read at matched throughput
2. Full-flag assertion when FIFO is at capacity
3. Empty-flag assertion when FIFO is drained
4. Simultaneous write/read at the boundary conditions
5. Back-to-back full → read → write recovery
6. Reset behavior in both clock domains
7. Sustained random read/write traffic across mismatched clock rates (100 MHz / 71 MHz) checked against a scoreboard/golden model

## Synthesis & Implementation

- Tool: Vivado 2020+ (specify your exact version in the report)
- Target: Xilinx Artix-7
- Include utilization and timing closure numbers once generated (see `impl/reports/`)

## Repository Structure

```
dual-clock-async-fifo/
├── README.md
├── rtl/
│   ├── fifomem.v
│   ├── wptr_full.v
│   ├── rptr_empty.v
│   ├── sync_r2w.v
│   ├── sync_w2r.v
│   └── async_fifo_top.v
│
├── sim/
│   ├── tb_async_fifo.v               # Or split per-case if you prefer
│   ├── waveforms/                    # Screenshots per test case (1-7 above)
│   └── logs/                         # Console pass/fail transcripts
│
├── synth/
│   ├── constraints/
│   │   └── async_fifo.xdc
│   └── reports/
│       └── utilization_synth.rpt
│
├── impl/
│   ├── reports/
│   │   ├── utilization_impl.rpt
│   │   └── timing_summary_impl.rpt
│   └── screenshots/
│       └── routed_device_view.png
│
└── docs/
    └── gray_code_full_empty_derivation.md   # Optional: the math writeup above, expanded
```

### Notes on ordering
Same flow as the CPU project: `rtl/` → `sim/` → `synth/` → `impl/`. Since this is a smaller, well-contained module, you could also flatten `sim/waveforms` and `sim/logs` directly under `sim/` if you have only a handful of screenshots — don't over-nest a small project.
