# FFT_Project# FFT_Project

이 저장소는 **SystemVerilog 기반 512포인트 FFT 프로세서**를 **Convergent Block Floating Point(CBFP)** 방식으로 구현한 프로젝트입니다.  
FPGA 플랫폼에서 동작하도록 설계되었으며(Vivado 2020.2 테스트 완료), 고성능과 파이프라인 처리에 중점을 두었습니다.

## 프로젝트 개요

FFT 프로세서는 다음 주요 기능을 수행합니다:

- **16포인트 블록 FFT 처리** 및 CBFP 스케일링
- **Twiddle Factor를 이용한 복소수 곱 연산**
- **Leading Zero Detection**을 통한 정규화
- **Fixed-point 연산** (`<1.6>` 및 `<8.14>` 형식 사용)
- **파이프라인 아키텍처** 적용으로 높은 처리 속도 달성
- **연속 읽기/쓰기 가능** 구조

FPGA 구현에 최적화되어 있으며, **자원 사용, 타이밍, 연산 정확도**를 균형 있게 설계했습니다.

## 주요 특징

- **모듈화 설계**: Twiddle 곱셈, 정규화, 버퍼링 모듈 분리
- **Fixed-point 정밀도 유지**: 부동소수점 연산 없이 CBFP FFT 정확도 확보
- **테스트벤치 제공**: 512 샘플 입력으로 기능 검증
- **출력 검증**: 정규화된 FFT 출력값과 인덱스를 파일로 기록

## 프로젝트 학습 포인트

- **CBFP 스케일링**을 활용한 블록 기반 FFT 정밀도 유지
- **파이프라인 Fixed-point 모듈 설계**로 타이밍 제약 충족
- FPGA 최적화 경험: 리소스 배분, 병렬 처리 설계
- **SystemVerilog 모듈화 설계 및 검증 경험** 습득

### MATLAB

**FFT_M**

└── fft_fixed_3** -> 작성한 메인 fixed code

**FFT_Pro_M**

└── CBFP를 적용한 Module

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
