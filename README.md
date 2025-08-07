# FFT_Project# FFT_Project

### MATLAB

**FFT_M**

└── fft_fixed_3** -> 작성한 메인 fixed code

**FFT_Pro_M**

└── CBFP를 적용한 Module

## System Verilog

### 📋 시스템 구성

```
📁 FFT_ASIC/
├── 📁RTL   # RTL Level Module 저장소
│   ├── Module0
│   │      └── sdf1.sv
│   │            └──top_module_02_cbfp.sv
│   │                        └── cbfp.sv
│   │                        └── complex_multiplier_02.sv
│   │                        └── twiddle512.sv
│   ├── Module1
│   │      └── sdf2.sv
│   │            └──top_module_12_cbfp.sv
│   │                        └── cbfp1.sv 
│   │                        └── complex_multiplier_12.sv
│   │                        └── twiddle64.sv
│   ├── Module2
│   │      └── sdf3.sv
│   ├── share        # 모듈 공용 사용
│   └── top_module   # 최종 구성 탑 모듈
│ 
└── 📁 Synthesis        # 합성을 위한 파일 모음
│           └── fft_top.list    # file list
│           └── fft_top.sdc     # timing file
│           └── fft_top.tcl     # script file
│           └── fft_top.dc      # 합성 결과 파일
│   
└── 📁 output_fft_top   
│           └── fft_top.timing_max.rpt  # setup
│           └── fft_top.timing_max.rpt  # hold
│
└── 📁 schematic    

```