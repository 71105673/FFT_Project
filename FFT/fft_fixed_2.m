function [fft_out, module2_out] = fft_fixed_2(fft_mode, fft_in)
    shift = 0;
    SIM_FIX = 1; % 0: float, 1: fixed

    FMT = fimath('RoundingMethod', 'Nearest', ...
                 'OverflowAction', 'Saturate', ...
                 'ProductMode', 'SpecifyPrecision', ...
                 'ProductWordLength', 32, ...
                 'ProductFractionLength', 28, ...
                 'SumMode', 'SpecifyPrecision', ...
                 'SumWordLength', 32, ...
                 'SumFractionLength', 28);

    T = numerictype('WordLength', 16, 'FractionLength', 14, 'Signed', true);

    %  초기 입력 T를 <3.6> 포맷으로 정의합니다.
    T_input = numerictype('WordLength', 9, 'FractionLength', 6, 'Signed', true); 

    if fft_mode == 1
        din = fft_in;
    else
        din = conj(fft_in);
    end
    if SIM_FIX
        din = fi(din, T_input, 'fimath', FMT);
    end
    
    % The fraction lengths for fac8_0 and fac8_1 are stated as <2.7>.
    % Assuming these are fixed point numbers, let's define their numerictype.
    % If they are truly fixed to <2.7> then their word length is 2 and fraction length is 7 which means they are very small numbers.
    % Given their values (1, 0.7071), it's more likely that <2.7> means:
    % 2 bits for integer part (including sign bit) and 7 bits for fractional part.
    % So, a signed 9-bit word length with 7 fractional bits.
    T_fac = numerictype('WordLength', 9, 'FractionLength', 7, 'Signed', true); 
    fac8_0 = fi([1, 1, 1, -1j], T_fac, 'fimath', FMT); 
    fac8_1 = fi([1, 1, 1, -1j, 1, 0.7071-0.7071j, 1, -0.7071-0.7071j], T_fac, 'fimath', FMT);
    
   % Define numerictypes for intermediate steps based on your comments
    T_4_6 = numerictype('WordLength', 10, 'FractionLength', 6, 'Signed', true); % <4.6> -> implies 4 integer bits (including sign) + 6 fractional bits = 10 total bits
    T_5_6 = numerictype('WordLength', 11, 'FractionLength', 6, 'Signed', true); % <5.6> -> 5 integer bits (including sign) + 6 fractional bits = 11 total bits
    T_7_13 = numerictype('WordLength', 20, 'FractionLength', 13, 'Signed', true); % <7.13> -> 7 integer bits (including sign) + 13 fractional bits = 20 total bits
    T_8_6 = numerictype('WordLength', 14, 'FractionLength', 6, 'Signed', true); % <8.6> -> 8 integer bits (including sign) + 6 fractional bits = 14 total bits
    T_10_13 = numerictype('WordLength', 23, 'FractionLength', 13, 'Signed', true); % <10.13> -> 10 integer bits (including sign) + 13 fractional bits = 23 total bits
    T_6_6 = numerictype('WordLength', 12, 'FractionLength', 6, 'Signed', true); % <6.6> -> 6 integer bits (including sign) + 6 fractional bits = 12 total bits
    T_7_6 = numerictype('WordLength', 13, 'FractionLength', 6, 'Signed', true); % <7.6> -> 7 integer bits (including sign) + 6 fractional bits = 13 total bits
    T_9_13 = numerictype('WordLength', 22, 'FractionLength', 13, 'Signed', true); % <9.13> -> 9 integer bits (including sign) + 13 fractional bits = 22 total bits
    T_9_6 = numerictype('WordLength', 15, 'FractionLength', 6, 'Signed', true);  % <9.6> -> 9 integer bits (including sign) + 6 fractional bits = 15 total bits
    T_10_6 = numerictype('WordLength', 16, 'FractionLength', 6, 'Signed', true); % <10.6> -> 10 integer bits (including sign) + 6 fractional bits = 16 total bits
    T_12_13 = numerictype('WordLength', 25, 'FractionLength', 13, 'Signed', true); % <12.13> -> 12 integer bits (including sign) + 13 fractional bits = 25 total bits
    T_12_6 = numerictype('WordLength', 18, 'FractionLength', 6, 'Signed', true); % <12.6> -> 12 integer bits (including sign) + 6 fractional bits = 18 total bits
    T_10_4 = numerictype('WordLength', 14, 'FractionLength', 4, 'Signed', true); % <10.4> -> 10 integer bits (including sign) + 4 fractional bits = 14 total bits
    T_11_4 = numerictype('WordLength', 15, 'FractionLength', 4, 'Signed', true); % <11.4> -> 11 integer bits (including sign) + 4 fractional bits = 15 total bits
    T_9_4 = numerictype('WordLength', 13, 'FractionLength', 4, 'Signed', true); % <9.4> -> 9 integer bits (including sign) + 4 fractional bits = 13 total bits


    %-----------------------------------------------------------------------------
    % Module 0
    %-----------------------------------------------------------------------------
    % step0_0
    bfly00_out0 = din(1:256) + din(257:512); 
    bfly00_out1 = din(1:256) - din(257:512); 
    bfly00_tmp = fi([bfly00_out0, bfly00_out1], T_4_6, 'fimath', FMT); % <4.6> 
    for nn=1:512
        bfly00(nn) = fi(bfly00_tmp(nn) * fac8_0(ceil(nn/128)), T_4_6, 'fimath', FMT); % <4.6> 
    end
    
    % step0_1
    for kk=1:2
        for nn=1:128
            bfly01_tmp((kk-1)*256+nn) = fi(bfly00((kk-1)*256+nn) + bfly00((kk-1)*256+128+nn), T_5_6, 'fimath', FMT); % <5.6>
            bfly01_tmp((kk-1)*256+128+nn) = fi(bfly00((kk-1)*256+nn) - bfly00((kk-1)*256+128+nn), T_5_6, 'fimath', FMT); % <5.6>
        end
    end
    for nn=1:512
        % Product <5.6> * <2.7> = <7.13>
        % Then convert to <7.6>
        bfly01(nn) = fi(bfly01_tmp(nn) * fac8_1(ceil(nn/64)), T_7_13, 'fimath', FMT); % Result is <7.13>
        bfly01(nn) = fi(bfly01(nn), T_7_6, 'fimath', FMT); % <7.13> -> <7.6>
    end
    
    % step0_2
    for kk=1:4
        for nn=1:64   
            bfly02_tmp((kk-1)*128+nn) = fi(bfly01((kk-1)*128+nn) + bfly01((kk-1)*128+64+nn), T_8_6, 'fimath', FMT); % <8.6>
            bfly02_tmp((kk-1)*128+64+nn) = fi(bfly01((kk-1)*128+nn) - bfly01((kk-1)*128+64+nn), T_8_6, 'fimath', FMT); % <8.6>
        end
    end
    % Data rearrangement
    K3 = [0, 4, 2, 6, 1, 5, 3, 7];
    for kk=1:8
        for nn=1:64
            tw = exp(-1j * 2 * pi * (nn - 1) * K3(kk) / 512);
            if SIM_FIX
                twf_m0((kk - 1) * 64 + nn) = fi(tw, T_fac, 'fimath', FMT); % Assuming T_fac is appropriate for twiddle factors
            else
                twf_m0((kk - 1) * 64 + nn) = tw;
            end
        end
    end
    for nn=1:512
        % Product <8.6> * <2.7> = <10.13>
        % Then convert to <10.6> and then to <5.6>
        bfly02(nn) = fi(bfly02_tmp(nn) * twf_m0(nn), T_10_13, 'fimath', FMT); % Result is <10.13>
        bfly02(nn) = fi(bfly02(nn), T_10_6, 'fimath', FMT); % <10.13> -> <10.6>
        bfly02(nn) = fi(bfly02(nn), T_5_6, 'fimath', FMT); % <10.6> -> <5.6>
    end
    
    %-----------------------------------------------------------------------------
    % Module 1
    %-----------------------------------------------------------------------------
    % step1_0
    for kk=1:8
        for nn=1:32
            bfly10_tmp((kk-1)*64+nn) = fi(bfly02((kk-1)*64+nn) + bfly02((kk-1)*64+32+nn), T_6_6, 'fimath', FMT); % <6.6>
            bfly10_tmp((kk-1)*64+32+nn) = fi(bfly02((kk-1)*64+nn) - bfly02((kk-1)*64+32+nn), T_6_6, 'fimath', FMT); % <6.6>
        end
    end
    for kk=1:8
        for nn=1:64
            bfly10((kk-1)*64+nn) = fi(bfly10_tmp((kk-1)*64+nn) * fac8_0(ceil(nn/16)), T_6_6, 'fimath', FMT); % <6.6>
        end
    end
    % step1_1
    for kk=1:16
        for nn=1:16
            bfly11_tmp((kk-1)*32+nn) = fi(bfly10((kk-1)*32+nn) + bfly10((kk-1)*32+16+nn), T_7_6, 'fimath', FMT); % <7.6>
            bfly11_tmp((kk-1)*32+16+nn) = fi(bfly10((kk-1)*32+nn) - bfly10((kk-1)*32+16+nn), T_7_6, 'fimath', FMT); % <7.6>
        end
    end
    for kk=1:8
        for nn=1:64
            % Product <7.6> * <2.7> = <9.13>
            % Then convert to <9.6>
            bfly11((kk-1)*64+nn) = fi(bfly11_tmp((kk-1)*64+nn) * fac8_1(ceil(nn/8)), T_9_13, 'fimath', FMT); % Result is <9.13>
            bfly11(nn) = fi(bfly11(nn), T_9_6, 'fimath', FMT); % <9.13> -> <9.6>
        end 
    end
    
    % step1_2 (16)
    for kk=1:32
        for nn=1:8
            bfly12_tmp((kk-1)*16+nn) = fi(bfly11((kk-1)*16+nn) + bfly11((kk-1)*16+8+nn), T_10_6, 'fimath', FMT); % <10.6>
            bfly12_tmp((kk-1)*16+8+nn) = fi(bfly11((kk-1)*16+nn) - bfly11((kk-1)*16+8+nn), T_10_6, 'fimath', FMT); % <10.6>
        end
    end
    % Data rearrangement
    K2 = [0, 4, 2, 6, 1, 5, 3, 7];
    for kk=1:8
        for nn=1:8
            tw = exp(-1j * 2 * pi * (nn - 1) * K2(kk) / 64);
            if SIM_FIX
                twf_m1((kk - 1) * 8 + nn) = fi(tw, T_fac, 'fimath', FMT); % Assuming T_fac is appropriate for twiddle factors
            else
                twf_m1((kk - 1) * 8 + nn) = tw;
            end
        end
    end
    for kk=1:8
        for nn=1:64
            % Product <10.6> * <2.7> = <12.13>
            % Then convert to <12.6> and then to <6.6>
            bfly12((kk-1)*64+nn) = fi(bfly12_tmp((kk-1)*64+nn) * twf_m1(nn), T_12_13, 'fimath', FMT); % Result is <12.13>
            bfly12(nn) = fi(bfly12(nn), T_12_6, 'fimath', FMT); % <12.13> -> <12.6> (defined as T_Word_18_Frac_6. Need to define if not existing)
            bfly12(nn) = fi(bfly12(nn), T_6_6, 'fimath', FMT); % <12.6> -> <6.6>
        end
    end
    
    %-----------------------------------------------------------------------------
    % Module 2
    %-----------------------------------------------------------------------------
    % step2_0
    for kk=1:64
        for nn=1:4
            bfly20_tmp((kk-1)*8+nn) = fi(bfly12((kk-1)*8+nn) + bfly12((kk-1)*8+4+nn), T_7_6, 'fimath', FMT); % <7.6>
            bfly20_tmp((kk-1)*8+4+nn) = fi(bfly12((kk-1)*8+nn) - bfly12((kk-1)*8+4+nn), T_7_6, 'fimath', FMT); % <7.6>
        end
    end
    for kk=1:64
        for nn=1:8
            bfly20((kk-1)*8+nn) = fi(bfly20_tmp((kk-1)*8+nn) * fac8_0(ceil(nn/2)), T_7_6, 'fimath', FMT); % <7.6>
        end
    end
    % step2_1
    for kk=1:128
        for nn=1:2
            bfly21_tmp((kk-1)*4+nn) = fi(bfly20((kk-1)*4+nn) + bfly20((kk-1)*4+2+nn), T_8_6, 'fimath', FMT); % <8.6>
            bfly21_tmp((kk-1)*4+2+nn) = fi(bfly20((kk-1)*4+nn) - bfly20((kk-1)*4+2+nn), T_8_6, 'fimath', FMT); % <8.6>
        end
    end
    for kk=1:64
        for nn=1:8
            % Product <8.6> * <2.7> = <10.13>
            % Then convert to <10.4>
            bfly21((kk-1)*8+nn) = fi(bfly21_tmp((kk-1)*8+nn) * fac8_1(nn), T_10_13, 'fimath', FMT); % Result is <10.13>
            bfly21(nn) = fi(bfly21(nn), T_10_4, 'fimath', FMT); % <10.13> -> <10.4>
        end
    end
    
    % step2_2
    for kk=1:256
        bfly22_tmp((kk-1)*2+1) = fi(bfly21((kk-1)*2+1) + bfly21((kk-1)*2+2), T_11_4, 'fimath', FMT); % <11.4> 
        bfly22_tmp((kk-1)*2+2) = fi(bfly21((kk-1)*2+1) - bfly21((kk-1)*2+2), T_11_4, 'fimath', FMT); % <11.4>
    end
    bfly22 = fi(bfly22_tmp, T_9_4, 'fimath', FMT); % <11.4> -> <9.4> 

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
    
    % Output to files (no changes needed here as they are just printing values)
    % ... (The rest of your file output code remains the same)
    fp=fopen('bfly00_tmp_fixed.txt','w');
    for nn=1:512
      fprintf(fp, 'bfly00_tmp(%d)=%f+j%f\n',nn,real(bfly00_tmp(nn)),imag(bfly00_tmp(nn)));
    end
    fclose(fp);
    %----------------------------------------------------------------------------
    
    % 출력 ----------------------------------------------------------------------
    fp=fopen('bfly00_fixed.txt','w');
    for nn=1:512
      fprintf(fp, 'bfly00(%d)=%f+j%f\n',nn,real(bfly00(nn)),imag(bfly00(nn)));
    end
    fclose(fp);
    %----------------------------------------------------------------------------
    
    % 출력 ----------------------------------------------------------------------
    fp=fopen('bfly01_tmp_fixed.txt','w');
    for nn=1:512
      fprintf(fp, 'bfly01_tmp(%d)=%f+j%f\n',nn,real(bfly01_tmp(nn)),imag(bfly01_tmp(nn)));
    end
    fclose(fp);
    %----------------------------------------------------------------------------
   
    % 출력 ----------------------------------------------------------------------
    fp=fopen('bfly01_fixed.txt','w');
    for nn=1:512
      fprintf(fp, 'bfly01(%d)=%f+j%f\n',nn,real(bfly01(nn)),imag(bfly01(nn)));
    end
    fclose(fp);
    %----------------------------------------------------------------------------
   
    % 출력 ----------------------------------------------------------------------
    fp=fopen('bfly02_tmp_fixed.txt','w');
    for nn=1:512
      fprintf(fp, 'bfly02_tmp(%d)=%f+j%f\n',nn,real(bfly02_tmp(nn)),imag(bfly02_tmp(nn)));
    end
    fclose(fp);
    %----------------------------------------------------------------------------
   
   
    % 출력 ----------------------------------------------------------------------
    fp=fopen('twf_m0_fixed.txt','w');
    for nn=1:512
      fprintf(fp, 'twf_m0(%d)=%f+j%f\n',nn,real(twf_m0(nn)),imag(twf_m0(nn)));
    end
    fclose(fp);
    %----------------------------------------------------------------------------
   
    % 출력 ----------------------------------------------------------------------
    fp=fopen('bfly02_fixed.txt','w');
    for nn=1:512
      fprintf(fp, 'bfly02(%d)=%f+j%f\n',nn,real(bfly02(nn)),imag(bfly02(nn)));
    end
    fclose(fp);
    %----------------------------------------------------------------------------
        
    % 출력 ----------------------------------------------------------------------
    fp=fopen('bfly10_tmp_fixed.txt','w');
    for nn=1:512
      fprintf(fp, 'bfly10_tmp(%d)=%f+j%f\n',nn,real(bfly10_tmp(nn)),imag(bfly10_tmp(nn)));
    end
    fclose(fp);
    %----------------------------------------------------------------------------
    
    
    % 출력 ----------------------------------------------------------------------
    fp=fopen('bfly10_fixed.txt','w');
    for nn=1:512
      fprintf(fp, 'bfly10(%d)=%f+j%f\n',nn,real(bfly10(nn)),imag(bfly10(nn)));
    end
    fclose(fp);
    %----------------------------------------------------------------------------
    
    % 출력 ----------------------------------------------------------------------
    fp=fopen('bfly11_tmp_fixed.txt','w');
    for nn=1:512
      fprintf(fp, 'bfly11_tmp(%d)=%f+j%f\n',nn,real(bfly11_tmp(nn)),imag(bfly11_tmp(nn)));
    end
    fclose(fp);
    %----------------------------------------------------------------------------
    
    % 출력 ----------------------------------------------------------------------
    fp=fopen('bfly11_fixed.txt','w');
    for nn=1:512
      fprintf(fp, 'bfly11(%d)=%f+j%f\n',nn,real(bfly11(nn)),imag(bfly11(nn)));
    end
    fclose(fp);
    %----------------------------------------------------------------------------
    
    % 출력 ----------------------------------------------------------------------
    fp=fopen('bfly12_tmp_fixed.txt','w');
    for nn=1:512
      fprintf(fp, 'bfly12_tmp(%d)=%f+j%f\n',nn,real(bfly12_tmp(nn)),imag(bfly12_tmp(nn)));
    end
    fclose(fp);
    %----------------------------------------------------------------------------
    
    % 출력 ----------------------------------------------------------------------
    N = length(twf_m1);
    fp=fopen('twf_m1_fixed.txt','w');
    for nn=1:N
      fprintf(fp, 'twf_m1(%d)=%f+j%f\n',nn,real(twf_m1(nn)),imag(twf_m1(nn)));
    end
    fclose(fp);
    %----------------------------------------------------------------------------
    
    % 출력 ----------------------------------------------------------------------
    fp=fopen('bfly12_fixed.txt','w');
    for nn=1:512
      fprintf(fp, 'bfly12(%d)=%f+j%f\n',nn,real(bfly12(nn)),imag(bfly12(nn)));
    end
    fclose(fp);
    %----------------------------------------------------------------------------
    
    % 출력 ----------------------------------------------------------------------
    fp=fopen('bfly20_tmp_fixed.txt','w');
    for nn=1:512
      fprintf(fp, 'bfly20_tmp(%d)=%f+j%f\n',nn,real(bfly20_tmp(nn)),imag(bfly20_tmp(nn)));
    end
    fclose(fp);
    %----------------------------------------------------------------------------
    
    
    % 출력 ----------------------------------------------------------------------
    fp=fopen('bfly20_fixed.txt','w');
    for nn=1:512
      fprintf(fp, 'bfly20(%d)=%f+j%f\n',nn,real(bfly20(nn)),imag(bfly20(nn)));
    end
    fclose(fp);
    %----------------------------------------------------------------------------
    
    % 출력 ----------------------------------------------------------------------
    fp=fopen('bfly21_tmp_fixed.txt','w');
    for nn=1:512
      fprintf(fp, 'bfly21_tmp(%d)=%f+j%f\n',nn,real(bfly21_tmp(nn)),imag(bfly21_tmp(nn)));
    end
    fclose(fp);
    %----------------------------------------------------------------------------
     
    % 출력 ----------------------------------------------------------------------
    fp=fopen('bfly21_fixed.txt','w');
    for nn=1:512
      fprintf(fp, 'bfly21(%d)=%f+j%f\n',nn,real(bfly21(nn)),imag(bfly21(nn)));
    end
    fclose(fp);
    %----------------------------------------------------------------------------
    
    % 출력 ----------------------------------------------------------------------
    fp=fopen('bfly22_tmp_fixed.txt','w');
    for nn=1:512
      fprintf(fp, 'bfly22_tmp(%d)=%f+j%f\n',nn,real(bfly22_tmp(nn)),imag(bfly22_tmp(nn)));
    end
    fclose(fp);
    %----------------------------------------------------------------------------
end