onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib vio_fft_opt

do {wave.do}

view wave
view structure
view signals

do {vio_fft.udo}

run -all

quit -force
