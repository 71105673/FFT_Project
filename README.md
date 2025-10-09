# FFT_Project

이 프로젝트는 **SystemVerilog 기반 512포인트 FFT 프로세서**를 **Convergent Block Floating Point (CBFP)** 방식으로 구현한 FPGA 설계 프로젝트입니다.  
Vivado 2020.2 환경에서 테스트되었으며, **고성능 연산과 파이프라인 처리**에 중점을 두었습니다.

---

## 팀원
| 정민교 | 엄찬하 | 신상학 | 임재홍 |
|--------|--------|--------|--------|
| Team Leader <br> Algorithm Designer | RTL Design Engineer <br> Algorithm Designer | RTL Design Engineer | RTL Design Engineer |
| <img src="image/profile/민교.png" width="240" height="160"> | <img src="image/profile/엄찬하.JPG" width="240" height="160"> | <img src="image/profile/상학.png" width="240" height="160"> | <img src="image/profile/재홍.png" width="240" height="160"> |


### 정민교 
- Tram Leader <br>
- Butterfly Calculation Module RTL Desgin <br> 
- FPGA targeting

### 엄찬하 
- DSP Algorithm Analysis <br>
- BFP-based FFT Fixed point modeling <br>
- CBFP Module RTL Desgin <br>
- Bit reverse RTL Desgin <br>

### 신상학 
- CBFP Module RTL Desgin <br>
- Butterfly Calculation Module & Bit reverse RTL Desgin

### 임재홍 
- Gate simulation & Debugging

---

## 프로젝트 개요


본 프로젝트는 **N = 512 포인트 FFT**를 CBFP 방식으로 구현한 FPGA 설계입니다.  

본 프로젝트에서는 BFP(Block Floating Point) 기반 Radix-2² 구조의 FFT를 대상으로 MATLAB 환경에서 Floating 모델을 Q-format 기반 Fixed-point 모델로 변환하여 알고리즘 수준의 사전 검증(High-level verification) 을 수행하였다. 이어서 CBFP(Combined Block Floating Point) 모델의 Fixed-point 구현을 적용하여 BFP와 CBFP 알고리즘 간 성능을 비교하였다.

CBFP 모델을 기반으로 RTL 설계 및 합성을 진행하고, 이를 통해 setup time violation, Area, Latency 등의 특성을 분석하였다. 마지막으로 게이트 레벨 시뮬레이션과 FPGA Targeting을 수행하여 RTL 설계의 기능적 타당성을 검증하였다.

FFT 프로세서는 다음 기능을 수행합니다:

- **FFT 처리** 및 CBFP 스케일링
- **Twiddle Factor를 이용한 복소수 곱 연산**
- **Leading Zero Detection**을 통한 정규화
- **Fixed-point 연산** 
- **파이프라인 아키텍처** 적용으로 고속 연산 달성
- **연속 읽기/쓰기 가능 구조**로 안정적인 데이터 처리

FPGA 구현에 최적화되어 있으며, **자원 사용, 타이밍, 연산 정확도**를 균형 있게 설계했습니다.


## 💻 개발 환경

| 구분        | 사용 도구 / 언어 |
|-------------|------------------|
| **EDA Tools** | Xilinx Vivado HLx Editions, Synopsys VCS, Synopsys Verdi |
| **Languages** | SystemVerilog, MATLAB |
| **IDE / Tools** | Visual Studio Code, MobaXterm |

### 모델링 및 알고리즘 설계
 - **MATLAB** (Floating/Fixed-point 모델링 및 High-level verification)
 
### 시뮬레이션 및 검증
- Synopsys VCS (RTL 및 게이트 레벨 논리 시뮬레이션)
- Synopsys Verdi (파형 분석 및 디버깅)

### 개발 툴 및 편집기
- MobaXterm (원격 개발 환경)
- Visual Studio Code (RTL 및 스크립트 편집)

### 합성 및 게이트 시뮬레이션
- Synopsys Design Compiler (합성)
- Synopsys VCS/Verdi (게이트 레벨 시뮬레이션)
### FPGA 타겟팅
- Xilinx Vivado (Bitstream 생성)

### 하드웨어 플랫폼
-Avnet UltraZed-7EV Carrier Card

---

## 주요 특징

- **모듈화 설계**: Twiddle 곱셈, 정규화, 버퍼링 모듈 분리
- **Fixed-point 정밀도 유지**: 부동소수점 연산 없이 CBFP FFT 정확도 확보
- **테스트벤치 제공**: 512 샘플 입력으로 기능 검증
- **출력 검증**: 정규화된 FFT 출력값과 인덱스를 파일로 기록

---

## 학습 포인트

- **CBFP 스케일링 적용**: 블록 기반 FFT에서 정밀도 유지
- **파이프라인 Fixed-point 모듈 설계**로 타이밍 제약 충족
- **FPGA 최적화 경험**: 리소스 배분, 병렬 처리 설계
- **SystemVerilog 모듈화 설계 및 검증 경험** 습득
- MATLAB 기반 **Fixed-point 코드와 모듈화 설계 연계**

---

## MATLAB 구성

- **FFT_M**  
  - `fft_fixed_3` → 메인 Fixed-point 코드
- **FFT_Pro_M**  
  - CBFP 적용 Module 설계

---


## 📋 System Verilog 시스템 구성

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
## 참고
자세한 내용은 PPT를 확인해 주세요


## 개발 과정

### (1) Fixed Point Modeling 
|---|---|
| ![alt text]("image/profile/Fixed Point/BFP.png") | ![alt text]("image/profile/Fixed Point/CBFP.png") |


- Float 모델은 정확한 실숫값들의 연산으로 알고리즘을 확인해 가며 원하는 출력을 만들어 내는지 시뮬레이션을 진행할 수 있습니다.

- Fixed 모델은 완성된 float 모델을 고정 소수점을 사용하여 정숫값들의 연산으로 수정한 모델로, 비트들로 이루어진 연산을 수행하는 하드웨어에서의 연산을 미리 시뮬레이션할 수 있습니다.

- 고정 소수점으로 실수값들을 정수로 나타낼때는 부호비트와 정수비트 그리고 소수비트로 구성됩니다. 이떄 정수비트와 소수비트를 나타낼때는 실수값을 기준으로 포멧을 정하여 정해진 비트로 나타냅니다.

- Fixed 모델로 작성된 MATLAB코드를 해석하면서 알게 된것은 사칙연산 과정 특히 곱셈 과정에서 비트가 크게 증가하게 되기에, 이것을 Saturaion과정과 Round 과정을 거쳐야 비트수를 줄일수 있게 되어 하드웨어 구현에서 크기를 줄이고 속도를 올릴며 전력소모를 줄일수 있습니다.

- Fixed 모델에 cos 데이터를 512개로 샘플링한 데이터와 랜덤입력을 넣어 나온 결과를 SQNR 과정을 거쳐 정확도를 비교 했을때 랜덤입력에서 정확도 dB값이 낮게 나온것을 확인 하였습니다. 이는