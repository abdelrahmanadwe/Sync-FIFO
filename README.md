# 🚀 Synchronous FIFO Verification Project

**Author:** [Abdelrahman Adw Ali](https://github.com/abdelrahmanadwe)
**Project Repository:** [github.com/abdelrahmanadwe/Sync-FIFO](https://github.com/abdelrahmanadwe/Sync-FIFO/)

---

## 📖 Table of Contents
1. [About The Project](#about-the-project)
2. [FIFO Specifications](#fifo-specs)
3. [Testbench Architecture](#tb-architecture)
4. [Bugs Found](#bugs-found)
5. [Coverage Results](#coverage-results)
6. [How to Run](#how-to-run)

---

<a name="about-the-project"></a>
## 🌟 1. About The Project

The goal of this project is to build a complete testbench using SystemVerilog to verify a Synchronous First-In, First-Out (FIFO) design.

The testbench was built to perform the following:
* **Randomized Stimuli Generation:** To test the DUT (Design Under Test) in various scenarios.
* **Result Checking:** By building a reference model (Scoreboard) to compare the DUT's expected behavior with its actual behavior.
* **Coverage Collection:** To ensure all design functionalities and states are tested.
* **Assertions:** To continuously monitor the FIFO's internal behavior and flags.

---

<a name="fifo-specs"></a>
## 🛠️ 2. FIFO Specifications

The DUT is a Synchronous FIFO with the following specifications and ports:

### Parameters
* `FIFO_WIDTH`: Data in/out and memory word width (Default: 16)
* `FIFO_DEPTH`: Memory depth (Default: 8)

### Input Ports
* `clk`: Clock signal
* `rst_n`: Active low asynchronous reset
* `data_in`: Write Data
* `wr_en`: Write Enable
* `rd_en`: Read Enable

### Output Ports
* `data_out`: Read Data
* `full`: Full Flag (indicates FIFO is full)
* `empty`: Empty Flag (indicates FIFO is empty)
* `almostfull`: Almost Full Flag (indicates one space left)
* `almostempty`: Almost Empty Flag (indicates one item left)
* `wr_ack`: Write Acknowledge (write succeeded)
* `overflow`: Overflow Flag (write attempt while full)
* `underflow`: Underflow Flag (read attempt while empty)

---

<a name="tb-architecture"></a>
## 🏗️ 3. Testbench Architecture

The Verification Environment was built using SystemVerilog Classes in a UVM-like structure to ensure separation of concerns and reusability.

### Environment Components (File Structure)

* **[`fifo_top.sv`](https://github.com/abdelrahmanadwe/Sync-FIFO/tree/main/Sync%20FIFO/fifo_top.sv)**: The top-level module that connects all components (DUT, Interface, Test, Monitor).
* **[`fifo_if.sv`](https://github.com/abdelrahmanadwe/Sync-FIFO/tree/main/Sync%20FIFO/fifo_if.sv)**: The SystemVerilog interface containing all FIFO signals, used to connect the DUT to the testbench.
* **[`FIFO.sv`](https://github.com/abdelrahmanadwe/Sync-FIFO/tree/main/Sync%20FIFO/FIFO.sv)**: The RTL design file (DUT) with embedded SystemVerilog Assertions (SVA).
* **[`fifo_transaction_pkg.sv`](https://github.com/abdelrahmanadwe/Sync-FIFO/tree/main/Sync%20FIFO/fifo_transaction_pkg.sv)**: Contains the `fifo_transaction` class. This class holds all FIFO variables and includes constraints for randomization.
* **[`fifo_test.sv`](https://github.com/abdelrahmanadwe/Sync-FIFO/tree/main/Sync%20FIFO/fifo_test.sv)**: Applies reset, then randomizes the `fifo_transaction` class and drives the inputs to the DUT via the interface.
* **[`fifo_monitor.sv`](https://github.com/abdelrahmanadwe/Sync-FIFO/tree/main/Sync%20FIFO/fifo_monitor.sv)**: Monitors the interface, samples all signals at every `negedge clk`, creates a transaction, and sends it to the scoreboard and coverage collector.
* **[`fifo_scoreboard_pkg.sv`](https://github.com/abdelrahmanadwe/Sync-FIFO/tree/main/Sync%20FIFO/fifo_scoreboard_pkg.sv)**: Contains the `fifo_scoreboard` class. This class includes a **Reference Model** (Golden Model) built using a `queue`. It compares the DUT's actual outputs with the reference model's expected outputs and maintains `error_count` and `correct_count`.
* **[`fifo_coverage_pkg.sv`](https://github.com/abdelrahmanadwe/Sync-FIFO/tree/main/Sync%20FIFO/fifo_coverage_pkg.sv)**: Contains the `fifo_coverage` class, which includes a `covergroup`. It collects functional coverage, specifically `cross coverage` between `wr_en`, `rd_en`, and all output flags.
* **[`shared_pkg.sv`](https://github.com/abdelrahmanadwe/Sync-FIFO/tree/main/Sync%20FIFO/shared_pkg.sv)**: A package containing shared variables like `error_count`, `correct_count`, and `test_finished`.

---

<a name="bugs-found"></a>
## 🐞 4. Bugs Found and Fixed

During the verification process, the testbench successfully identified several bugs in the original RTL design. These bugs were documented and subsequently fixed in [`FIFO.sv`](https://github.com/abdelrahmanadwe/Sync-FIFO/blob/main/FIFO.sv).

**List of Detected Bugs:**
1.  `wr_ack` was not asserted `Low` when reset was asserted.
2.  `overflow` was not asserted `Low` when reset was asserted.
3.  `overflow` was not asserted `Low` when the FIFO was not full.
4.  `underflow` was not asserted `Low` when reset was asserted.
5.  `underflow` was not asserted `Low` when the FIFO was not empty.
6.  The `underflow` output was Combinational instead of Sequential.
7.  `data_out` was not `Low` when reset was asserted.
8.  An uncovered case was found where `wr_en` and `rd_en` were high simultaneously:
    * When the FIFO is full, a read process should occur.
    * When the FIFO is empty, a write process should occur.
9.  `almostfull` was high when two spots were empty, but it should be high when only one spot is empty.

---

<a name="coverage-results"></a>
## 📊 5. Coverage Results

The project successfully achieved **100%** across all required coverage metrics, ensuring the design was thoroughly tested. (Screenshots of the reports are available in the project submission PDF).

* **Functional Coverage:** 100%
    * All Coverpoints and Crosses defined in **[`fifo_coverage_pkg.sv`](https://github.com/abdelrahmanadwe/Sync-FIFO/tree/main/Sync%20FIFO/fifo_coverage_pkg.sv)** were fully covered.

* **Code Coverage:** 100%
    * **Statement Coverage:** 100%
    * **Branch Coverage:** 100%
    * **Condition Coverage:** 100%
    * **Toggle Coverage:** 100%

* **Assertion Coverage:** 100%
    * All SVA (SystemVerilog Assertions) added to **[`FIFO.sv`](https://github.com/abdelrahmanadwe/Sync-FIFO/tree/main/Sync%20FIFO/FIFO.sv)** were enabled and passed without any failures.

---

<a name="how-to-run"></a>
## 🏁 6. How to Run

To run the simulation and view the results:

### Prerequisites
* A SystemVerilog simulator, such as **QuestaSim**, is required.

### Running the Simulation
1.  Clone the repository:
    ```sh
    git clone [https://github.com/abdelrahmanadwe/Sync-FIFO.git](https://github.com/abdelrahmanadwe/Sync-FIFO.git)
    cd Sync-FIFO
    ```
2.  Open QuestaSim in the project directory.
3.  In the QuestaSim Transcript window, execute the following command:
    ```sh
    do run.do
    ```
4.  The **[`run.do`](https://github.com/abdelrahmanadwe/Sync-FIFO/tree/main/Sync%20FIFO/run.do)** script will perform the following actions:
    * Create the `work` library.
    * Compile all SV files listed in **[`fifo_files.list`](https://github.com/abdelrahmanadwe/Sync-FIFO/tree/main/Sync%20FIFO/fifo_files.list)** with coverage enabled (`+cover`) and the `SIM` macro defined (to enable assertions).
    * Load the simulation for `work.fifo_top`.
    * Add key signals to the wave window.
    * Run the simulation to completion (`run -all`).
    * Save the coverage database as `fifo.ucdb` on exit.
5.  After the simulation finishes, the monitor will display a message with the error and correct counts. You can then open the generated `fifo.ucdb` file to view detailed coverage reports.
