% reorder_index.txt에서 복소수값 읽어오기
fid = fopen('float_reorder_index.txt', 'r');
data = textscan(fid, 'jj=%d, kk=%d, dout(%d)=%f+j%f');
fclose(fid);

% 실수부 + 허수부로 복소수 벡터 생성
real_part = data{4};
imag_part = data{5};
fft_result = complex(real_part, imag_part);
N = length(fft_result);  % 예: 512

% Magnitude spectrum
figure;
plot(0:N-1, abs(fft_result));
title('FFT Magnitude Spectrum');
xlabel('Frequency Bin');
ylabel('|FFT Output|');
grid on;