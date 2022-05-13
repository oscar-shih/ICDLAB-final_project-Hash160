指令
```bash
source /usr/cadence/cshrc
```
```bash
source /usr/cad/synopsys/CIC/synthesis.cshrc
```
```bash
ncverilog +access+r stage_1_tb.v stage_1_test.v
```
```bash
ncverilog +access+r stage_1_tb.v stage_1_test_syn.v fsa0m_a_generic_core_21.lib.src +define+SDF
```
```bash
ncverilog +access+r ripemd_final_tb.v ripemd_final_syn.v fsa0m_a_generic_core_21.lib.src +define+SDF
```
https://www.esat.kuleuven.be/cosic/publications/article-317.pdf
