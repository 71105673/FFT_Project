% Added on 2025/07/01 by jihan 
function [fft_out, module2_out] = fft_float_5(fft_mode, fft_in)

 shift = 0;
 SIM_FIX = 0; % 0: float, 1: fixed

 if (fft_mode==1) % fft
	din = fft_in; % <3.6>
 else % ifft
	din = conj(fft_in);
 end

 fac8_0 = [1, 1, 1, -j]; % <2.7>
 fac8_2 = [1, 1, 1, -j, 1, 0.7071-0.7071j, 1, -0.7071-0.7071j]; % <2.7>
 fac8_1 = round(fac8_2 * 128);

 %-----------------------------------------------------------------------------
 % Module 0
 %-----------------------------------------------------------------------------
 % step0_0
 bfly00_out0 = din(1:256) + din(257:512); % <4.6>
 bfly00_out1 = din(1:256) - din(257:512);

 bfly00_tmp = [bfly00_out0, bfly00_out1];

 for nn=1:512
	bfly00(nn) = bfly00_tmp(nn)*fac8_0(ceil(nn/128));
 end

 % step0_1
 for kk=1:2
  for nn=1:128
	bfly01_tmp((kk-1)*256+nn) = bfly00((kk-1)*256+nn) + bfly00((kk-1)*256+128+nn); % <5.6>
	bfly01_tmp((kk-1)*256+128+nn) = bfly00((kk-1)*256+nn) - bfly00((kk-1)*256+128+nn);
  end
 end


 for nn=1:512
	bfly01(nn) = round(bfly01_tmp(nn)*fac8_1(ceil(nn/64)) /128); % <7.13>
    bfly01_re(nn) = real(bfly01(nn));
    bfly01_im(nn) = imag(bfly01(nn));
    if (bfly01_re(nn) > 1023) % <7.6>
        bfly01_re_1(nn) = 1023;
    elseif (bfly01_re(nn) < -1024)
        bfly01_re_1(nn) = -1024;
    else
        bfly01_re_1(nn) = bfly01_re(nn);
    end
    if (bfly01_im(nn) > 1023) % <7.6>
        bfly01_im_1(nn) = 1023;
    elseif (bfly01_im(nn) < -1024)
        bfly01_im_1(nn) = -1024;
    else
        bfly01_im_1(nn) = bfly01_im(nn);
    end
    bfly01_sa(nn) = bfly01_re_1(nn) + j*bfly01_im_1(nn);
 end % <5.6>

 % step0_2
 for kk=1:4
  for nn=1:64
	bfly02_tmp((kk-1)*128+nn) = bfly01_sa((kk-1)*128+nn) + bfly01_sa((kk-1)*128+64+nn); % <6.6>
	bfly02_tmp((kk-1)*128+64+nn) = bfly01_sa((kk-1)*128+nn) - bfly01_sa((kk-1)*128+64+nn);
  end
 end

 % Data rearrangement
 K3 = [0, 4, 2, 6, 1, 5, 3, 7];

 for kk=1:8
  for nn=1:64
	twf_m0((kk-1)*64+nn) = round(exp(-j*2*pi*(nn-1)*(K3(kk))/512) *128); % <2.7>
  end
 end

 for nn=1:512
	bfly02(nn) = round(bfly02_tmp(nn)*twf_m0(nn)/128); % <8.13>
    bfly02_re(nn) = real(bfly02(nn));
    bfly02_im(nn) = imag(bfly02(nn));
    if (bfly02_re(nn) > 1023) % <8.6>
        bfly02_re_1(nn) = 1023;
    elseif (bfly02_re(nn) < -1024)
        bfly02_re_1(nn) = -1024;
    else
        bfly02_re_1(nn) = bfly02_re(nn);
    end
    if (bfly02_im(nn) > 1023) % <8.6>
        bfly02_im_1(nn) = 1023;
    elseif (bfly02_im(nn) < -1024)
        bfly02_im_1(nn) = -1024;
    else
        bfly02_im_1(nn) = bfly02_im(nn);
    end
    bfly02_sa(nn) = bfly02_re_1(nn) + j*bfly02_im_1(nn);
 end % <5.6>

 fm0=fopen('reorder_index_m0_fixed.txt','w');
 for jj=1:512
	dout(jj) = bfly02_sa(jj); % With reorder
	fprintf(fm0, 'jj=%d, dout(%d)=%f+j%f\n',jj, jj, real(dout(jj)), imag(dout(jj)));
 end
 fclose(fm0);
 

 %-----------------------------------------------------------------------------
 % Module 1
 %-----------------------------------------------------------------------------
 % step1_0
 for kk=1:8
  for nn=1:32
	bfly10_tmp((kk-1)*64+nn) = bfly02_sa((kk-1)*64+nn) + bfly02_sa((kk-1)*64+32+nn); % <6.6>
	bfly10_tmp((kk-1)*64+32+nn) = bfly02_sa((kk-1)*64+nn) - bfly02_sa((kk-1)*64+32+nn);
  end
 end

 for kk=1:8
  for nn=1:64
	bfly10((kk-1)*64+nn) = bfly10_tmp((kk-1)*64+nn)*fac8_0(ceil(nn/16));
  end
 end

 % step1_1
 for kk=1:16
  for nn=1:16
	bfly11_tmp((kk-1)*32+nn) = bfly10((kk-1)*32+nn) + bfly10((kk-1)*32+16+nn); % <7.6>
	bfly11_tmp((kk-1)*32+16+nn) = bfly10((kk-1)*32+nn) - bfly10((kk-1)*32+16+nn);
  end
 end

 for kk=1:8
  for nn=1:64
	bfly11((kk-1)*64+nn) = round(bfly11_tmp((kk-1)*64+nn)*fac8_1(ceil(nn/8))/128); % <9.13>
    bfly11_re((kk-1)*64+nn) = real(bfly11((kk-1)*64+nn));
    bfly11_im((kk-1)*64+nn) = imag(bfly11((kk-1)*64+nn));
    if (bfly11_re((kk-1)*64+nn) > 2047) % <9.6>
        bfly11_re_1((kk-1)*64+nn) = 2047;
    elseif (bfly11_re((kk-1)*64+nn) < -2048)
        bfly11_re_1((kk-1)*64+nn) = -2048;
    else
        bfly11_re_1((kk-1)*64+nn) = bfly11_re((kk-1)*64+nn);
    end
    if (bfly11_im((kk-1)*64+nn) > 2047) % <9.6>
        bfly11_im_1((kk-1)*64+nn) = 2047;
    elseif (bfly11_im((kk-1)*64+nn) < -2048)
        bfly11_im_1((kk-1)*64+nn) = -2048;
    else
        bfly11_im_1((kk-1)*64+nn) = bfly11_im((kk-1)*64+nn);
    end
    bfly11_sa((kk-1)*64+nn) = bfly11_re_1((kk-1)*64+nn) + j * bfly11_im_1((kk-1)*64+nn);
  end
 end % <6.6>

 % step1_2
 for kk=1:32
  for nn=1:8
	bfly12_tmp((kk-1)*16+nn) = bfly11_sa((kk-1)*16+nn) + bfly11_sa((kk-1)*16+8+nn); % <7.6>
	bfly12_tmp((kk-1)*16+8+nn) = bfly11_sa((kk-1)*16+nn) - bfly11_sa((kk-1)*16+8+nn);
  end
 end

 % Data rearrangement
 K2 = [0, 4, 2, 6, 1, 5, 3, 7];

 for kk=1:8
  for nn=1:8
	twf_m1((kk-1)*8+nn) = round(exp(-j*2*pi*(nn-1)*(K2(kk))/64)*128);
  end
 end

 for kk=1:8
  for nn=1:64
	bfly12((kk-1)*64+nn) = round(bfly12_tmp((kk-1)*64+nn)*twf_m1(nn)/128); % <9.13>
    bfly12_re((kk-1)*64+nn) = real(bfly12((kk-1)*64+nn));
    bfly12_im((kk-1)*64+nn) = imag(bfly12((kk-1)*64+nn));
    if (bfly12_re((kk-1)*64+nn) > 2047) % <9.6>
        bfly12_re_1((kk-1)*64+nn) = 2047;
    elseif (bfly12_re((kk-1)*64+nn) < -2048)
        bfly12_re_1((kk-1)*64+nn) = -2048;
    else
        bfly12_re_1((kk-1)*64+nn) = bfly12_re((kk-1)*64+nn);
    end
    if (bfly12_im((kk-1)*64+nn) > 2047) % <9.6>
        bfly12_im_1((kk-1)*64+nn) = 2047;
    elseif (bfly12_im((kk-1)*64+nn) < -2048)
        bfly12_im_1((kk-1)*64+nn) = -2048;
    else
        bfly12_im_1((kk-1)*64+nn) = bfly12_im((kk-1)*64+nn);
    end
    bfly12_sa((kk-1)*64+nn) = bfly12_re_1((kk-1)*64+nn) + j * bfly12_im_1((kk-1)*64+nn);
  end % <6.6>
 end

 fm1=fopen('reorder_index_m1_fixed.txt','w');
 for jj=1:512
	dout(jj) = bfly12_sa(jj); % With reorder
	fprintf(fm1, 'jj=%d, dout(%d)=%f+j%f\n',jj, jj, real(dout(jj)), imag(dout(jj)));
 end
 fclose(fm1);

 %-----------------------------------------------------------------------------
 % Module 2
 %-----------------------------------------------------------------------------
 % step2_0
 for kk=1:64
  for nn=1:4
	bfly20_tmp((kk-1)*8+nn) = bfly12_sa((kk-1)*8+nn) + bfly12_sa((kk-1)*8+4+nn); % <7.6>
	bfly20_tmp((kk-1)*8+4+nn) = bfly12_sa((kk-1)*8+nn) - bfly12_sa((kk-1)*8+4+nn);
  end
 end

 for kk=1:64
  for nn=1:8
	bfly20((kk-1)*8+nn) = bfly20_tmp((kk-1)*8+nn)*fac8_0(ceil(nn/2));
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
	bfly21((kk-1)*8+nn) = round(bfly21_tmp((kk-1)*8+nn)*fac8_1(nn)/512); % <10.13>
    bfly21_re((kk-1)*8+nn) = real(bfly21((kk-1)*8+nn));
    bfly21_im((kk-1)*8+nn) = imag(bfly21((kk-1)*8+nn));
    if (bfly21_re((kk-1)*8+nn) > 4095) % <10.4>
        bfly21_re_1((kk-1)*8+nn) = 4095;
    elseif (bfly21_re((kk-1)*8+nn) < -4096)
        bfly21_re_1((kk-1)*8+nn) = -4096;
    else
        bfly21_re_1((kk-1)*8+nn) = bfly21_re((kk-1)*8+nn);
    end
    if (bfly21_im((kk-1)*8+nn) > 4095) % <10.4>
        bfly21_im_1((kk-1)*8+nn) = 4095;
    elseif (bfly21_im((kk-1)*8+nn) < -4096)
        bfly21_im_1((kk-1)*8+nn) = -4096;
    else
        bfly21_im_1((kk-1)*8+nn) = bfly21_im((kk-1)*8+nn);
    end
    bfly21_sa((kk-1)*8+nn) = bfly21_re_1((kk-1)*8+nn) + j * bfly21_im_1((kk-1)*8+nn);
  end
 end % <9.4>

 % step2_2
 for kk=1:256
	bfly22_tmp((kk-1)*2+1) = bfly21_sa((kk-1)*2+1) + bfly21_sa((kk-1)*2+2); % <10.4>
	bfly22_tmp((kk-1)*2+2) = bfly21_sa((kk-1)*2+1) - bfly21_sa((kk-1)*2+2);
 end 
 
 bfly22 = bfly22_tmp;

 for kk=1:64
  for nn=1:8
    bfly22_re((kk-1)*8+nn) = real(bfly22((kk-1)*8+nn));
    bfly22_im((kk-1)*8+nn) = imag(bfly22((kk-1)*8+nn));
    if (bfly22_re((kk-1)*8+nn) > 4095) % <10.4>
        bfly22_re_1((kk-1)*8+nn) = 4095;
    elseif (bfly22_re((kk-1)*8+nn) < -4096)
        bfly22_re_1((kk-1)*8+nn) = -4096;
    else
        bfly22_re_1((kk-1)*8+nn) = bfly22_re((kk-1)*8+nn);
    end
    if (bfly22_im((kk-1)*8+nn) > 4095) % <10.4>
        bfly22_im_1((kk-1)*8+nn) = 4095;
    elseif (bfly22_im((kk-1)*8+nn) < -4096)
        bfly22_im_1((kk-1)*8+nn) = -4096;
    else
        bfly22_im_1((kk-1)*8+nn) = bfly22_im((kk-1)*8+nn);
    end
    bfly22_sa((kk-1)*8+nn) = bfly22_re_1((kk-1)*8+nn) + j * bfly22_im_1((kk-1)*8+nn);
  end % <9.4>
 end
 
 %-----------------------------------------------------------------------------
 % Index 
 %-----------------------------------------------------------------------------
 fp = fopen('reorder_index_fixed_m2.txt','w');
for jj = 1:512
    kk = bitget(jj-1,9)*1 + bitget(jj-1,8)*2 + bitget(jj-1,7)*4 + ...
         bitget(jj-1,6)*8 + bitget(jj-1,5)*16 + bitget(jj-1,4)*32 + ...
         bitget(jj-1,3)*64 + bitget(jj-1,2)*128 + bitget(jj-1,1)*256;

    dout(kk+1) = bfly22_sa(jj); % bit-reversed reorder
    fprintf(fp, 'jj=%d, kk=%d, dout(%d)=%f+j%f\n', jj, kk, kk+1, real(dout(kk+1)), imag(dout(kk+1)));
end

% 배열 출력은 따로 처리
fprintf(fp, 'fac8_1 = ');
fprintf(fp, '%d ', fac8_1);
fprintf(fp, '\n');

fprintf(fp, 'twf_m0 = ');
fprintf(fp, '%d ', twf_m0);
fprintf(fp, '\n');

fprintf(fp, 'twf_m1 = ');
fprintf(fp, '%d ', twf_m1);
fprintf(fp, '\n');

fclose(fp);


 if (fft_mode==1) % fft
	fft_out = dout;
	module2_out = bfly22;
 else % ifft
	fft_out = conj(dout)/512; 
	module2_out = conj(bfly22)/512;

 end

end
