% Test fft function (fft_float) 
% Added on 2025/07/02 by jihan 
 fft_mode = 0; % '0': ifft, '1': fft
 N = 512;

 if (fft_mode == 0)
    fft_coeff = 3; %ifft <10.3>
 else
    fft_coeff = 4; % fft<9.4>
 end

 %[cos_float, cos_fixed] = cos_in_gen(fft_mode, N);
 
 [ran_float, ran_fixed] = ran_in_gen_stu(fft_mode, N);

 [fft_out, module2_out] = fft_float(1, ran_float); % Floating-point fft (fft) : Cosine 

 [fft_out1, module2_out] = fft_fixed_stu(1, ran_fixed); % Fixed-point fft (fft) : Cosine 
 
 % MODULE 0

 merge_fft_logs_scaled('bfly00_out1_float.txt', 'bfly00_out1_fixed.txt', 'bfly00_out1.txt', 6);

 merge_fft_logs_scaled('bfly00_float.txt', 'bfly00_fixed.txt', 'bfly00_merge.txt', 6);

 merge_fft_logs_scaled('bfly01_tmp_float.txt', 'bfly01_tmp_fixed.txt', 'bfly01_tmp.txt', 6);

 merge_fft_logs_scaled('bfly01_float.txt', 'bfly01_fixed.txt', 'bfly01_merge.txt', 6);

 merge_fft_logs_scaled('bfly02_tmp_float.txt', 'bfly02_tmp_fixed.txt', 'bfly02_tmp.txt', 6);

 merge_fft_logs_scaled('bfly02_float.txt', 'bfly02_fixed.txt', 'bfly02_merge.txt', 6);

 % MODULE 1

 merge_fft_logs_scaled('bfly10_tmp_float.txt', 'bfly10_tmp_fixed.txt', 'bfly10_tmp.txt', 6);
 merge_fft_logs_scaled('bfly10_float.txt', 'bfly10_fixed.txt', 'bfly10_merge.txt', 6);

 merge_fft_logs_scaled('bfly11_tmp_float.txt', 'bfly11_tmp_fixed.txt', 'bfly11_tmp.txt', 6);

 merge_fft_logs_scaled('bfly11_float.txt', 'bfly11_fixed.txt', 'bfly11_merge.txt', 6);

 merge_fft_logs_scaled('bfly12_tmp_float.txt', 'bfly12_tmp_fixed.txt', 'bfly12_tmp.txt', 6);

 merge_fft_logs_scaled('bfly12_float.txt', 'bfly12_fixed.txt', 'bfly12_merge.txt', 6);

 % MODULE 2

 merge_fft_logs_scaled('bfly20_tmp_float.txt', 'bfly20_tmp_fixed.txt', 'bfly20_tmp.txt', 6);

 merge_fft_logs_scaled('bfly20_float.txt', 'bfly20_fixed.txt', 'bfly20_merge.txt', 6);

 merge_fft_logs_scaled('bfly21_tmp_float.txt', 'bfly21_tmp_fixed.txt', 'bfly21_tmp.txt', 6);

 merge_fft_logs_scaled('bfly21_float.txt', 'bfly21_fixed.txt', 'bfly21_merge.txt', 4);

 merge_fft_logs_scaled('bfly22_tmp_float.txt', 'bfly22_tmp_fixed.txt', 'bfly22_tmp.txt', 4);
 
 merge_fft_logs_scaled('bfly22_tmp_float.txt', 'bfly22_fixed.txt', 'bfly22_merge.txt', 4);

 %save_cosine_table('cosine_table.txt', cos_float, cos_fixed, fft_mode);

 data = readtable('bfly22_merge.txt', 'Delimiter', '\t');

 float_real = data.Float_Real;
 float_imag = data.Float_Imag;
 fixed_real = data.Fixed_Real;
 fixed_imag = data.Fixed_Imag;

 signal_power = mean(float_real.^2 + float_imag.^2);
 error_real = float_real - fixed_real;
 error_imag = float_imag - fixed_imag;
 noise_power = mean(error_real.^2 + error_imag.^2);

 if noise_power > 0
     sqnr_db = 10 * log10(signal_power / noise_power);
 else
     sqnr_db = inf;
 end

 fprintf('SQNR = %.2f dB\n', sqnr_db);

  
