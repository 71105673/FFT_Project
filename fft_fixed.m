function [fft_out, module2_out] = fft_fixed(fft_mode, fft_in)
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

    if fft_mode == 1
        din = fft_in;
    else
        din = conj(fft_in);
    end

    if SIM_FIX
        din = fi(din, T, 'fimath', FMT);
    end


    fac8_0 = fi([1, 1, 1, -1j]); % <2.7>
    fac8_1 = fi([1, 1, 1, -1j, 1, 0.7071-0.7071j, 1, -0.7071-0.7071j]);  % <2.7>

    %-----------------------------------------------------------------------------
    % Module 0
    %-----------------------------------------------------------------------------
    % step0_0
    bfly00_out0 = din(1:256) + din(257:512); % <4.6> 
    bfly00_out1 = din(1:256) - din(257:512); % <4.6> 

    bfly00_tmp = [bfly00_out0, bfly00_out1]; % <4.6> 
    for nn=1:512
        bfly00(nn) = bfly00_tmp(nn) * fac8_0(ceil(nn/128)); % <4.6> 
    end

    % step0_1
    for kk=1:2
        for nn=1:128
            bfly01_tmp((kk-1)*256+nn) = bfly00((kk-1)*256+nn) + bfly00((kk-1)*256+128+nn); % <5.6>
            bfly01_tmp((kk-1)*256+128+nn) = bfly00((kk-1)*256+nn) - bfly00((kk-1)*256+128+nn); % <5.6>
        end
    end

    for nn=1:512
        bfly01(nn) = bfly01_tmp(nn) * fac8_1(ceil(nn/64)); % <5.6> * <2.7> = <7.13>
    end

    % <7.13> -> <7.6>

    % step0_2
    for kk=1:4
        for nn=1:64   
            bfly02_tmp((kk-1)*128+nn) = bfly01((kk-1)*128+nn) + bfly01((kk-1)*128+64+nn); % <8.6>
            bfly02_tmp((kk-1)*128+64+nn) = bfly01((kk-1)*128+nn) - bfly01((kk-1)*128+64+nn); % <8.6>
        end
    end

    % Data rearrangement
    K3 = [0, 4, 2, 6, 1, 5, 3, 7];
    for kk=1:8
        for nn=1:64
            tw = exp(-1j * 2 * pi * (nn - 1) * K3(kk) / 512);
            if SIM_FIX
                twf_m0((kk - 1) * 64 + nn) = fi(tw, T, 'fimath', FMT);  
            else
                twf_m0((kk - 1) * 64 + nn) = tw;
            end
        end
    end

    for nn=1:512
        bfly02(nn) = bfly02_tmp(nn) * twf_m0(nn);  % <8.6> * <2.7> = <10.13> 
    end

    % <10.13> -> <10.6> -> <5.6>
    
    %-----------------------------------------------------------------------------
    % Module 1
    %-----------------------------------------------------------------------------
    % step1_0
    for kk=1:8
        for nn=1:32
            bfly10_tmp((kk-1)*64+nn) = bfly02((kk-1)*64+nn) + bfly02((kk-1)*64+32+nn); % <6.6>
            bfly10_tmp((kk-1)*64+32+nn) = bfly02((kk-1)*64+nn) - bfly02((kk-1)*64+32+nn);
        end
    end

    for kk=1:8
        for nn=1:64
            bfly10((kk-1)*64+nn) = bfly10_tmp((kk-1)*64+nn) * fac8_0(ceil(nn/16));  % <6.6>
        end
    end

    % step1_1
    for kk=1:16
        for nn=1:16
            bfly11_tmp((kk-1)*32+nn) = bfly10((kk-1)*32+nn) + bfly10((kk-1)*32+16+nn);  % <7.6>
            bfly11_tmp((kk-1)*32+16+nn) = bfly10((kk-1)*32+nn) - bfly10((kk-1)*32+16+nn);
        end
    end

    for kk=1:8
        for nn=1:64
            bfly11((kk-1)*64+nn) = bfly11_tmp((kk-1)*64+nn) * fac8_1(ceil(nn/8));  % <7.6> * <2.7> = <9.13>
        end 
    end

    % <9.13> -> <9.6> 

    % step1_2 (16)
    for kk=1:32
        for nn=1:8
            bfly12_tmp((kk-1)*16+nn) = bfly11((kk-1)*16+nn) + bfly11((kk-1)*16+8+nn); % <10.6>
            bfly12_tmp((kk-1)*16+8+nn) = bfly11((kk-1)*16+nn) - bfly11((kk-1)*16+8+nn); % <10.6>
        end
    end

    % Data rearrangement
    K2 = [0, 4, 2, 6, 1, 5, 3, 7];
    for kk=1:8
        for nn=1:8
            tw = exp(-1j * 2 * pi * (nn - 1) * K2(kk) / 64);
            if SIM_FIX
                twf_m1((kk - 1) * 8 + nn) = fi(tw, T, 'fimath', FMT);
            else
                twf_m1((kk - 1) * 8 + nn) = tw;
            end
        end
    end

    for kk=1:8
        for nn=1:64
            bfly12((kk-1)*64+nn) = bfly12_tmp((kk-1)*64+nn) * twf_m1(nn); % <10.6> * <2.7> = <12.13>
        end
    end

    % <12.13> -> <12.6> -> <6.6>

    %-----------------------------------------------------------------------------
    % Module 2
    %-----------------------------------------------------------------------------
    % step2_0
    for kk=1:64
        for nn=1:4
            bfly20_tmp((kk-1)*8+nn) = bfly12((kk-1)*8+nn) + bfly12((kk-1)*8+4+nn); % <7.6>
            bfly20_tmp((kk-1)*8+4+nn) = bfly12((kk-1)*8+nn) - bfly12((kk-1)*8+4+nn);
        end
    end

    for kk=1:64
        for nn=1:8
            bfly20((kk-1)*8+nn) = bfly20_tmp((kk-1)*8+nn) * fac8_0(ceil(nn/2)); % <7.6>
        end
    end

    % step2_1
    for kk=1:128
        for nn=1:2
            bfly21_tmp((kk-1)*4+nn) = bfly20((kk-1)*4+nn) + bfly20((kk-1)*4+2+nn); % <8.6>
            bfly21_tmp((kk-1)*4+2+nn) = bfly20((kk-1)*4+nn) - bfly20((kk-1)*4+2+nn);
        end
    end

    for kk=1:64
        for nn=1:8
            bfly21((kk-1)*8+nn) = bfly21_tmp((kk-1)*8+nn) * fac8_1(nn); % <8.6> * <2.7> = <10.13>
        end
    end
    
    % <10.13> -> <10.4>

    % step2_2
    for kk=1:256
        bfly22_tmp((kk-1)*2+1) = bfly21((kk-1)*2+1) + bfly21((kk-1)*2+2); % <11.4> 
        bfly22_tmp((kk-1)*2+2) = bfly21((kk-1)*2+1) - bfly21((kk-1)*2+2); % <11.4>
    end

    bfly22 = bfly22_tmp; % <11.4> -> <9.4> 

    %-----------------------------------------------------------------------------
    % Index 
    %-----------------------------------------------------------------------------
    fp = fopen('fixed_reorder_index.txt', 'w');
    for jj = 1:512
        kk = bitget(jj-1,9)*1 + bitget(jj-1,8)*2 + bitget(jj-1,7)*4 + bitget(jj-1,6)*8 + ...
             bitget(jj-1,5)*16 + bitget(jj-1,4)*32 + bitget(jj-1,3)*64 + ...
             bitget(jj-1,2)*128 + bitget(jj-1,1)*256;
        dout(kk+1) = bfly22(jj);
        fprintf(fp, 'jj=%d, kk=%d, dout(%d)=%f+j%f\n', jj, kk, kk+1, ...
                double(real(dout(kk+1))), double(imag(dout(kk+1))));
    end
    fclose(fp);

    if fft_mode == 1
        fft_out = dout;
        module2_out = bfly22;
    else
        fft_out = conj(dout) / 512;
        module2_out = conj(bfly22) / 512;
    end
    
    % 출력 ----------------------------------------------------------------------
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
    fp=fopen('bfly21.txt_fixed','w');
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
