% Added on 2025/07/01 by jihan 
function [fft_out, module2_out] = fft_fixed(fft_mode, fft_in)

 shift = 0;
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
 % 고정소수점 범위 설정 (3.6 format)
 
 % step0_0
 bfly00_out0 = din(1:256) + din(257:512); %INPUT <3.6> -> OUTPUT <4.6>
 bfly00_out1 = din(1:256) - din(257:512);

 save_table_single(bfly00_out1, 1,'bfly00_out1_fixed.txt' );

 bfly00_tmp = [bfly00_out0, bfly00_out1];

 for nn=1:512
   bfly00(nn) = bfly00_tmp(nn)*fac8_0(ceil(nn/128));  %INPUT <4.6> -> OUTPUT <4.6>
 end

 save_table_single(bfly00, 1,'bfly00_fixed.txt' );

 % step0_1
 for kk=1:2
  for nn=1:128
   bfly01_tmp((kk-1)*256+nn) = bfly00((kk-1)*256+nn) + bfly00((kk-1)*256+128+nn); %INPUT <4.6> -> OUTPUT <5.6> 
   bfly01_tmp((kk-1)*256+128+nn) = bfly00((kk-1)*256+nn) - bfly00((kk-1)*256+128+nn);
  end
 end

 save_table_single(bfly01_tmp, 1,'bfly01_tmp_fixed.txt' );


for nn = 1:512
    % 1. 곱셈: <5.6> x <2.7> → <7.13>
    bfly01_cmplx = bfly01_tmp(nn) * fac8_1(ceil(nn/64));

    % 2. 스케일 다운: <7.13> → <7.6>
    bfly01_cmplx = bfly01_cmplx / 128;

    % 3. rounding (정수 변환)
    real_part = round(real(bfly01_cmplx));
    imag_part = round(imag(bfly01_cmplx));

    % 4. 실수부 saturation <5.6>
    if real_part > 1023
        real_part = 1023;
    elseif real_part < -1024
        real_part = -1024;
    end

    % 5. 허수부 saturation <5.6>
    if imag_part > 1023
        imag_part = 1023;
    elseif imag_part < -1024
        imag_part = -1024;
    end

    % 6. 복소수 재조립
    bfly01(nn) = complex(real_part, imag_part);
end

  save_table_single(bfly01, 1,'bfly01_fixed.txt' );

 % step0_2
 for kk=1:4
  for nn=1:64
   bfly02_tmp((kk-1)*128+nn) = bfly01((kk-1)*128+nn) + bfly01((kk-1)*128+64+nn); %INPUT <5.6> -> OUTPUT <6.6> 
   bfly02_tmp((kk-1)*128+64+nn) = bfly01((kk-1)*128+nn) - bfly01((kk-1)*128+64+nn);
  end
 end

 save_table_single(bfly02_tmp, 1,'bfly02_tmp_fixed.txt' );

 % Data rearrangement
 K3 = [0, 4, 2, 6, 1, 5, 3, 7];

 for kk=1:8
  for nn=1:64
   twf_m0((kk-1)*64+nn) = round(exp(-j*2*pi*(nn-1)*(K3(kk))/512)*128); % twiddle factor <2.7> round, *128
  end
 end

 for nn = 1:512
    % 1. 곱셈: <6.6> x <2.7> → <8.13>
    bfly02_cmplx = bfly02_tmp(nn) * twf_m0(nn);

    % 2. 스케일 다운: /128 (2^7 shift) → <8.6>
    bfly02_cmplx = bfly02_cmplx / 128;

    % 3. 실수/허수 분리 후 rounding
    real_part = round(real(bfly02_cmplx));
    imag_part = round(imag(bfly02_cmplx));

    % 4. 실수부 saturation: <5.6> [-1024, 1023]
    if real_part > 1023
        real_part = 1023;
    elseif real_part < -1024
        real_part = -1024;
    end

    % 5. 허수부 saturation: <5.6> [-1024, 1023]
    if imag_part > 1023
        imag_part = 1023;
    elseif imag_part < -1024
        imag_part = -1024;
    end

    % 6. 복소수 재조립
    bfly02(nn) = complex(real_part, imag_part);
 end

  save_table_single(bfly02, 1,'bfly02_fixed.txt' );

 %-----------------------------------------------------------------------------
 % Module 1
 %-----------------------------------------------------------------------------
 % step1_0
 for kk=1:8
  for nn=1:32
   bfly10_tmp((kk-1)*64+nn) = bfly02((kk-1)*64+nn) + bfly02((kk-1)*64+32+nn); %INPUT <5.6> -> OUTPUT <6.6>
   bfly10_tmp((kk-1)*64+32+nn) = bfly02((kk-1)*64+nn) - bfly02((kk-1)*64+32+nn);
  end
 end

 save_table_single(bfly10_tmp, 1,'bfly10_tmp_fixed.txt' ); 

 for kk=1:8
  for nn=1:64
   bfly10((kk-1)*64+nn) = bfly10_tmp((kk-1)*64+nn)*fac8_0(ceil(nn/16)); %INPUT <6.6> -> OUTPUT <6.6>
  end
 end

 save_table_single(bfly10, 1,'bfly10_fixed.txt' ); 

 % step1_1
 for kk=1:16
  for nn=1:16
   bfly11_tmp((kk-1)*32+nn) = bfly10((kk-1)*32+nn) + bfly10((kk-1)*32+16+nn); %INPUT <6.6> -> OUTPUT <7.6>
   bfly11_tmp((kk-1)*32+16+nn) = bfly10((kk-1)*32+nn) - bfly10((kk-1)*32+16+nn);
  end
 end

 save_table_single(bfly11_tmp, 1,'bfly11_tmp_fixed.txt' );

 for kk = 1:8
  for nn = 1:64
    idx = (kk-1)*64 + nn;

    % 1. 곱셈: <7.6> × <2.7> → <9.13>
    bfly11_cmplx = bfly11_tmp(idx) * fac8_1(ceil(nn/8));

    % 2. 스케일 다운 (/128): <9.13> → <9.6>
    bfly11_cmplx = bfly11_cmplx / 128;

    % 3. rounding
    real_part = round(real(bfly11_cmplx));
    imag_part = round(imag(bfly11_cmplx));

    % 4. saturation (실수부) <5.6>
    if real_part > 1023
        real_part = 1023;
    elseif real_part < -1024
        real_part = -1024;
    end

    % 5. saturation (허수부) <5.6>
    if imag_part > 1023
        imag_part = 1023;
    elseif imag_part < -1024
        imag_part = -1024;
    end

    % 6. 복소수 저장
    bfly11(idx) = complex(real_part, imag_part);
  end
 end

  save_table_single(bfly11, 1,'bfly11_fixed.txt' );


 % step1_2
 for kk=1:32
  for nn=1:8
   bfly12_tmp((kk-1)*16+nn) = bfly11((kk-1)*16+nn) + bfly11((kk-1)*16+8+nn); %INPUT <5.6> -> OUTPUT <6.6>
   bfly12_tmp((kk-1)*16+8+nn) = bfly11((kk-1)*16+nn) - bfly11((kk-1)*16+8+nn);
  end
 end

 save_table_single(bfly12_tmp, 1,'bfly12_tmp_fixed.txt' );

 % Data rearrangement
 K2 = [0, 4, 2, 6, 1, 5, 3, 7];

 for kk=1:8
  for nn=1:8
   twf_m1((kk-1)*8+nn) = round(exp(-j*2*pi*(nn-1)*(K2(kk))/64)*128); % twiddle factior rounding, <2.7>
  end
 end

 for kk = 1:8
  for nn = 1:64
    idx = (kk-1)*64 + nn;

    % 1. 곱셈: <6.6> x <2.7> = <8.13>
    bfly12_cmplx = bfly12_tmp(idx) * twf_m1(nn);

    % 2. 스케일 다운: /128 (>> 7) → <8.6>
    bfly12_cmplx = bfly12_cmplx / 128;

    % 3. rounding
    real_part = round(real(bfly12_cmplx));
    imag_part = round(imag(bfly12_cmplx));

    % 4. 실수부 saturation <6.6> ([-2048, 2047])
    if real_part > 2047
        real_part = 2047;
    elseif real_part < -2048
        real_part = -2048;
    end

    % 5. 허수부 saturation <6.6> ([-2048, 2047])
    if imag_part > 2047
        imag_part = 2047;
    elseif imag_part < -2048
        imag_part = -2048;
    end

    % 6. 복소수 재조립
    bfly12(idx) = complex(real_part, imag_part);
  end
 end

 save_table_single(bfly12, 1,'bfly12_fixed.txt' );

 %-----------------------------------------------------------------------------
 % Module 2
 %-----------------------------------------------------------------------------
 % step2_0
 for kk=1:64
  for nn=1:4
   bfly20_tmp((kk-1)*8+nn) = bfly12((kk-1)*8+nn) + bfly12((kk-1)*8+4+nn); %INPUT <6.6> -> OUTPUT <7.6>
   bfly20_tmp((kk-1)*8+4+nn) = bfly12((kk-1)*8+nn) - bfly12((kk-1)*8+4+nn);
  end
 end

 save_table_single(bfly20_tmp, 1,'bfly20_tmp_fixed.txt' );

 for kk=1:64
  for nn=1:8
   bfly20((kk-1)*8+nn) = bfly20_tmp((kk-1)*8+nn)*fac8_0(ceil(nn/2)); %INPUT <7.6> -> OUTPUT <7.6>
  end
 end

save_table_single(bfly20, 1,'bfly20_fixed.txt' );
  
 % step2_1
 for kk=1:128
  for nn=1:2
   bfly21_tmp((kk-1)*4+nn) = bfly20((kk-1)*4+nn) + bfly20((kk-1)*4+2+nn); %INPUT <7.6> -> OUTPUT <8.6>
   bfly21_tmp((kk-1)*4+2+nn) = bfly20((kk-1)*4+nn) - bfly20((kk-1)*4+2+nn);
  end
 end

 save_table_single(bfly21_tmp, 1,'bfly21_tmp_fixed.txt' );


 for kk = 1:64
  for nn = 1:8
    idx = (kk-1)*8 + nn;

    % 1. 곱셈: <8.6> x <2.7> = <10.13>
    bfly21_cmplx = bfly21_tmp(idx) * fac8_1(nn);

    % 2. 스케일 다운: /512 (2^9) 
    bfly21_cmplx = bfly21_cmplx / 512;

    % 3. rounding
    real_part = round(real(bfly21_cmplx));
    imag_part = round(imag(bfly21_cmplx));

    % 4. 실수부 saturation: <8.4> [-2048, 2047] <9.3>
    if real_part > 2047
        real_part = 2047;
    elseif real_part < -2048
        real_part = -2048;
    end

    % 5. 허수부 saturation: <8.4> [-2048, 2047]
    if imag_part > 2047
        imag_part = 2047;
    elseif imag_part < -2048
        imag_part = -2048;
    end

    % 6. 복소수 저장
    bfly21(idx) = complex(real_part, imag_part);
  end
 end


 save_table_single(bfly21, 1,'bfly21_fixed.txt' );

 % step2_2
 for kk=1:256
   bfly22_tmp((kk-1)*2+1) = bfly21((kk-1)*2+1) + bfly21((kk-1)*2+2); %INPUT <8.4> -> OUTPUT <9.4>
   bfly22_tmp((kk-1)*2+2) = bfly21((kk-1)*2+1) - bfly21((kk-1)*2+2);
 end

  save_table_single(bfly22_tmp, 1,'bfly22_tmp_fixed.txt' );


 bfly22 = bfly22_tmp; %INPUT <9.4> -> OUTPUT <9.4>

 % noise solution

 %for kk=1:64
 % for nn=1:8
 %   bfly21((kk-1)*8+nn) = bfly21_tmp((kk-1)*8+nn)*fac8_1(nn); %INPUT <8.6> x <2.7>  -> OUTPUT <10.13>
 %    % rounding, saturation
 %   bfly21((kk-1)*8+nn) = round(bfly21((kk-1)*8+nn) / 128); % <10.6>, rounding
 %   if bfly21((kk-1)*8+nn) > 8191
 %       bfly21((kk-1)*8+nn) = 8191; % Saturation <8.6>
 %   elseif bfly21((kk-1)*8+nn) < -8191
 %       bfly21((kk-1)*8+nn) = -8191;
 %   else
 %       bfly21((kk-1)*8+nn) = bfly21((kk-1)*8+nn); 
 %  end
 % end
 %end

 %save_table_single(bfly21, 1,'bfly21_fixed.txt' );

 % step2_2
 %for kk=1:256
 %   bfly22_tmp((kk-1)*2+1) = bfly21((kk-1)*2+1) + bfly21((kk-1)*2+2); %INPUT <8.6> -> OUTPUT <9.6>
 %   bfly22_tmp((kk-1)*2+2) = bfly21((kk-1)*2+1) - bfly21((kk-1)*2+2);
 %end

 % save_table_single(bfly22_tmp, 1,'bfly22_tmp_fixed.txt' );


 %bfly22 = bfly22_tmp; %INPUT <9.6> -> OUTPUT <9.6>


 %-----------------------------------------------------------------------------
 % Index 
 %-----------------------------------------------------------------------------
 fp=fopen('reorder_index_fixed.txt','w');
 for jj=1:512
   %kk = bitget(jj-1,9)*(2^0) + bitget(jj-1,8)*(2^1) + bitget(jj-1,7)*(2^2) + bitget(jj-1,6)*(2^3) + bitget(jj-1,5)*(2^4) + bitget(jj-1,4)*(2^5) + bitget(jj-1,3)*(2^6) + bitget(jj-1,2)*(2^7) + bitget(jj-1,1)*(2^8);
   kk = bitget(jj-1,9)*1 + bitget(jj-1,8)*2 + bitget(jj-1,7)*4 + bitget(jj-1,6)*8 + bitget(jj-1,5)*16 + bitget(jj-1,4)*32 + bitget(jj-1,3)*64 + bitget(jj-1,2)*128 + bitget(jj-1,1)*256;
   dout(kk+1) = bfly22(jj); % With reorder
   fprintf(fp, 'jj=%d, kk=%d, dout(%d)=%f+j%f\n',jj, kk,(kk+1),real(dout(kk+1)),imag(dout(kk+1)));
 end
 fclose(fp);

 

 if (fft_mode==1) % fft
   fft_out = dout;
   module2_out = bfly22;
 else % ifft
   fft_out = conj(dout)/512; 
   module2_out = conj(bfly22) /512;

 end

end
