% Test fft function (fft_matlab vs. fft_manual) 
% Added on 2025/07/02 by jihan 
 N = 512;
 fft_mode = 1;
 [ran_float, ran_fixed] = ran_in_gen_stu(fft_mode, N);
 [cos_float, cos_fixed] = cos_in_gen(fft_mode, N);


if (fft_mode == 0)
    fft_coeff = 8;
else
    fft_coeff = 16;
end

 mat_float_fft = fft(ran_float); % Matlab fft (Random, Floating-point)
% mat_float_fft = fft(cos_float); % Matlab fft (Cosine, Floating-point)

 [fft_out, module2_out] = fft_float(1, ran_float); % Floating-point fft (fft) : Cosine 
 [fft_out_fixed, module2_out_fixed] = fft_fixed_stu(fft_mode, ran_fixed); % Fixed-point fft (Random, fft)
% [fft_out_fixed, module2_out_fixed] = fft_fixed_stu(fft_mode, cos_fixed); % Fixed-point fft (Cosine, fft)
 fft_out_fixed = fft_out_fixed/fft_coeff; % Modified on 2025/07/02 by jihan

  fp_1=fopen('sqnr_fft.txt','w');
  for ii=1:N
   sig_pow(ii) = power(real(mat_float_fft(ii)),2) + power(imag(mat_float_fft(ii)),2);
   noise_re(ii) = real(mat_float_fft(ii)) - real(fft_out_fixed(ii));
   noise_im(ii) = imag(mat_float_fft(ii)) - imag(fft_out_fixed(ii));
   noise_pow(ii) = power(noise_re(ii),2) + power(noise_im(ii),2);
   fprintf(fp_1,'sig_pow(ii)=%f, noise_pow(ii)=%f\n', sig_pow(ii), noise_pow(ii)); 
  end
  fclose(fp_1);

  tot_sig_pow = 0.0;
  tot_noise_pow = 0.0;
  for ii=1:N
   tot_sig_pow = tot_sig_pow + sig_pow(ii);
   tot_noise_pow = tot_noise_pow + noise_pow(ii);
  end

  snr_val = 10*log10(tot_sig_pow/tot_noise_pow);

 X=sprintf('tot_sig_pow=%f, tot_noise_pow=%f, snr_val=%f\n',tot_sig_pow, tot_noise_pow, snr_val);
 disp(X);


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
