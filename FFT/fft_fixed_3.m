function [fft_out, module2_out] = fft_fixed_3(fft_mode, fft_in)

 shift = 7;
 SIM_FIX = 1; % 0: float, 1: fixed

 if (fft_mode==1) % fft
   din = fft_in;
 else % ifft
   din = conj(fft_in);
 end

 fac8_0 = [1, 1, 1, -j];
 fac8_2 = [1, 1, 1, -j, 1, 0.7071-0.7071j, 1, -0.7071-0.7071j]; % <2.7>
 fac8_1 = round(fac8_2 * 128);  % fixed 전용 twiddle factor 
 %-----------------------------------------------------------------------------
 % Module 0
 %-----------------------------------------------------------------------------
 % step0_0 <3.6> + <3.6> = <4.6>
 bfly00_out0 = din(1:256) + din(257:512); % <4.6> 
 bfly00_out1 = din(1:256) - din(257:512); % <4.6> 
 
 bfly00_tmp = [bfly00_out0, bfly00_out1]; % <4.6> 

 for nn=1:512
   bfly00(nn) = bfly00_tmp(nn)*fac8_0(ceil(nn/128)); %  <4.6> 
 end
 
 % step0_1 <4.6> + <4.6> = <5.6>
 for kk=1:2 
  for nn=1:128
   bfly01_tmp((kk-1)*256+nn) = bfly00((kk-1)*256+nn) + bfly00((kk-1)*256+128+nn); 
   bfly01_tmp((kk-1)*256+128+nn) = bfly00((kk-1)*256+nn) - bfly00((kk-1)*256+128+nn);
  end
 end

 for nn=1:512
   bfly01(nn) = bfly01_tmp(nn)*fac8_1(ceil(nn/64)); % <7.13>
    % rounding, saturation <7.13> -> <7.6>
    real_01 = round(real(bfly01(nn)/2^shift));     
    imag_01 = round(imag(bfly01(nn)/2^shift));     

    if(real_01 > 4095)
        real_01 = 4095;
    elseif(real_01 < -4096)
        real_01 = -4096;
    end

    if(imag_01 > 4095)
        imag_01 = 4095;
    elseif(imag_01 < -4096)
        imag_01 = -4096;
    end

    bfly01(nn) = real_01 + 1j * imag_01; % <7.6>
 end % <7.6>


 % step0_2 <7.6> + <7.6> = <8.6>
 for kk=1:4
  for nn=1:64
   bfly02_tmp((kk-1)*128+nn) = bfly01((kk-1)*128+nn) + bfly01((kk-1)*128+64+nn);
   bfly02_tmp((kk-1)*128+64+nn) = bfly01((kk-1)*128+nn) - bfly01((kk-1)*128+64+nn);
  end
 end

 % Data rearrangement
 K3 = [0, 4, 2, 6, 1, 5, 3, 7];

 for kk=1:8
  for nn=1:64
   twf_m0((kk-1)*64+nn) = round(exp(-j*2*pi*(nn-1)*(K3(kk))/512) * 128); 
  end
 end

 for nn=1:512
    bfly02(nn) = bfly02_tmp(nn)*twf_m0(nn); % <8.6> x <2.7> = <10.13>
    real_02 = round(real(bfly02(nn)/2^shift));     % <10.6>
    imag_02 = round(imag(bfly02(nn)/2^shift));     % <10.6>

    if(real_02 > 1023)
        real_02 = 1023;
    elseif(real_02 < -1024)
        real_02 = -1024;
    end

    if(imag_02 > 1023)
        imag_02 = 1023;
    elseif(imag_02 < -1024)
        imag_02 = -1024;
    end

    bfly02(nn) = real_02 + 1j * imag_02; % <5.6>
 end
 
 %-----------------------------------------------------------------------------
 % Module 1
 %-----------------------------------------------------------------------------
 % step1_0 <5.6> + <5.6> = <6.6>
 for kk=1:8
  for nn=1:32
   bfly10_tmp((kk-1)*64+nn) = bfly02((kk-1)*64+nn) + bfly02((kk-1)*64+32+nn);
   bfly10_tmp((kk-1)*64+32+nn) = bfly02((kk-1)*64+nn) - bfly02((kk-1)*64+32+nn);
  end
 end

 for kk=1:8
  for nn=1:64
   bfly10((kk-1)*64+nn) = bfly10_tmp((kk-1)*64+nn)*fac8_0(ceil(nn/16)); % <6.6>
  end
 end

 % step1_1 <6.6> + <6.6> = <7.6>
 for kk=1:16 
  for nn=1:16
   bfly11_tmp((kk-1)*32+nn) = bfly10((kk-1)*32+nn) + bfly10((kk-1)*32+16+nn);
   bfly11_tmp((kk-1)*32+16+nn) = bfly10((kk-1)*32+nn) - bfly10((kk-1)*32+16+nn);
  end
 end

 for kk=1:8
  for nn=1:64
   bfly11((kk-1)*64+nn) = bfly11_tmp((kk-1)*64+nn)*fac8_1(ceil(nn/8)); % <7.6> X <2.7> = <9.13>
    real_11 = round(real(bfly11((kk-1)*64+nn)/2^shift));     % <9.6>
    imag_11 = round(imag(bfly11((kk-1)*64+nn)/2^shift));     % <9.6>

    if(real_11 > 4095)
        real_11 = 4095;
    elseif(real_11 < -4096)
        real_11 = -4096;
    end

    if(imag_11 > 4095)
        imag_11 = 4095;
    elseif(imag_11 < -4096)
        imag_11 = -4096;
    end

    bfly11((kk-1)*64+nn) = real_11 + 1j * imag_11; % <7.6>
  end 
 end

 % step1_2 <7.6> + <7.6> = <8.6>
 for kk=1:32
  for nn=1:8
   bfly12_tmp((kk-1)*16+nn) = bfly11((kk-1)*16+nn) + bfly11((kk-1)*16+8+nn);
   bfly12_tmp((kk-1)*16+8+nn) = bfly11((kk-1)*16+nn) - bfly11((kk-1)*16+8+nn);
  end
 end

 % Data rearrangement
 K2 = [0, 4, 2, 6, 1, 5, 3, 7];

 for kk=1:8
  for nn=1:8
   twf_m1((kk-1)*8+nn) = round(exp(-j*2*pi*(nn-1)*(K2(kk))/64) * 128); % <2.7> twiddle factor
  end
 end

 for kk=1:8
  for nn=1:64
    bfly12((kk-1)*64+nn) = bfly12_tmp((kk-1)*64+nn)*twf_m1(nn); % <8.6> X <2.7> = <10.13>
    real_12 = round(real(bfly12((kk-1)*64+nn)/2^shift));     % <10.6>
    imag_12 = round(imag(bfly12((kk-1)*64+nn)/2^shift));     % <10.6>

    if(real_12 > 2047)
        real_12 = 2047;
    elseif(real_12 < -2048)
        real_12 = -2048;
    end

    if(imag_12 > 2047)
        imag_12 = 2047;
    elseif(imag_12 < -2048)
        imag_12 = -2048;
    end
    bfly12((kk-1)*64+nn) = real_12 + 1j * imag_12; % <6.6>
  end
 end % <6.6> 

 %-----------------------------------------------------------------------------
 % Module 2
 %-----------------------------------------------------------------------------
 % step2_0 <6.6> + <6.6> = <7.6>
 for kk=1:64
  for nn=1:4
   bfly20_tmp((kk-1)*8+nn) = bfly12((kk-1)*8+nn) + bfly12((kk-1)*8+4+nn);
   bfly20_tmp((kk-1)*8+4+nn) = bfly12((kk-1)*8+nn) - bfly12((kk-1)*8+4+nn);
  end
 end

 for kk=1:64
  for nn=1:8
   bfly20((kk-1)*8+nn) = bfly20_tmp((kk-1)*8+nn)*fac8_0(ceil(nn/2));
  end
 end

 % step2_1 <7.6> + <7.6> = <8.6>
 for kk=1:128
  for nn=1:2
   bfly21_tmp((kk-1)*4+nn) = bfly20((kk-1)*4+nn) + bfly20((kk-1)*4+2+nn);
   bfly21_tmp((kk-1)*4+2+nn) = bfly20((kk-1)*4+nn) - bfly20((kk-1)*4+2+nn);
  end
 end

 for kk=1:64
  for nn=1:8
    bfly21((kk-1)*8+nn) = bfly21_tmp((kk-1)*8+nn)*fac8_1(nn); % <8.6> X <2.7> = <10.13>
    real_21 = round(real(bfly21((kk-1)*8+nn)/2^shift));     % <10.6>
    imag_21 = round(imag(bfly21((kk-1)*8+nn)/2^shift));     % <10.6>

    if(real_21 > 8191)
        real_21 = 8191;
    elseif(real_21 < -8192)
        real_21 = -8192;
    end

    if(imag_21 > 8191)
        imag_21 = 8191;
    elseif(imag_21 < -8192)
        imag_21 = -8192;
    end
    bfly21((kk-1)*8+nn) = real_21 + 1j * imag_21; % <8.6>
  end
 end


 % step2_2 <8.6> + <8.6> = <9.6>
 for kk=1:256
   bfly22_tmp((kk-1)*2+1) = bfly21((kk-1)*2+1) + bfly21((kk-1)*2+2);
   bfly22_tmp((kk-1)*2+2) = bfly21((kk-1)*2+1) - bfly21((kk-1)*2+2);
 end
     

 % bfly22 = bfly22_tmp;  % <9.6> -> <9.4> 
 for nn=1:512
     real_22(nn) = round(real(bfly22_tmp(nn)/2^2)); 
     imag_22(nn) = round(imag(bfly22_tmp(nn)/2^2));

     % 포화 처리
     if(real_22(nn) > 4095) % <9.4>의 최댓값
         real_22(nn) = 4095;
     elseif(real_22(nn) < -4096) % <9.4>의 최솟값
         real_22(nn) = -4096;
     end
     if(imag_22(nn) > 4095) % <9.4>의 최댓값
         imag_22(nn) = 4095;
     elseif(imag_22(nn) < -4096) % <9.4>의 최솟값
         imag_22(nn) = -4096;
     end
     bfly22(nn) = real_22(nn) + 1j * imag_22(nn); % <9.4> 포맷의 정수화된 값으로 저장
 end

    %-----------------------------------------------------------------------------
    % Index 
    %-----------------------------------------------------------------------------
    fp = fopen('fixed_reorder_index.txt', 'w');
    for jj = 1:512
        kk = bitget(jj-1,9)*1 + bitget(jj-1,8)*2 + bitget(jj-1,7)*4 + bitget(jj-1,6)*8 + ...
             bitget(jj-1,5)*16 + bitget(jj-1,4)*32 + bitget(jj-1,3)*64 + ...
             bitget(jj-1,2)*128 + bitget(jj-1,1)*256;
        dout(kk+1) = bfly22(jj); % dout is not explicitly fixed, it will inherit from bfly22
        fprintf(fp, 'jj=%d, kk=%d, dout(%d)=%f+j%f\n', jj, kk, kk+1, ...
                double(real(dout(kk+1))), double(imag(dout(kk+1))));
    end
    fclose(fp);
    if fft_mode == 1
        fft_out = dout;
        module2_out = bfly22;
    else
        % Ensure division by 512 is handled with fixed-point arithmetic if necessary
        % For simplicity, assuming output can be float, otherwise define new numerictype
        fft_out = conj(dout) / 512; 
        module2_out = conj(bfly22) / 512;
    end
    

    % % Output to files (no changes needed here as they are just printing values)
    % % ... (The rest of your file output code remains the same)
    % fp=fopen('bfly00_tmp_fixed.txt','w');
    % for nn=1:512
    %   fprintf(fp, 'bfly00_tmp(%d)=%f+j%f\n',nn,real(bfly00_tmp(nn)),imag(bfly00_tmp(nn)));
    % end
    % fclose(fp);
    % 
    % % 출력 ----------------------------------------------------------------------
    % fp=fopen('bfly00_fixed.txt','w');
    % for nn=1:512
    %   fprintf(fp, 'bfly00(%d)=%f+j%f\n',nn,real(bfly00(nn)),imag(bfly00(nn)));
    % end
    % fclose(fp);
    % %----------------------------------------------------------------------------
    % 
    % % 출력 ----------------------------------------------------------------------
    % fp=fopen('bfly01_tmp_fixed.txt','w');
    % for nn=1:512
    %   fprintf(fp, 'bfly01_tmp(%d)=%f+j%f\n',nn,real(bfly01_tmp(nn)),imag(bfly01_tmp(nn)));
    % end
    % fclose(fp);
    % %----------------------------------------------------------------------------
    % 
    % % 출력 ----------------------------------------------------------------------
    % fp=fopen('bfly01_fixed.txt','w');
    % for nn=1:512
    %   fprintf(fp, 'bfly01(%d)=%f+j%f\n',nn,real(bfly01(nn)),imag(bfly01(nn)));
    % end
    % fclose(fp);
    % %----------------------------------------------------------------------------
    % 
    % % 출력 ----------------------------------------------------------------------
    % fp=fopen('bfly02_tmp_fixed.txt','w');
    % for nn=1:512
    %   fprintf(fp, 'bfly02_tmp(%d)=%f+j%f\n',nn,real(bfly02_tmp(nn)),imag(bfly02_tmp(nn)));
    % end
    % fclose(fp);
    % %----------------------------------------------------------------------------
    % 
    % 
    % % 출력 ----------------------------------------------------------------------
    % fp=fopen('twf_m0_fixed.txt','w');
    % for nn=1:512
    %   fprintf(fp, 'twf_m0(%d)=%f+j%f\n',nn,real(twf_m0(nn)),imag(twf_m0(nn)));
    % end
    % fclose(fp);
    % %----------------------------------------------------------------------------
    % 
    % % 출력 ----------------------------------------------------------------------
    % fp=fopen('bfly02_fixed.txt','w');
    % for nn=1:512
    %   fprintf(fp, 'bfly02(%d)=%f+j%f\n',nn,real(bfly02(nn)),imag(bfly02(nn)));
    % end
    % fclose(fp);
    % %----------------------------------------------------------------------------
    % 
    % % 출력 ----------------------------------------------------------------------
    % fp=fopen('bfly10_tmp_fixed.txt','w');
    % for nn=1:512
    %   fprintf(fp, 'bfly10_tmp(%d)=%f+j%f\n',nn,real(bfly10_tmp(nn)),imag(bfly10_tmp(nn)));
    % end
    % fclose(fp);
    % %----------------------------------------------------------------------------
    % 
    % 
    % % 출력 ----------------------------------------------------------------------
    % fp=fopen('bfly10_fixed.txt','w');
    % for nn=1:512
    %   fprintf(fp, 'bfly10(%d)=%f+j%f\n',nn,real(bfly10(nn)),imag(bfly10(nn)));
    % end
    % fclose(fp);
    % %----------------------------------------------------------------------------
    % 
    % % 출력 ----------------------------------------------------------------------
    % fp=fopen('bfly11_tmp_fixed.txt','w');
    % for nn=1:512
    %   fprintf(fp, 'bfly11_tmp(%d)=%f+j%f\n',nn,real(bfly11_tmp(nn)),imag(bfly11_tmp(nn)));
    % end
    % fclose(fp);
    % %----------------------------------------------------------------------------
    % 
    % % 출력 ----------------------------------------------------------------------
    % fp=fopen('bfly11_fixed.txt','w');
    % for nn=1:512
    %   fprintf(fp, 'bfly11(%d)=%f+j%f\n',nn,real(bfly11(nn)),imag(bfly11(nn)));
    % end
    % fclose(fp);
    % %----------------------------------------------------------------------------
    % 
    % % 출력 ----------------------------------------------------------------------
    % fp=fopen('bfly12_tmp_fixed.txt','w');
    % for nn=1:512
    %   fprintf(fp, 'bfly12_tmp(%d)=%f+j%f\n',nn,real(bfly12_tmp(nn)),imag(bfly12_tmp(nn)));
    % end
    % fclose(fp);
    % %----------------------------------------------------------------------------
    % 
    % % 출력 ----------------------------------------------------------------------
    % N = length(twf_m1);
    % fp=fopen('twf_m1_fixed.txt','w');
    % for nn=1:N
    %   fprintf(fp, 'twf_m1(%d)=%f+j%f\n',nn,real(twf_m1(nn)),imag(twf_m1(nn)));
    % end
    % fclose(fp);
    % %----------------------------------------------------------------------------
    % 
    % % 출력 ----------------------------------------------------------------------
    % fp=fopen('bfly12_fixed.txt','w');
    % for nn=1:512
    %   fprintf(fp, 'bfly12(%d)=%f+j%f\n',nn,real(bfly12(nn)),imag(bfly12(nn)));
    % end
    % fclose(fp);
    % %----------------------------------------------------------------------------
    % 
    % % 출력 ----------------------------------------------------------------------
    % fp=fopen('bfly20_tmp_fixed.txt','w');
    % for nn=1:512
    %   fprintf(fp, 'bfly20_tmp(%d)=%f+j%f\n',nn,real(bfly20_tmp(nn)),imag(bfly20_tmp(nn)));
    % end
    % fclose(fp);
    % %----------------------------------------------------------------------------
    % 
    % 
    % % 출력 ----------------------------------------------------------------------
    % fp=fopen('bfly20_fixed.txt','w');
    % for nn=1:512
    %   fprintf(fp, 'bfly20(%d)=%f+j%f\n',nn,real(bfly20(nn)),imag(bfly20(nn)));
    % end
    % fclose(fp);
    % %----------------------------------------------------------------------------
    % 
    % % 출력 ----------------------------------------------------------------------
    % fp=fopen('bfly21_tmp_fixed.txt','w');
    % for nn=1:512
    %   fprintf(fp, 'bfly21_tmp(%d)=%f+j%f\n',nn,real(bfly21_tmp(nn)),imag(bfly21_tmp(nn)));
    % end
    % fclose(fp);
    % %----------------------------------------------------------------------------
    % 
    % % 출력 ----------------------------------------------------------------------
    % fp=fopen('bfly21_fixed.txt','w');
    % for nn=1:512
    %   fprintf(fp, 'bfly21(%d)=%f+j%f\n',nn,real(bfly21(nn)),imag(bfly21(nn)));
    % end
    % fclose(fp);
    % %----------------------------------------------------------------------------
    % 
    % % 출력 ----------------------------------------------------------------------
    % fp=fopen('bfly22_tmp_fixed.txt','w');
    % for nn=1:512
    %   fprintf(fp, 'bfly21(%d)=%f+j%f\n',nn,real(bfly21(nn)),imag(bfly21(nn)));
    % end
    % fclose(fp);
    % %----------------------------------------------------------------------------
    % 
    % % 출력 ----------------------------------------------------------------------
    % fp=fopen('bfly22_tmp_fixed.txt','w');
    % for nn=1:512
    %   fprintf(fp, 'bfly22_tmp(%d)=%f+j%f\n',nn,real(bfly22_tmp(nn)),imag(bfly22_tmp(nn)));
    % end
    % fclose(fp);
    % %----------------------------------------------------------------------------