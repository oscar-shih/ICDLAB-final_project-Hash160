# ICDLAB-final_project-HASH160

**Team Member: 石旻翰、蔡帛恩、楊翔淳、王政邦**

NTUEE IC Design Lab 2022spring Final Project -HASH160 prof.Tzi-Dar, Chiueh
## Enviroment Setting(Suggestion)
OS: Ubuntu 20.04 LTS 

GCC Version: 9.4.0 

Python Version: 3.7+

### DRC/LVS
1. DRC:
* http://www2.cic.org.tw/~shuttle/drc/all/U18.pdf
* Compare the DRC_error.txt to this PDF, there is no violation.
2. LVS:
* It shows a smile face in lvs_test.rep, so it is passed.


### How to run CHIP.v Posim
```bash
ncverilog top_tb.v CHIP.v -v fsa0m_a_generic_core_21.lib.src fsa0m_a_t33_generic_io_21.lib.src +define+SDF
```

### How to run top_syn.v
```bash
ncverilog +access+r top_tb.v top_syn.v fsa0m_a_generic_core_21.lib.src +define+SDF
```

### How to run SHA256
```bash
cd SHA256 && gcc sha256.c main.c -o sha256
```
```bash
./sha256 <message>
```
### How to run RIPEMD160
```bash
cd RIPEMD160 && g++ main.cpp -o ripemd160
```
```bash
./ripemd160 <message>
```
