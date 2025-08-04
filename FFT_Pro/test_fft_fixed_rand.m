% --- 두 개의 파일에서 데이터 읽기 ---
% 실수부 데이터 (ran_q_dat_stu.txt) 읽기
real_input_file = './test_vector/ran_q_dat_stu.txt';
fid_imag = fopen(real_input_file, 'r');
raw_data_imag = textscan(fid_imag, '%d');
fclose(fid_imag);

% 허수부 데이터 (ran_i_dat_stu.txt) 읽기
imag_input_file = './test_vector/ran_i_dat_stu.txt';
fid_real = fopen(imag_input_file, 'r');
raw_data_real = textscan(fid_real, '%d');
fclose(fid_real);

% 데이터를 double 타입으로 변환
input_data_real_double = double(raw_data_real{1});
input_data_imag_double = double(raw_data_imag{1});

% 실수부와 허수부를 합쳐 복소수 데이터 생성
rand_fixed = input_data_real_double + 1j * input_data_imag_double;

% --- FFT 실행 ---
fft_mode = 1; % '0': ifft, '1': fft
[fft_out, module2_out] = fft_fixed_stu_2(fft_mode, rand_fixed);

% --- FFT 결과를 텍스트 파일로 저장 ---
output_file = './output_ran_fixed.txt';
fid_out = fopen(output_file, 'w');

% FFT 결과의 실수부와 허수부를 분리
fft_out_re = real(fft_out);
fft_out_im = imag(fft_out);

% 각 줄에 실수부와 허수부를 공백으로 구분하여 씁니다.
for k = 1:length(fft_out)
    fprintf(fid_out, '%f %f\n', fft_out_re(k), fft_out_im(k));
end

fclose(fid_out);

disp(['FFT 결과가 ', output_file, ' 파일에 성공적으로 저장되었습니다.']);