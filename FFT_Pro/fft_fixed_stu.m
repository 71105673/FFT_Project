% Added on 2024/07/02 by jihan 
function [fft_out, module2_out] = fft_fixed_stu(fft_mode, fft_in)

 shift = 0;

    din = fft_in; % <2.7> => <3.6>
    
 fac8_0 = [1, 1, 1, -j];
 %fac8_1 = [1, 1, 1, -j, 1, 0.7071-0.7071j, 1, -0.7071-0.7071j]; % floating
 fac8_1 = [256, 256, 256, -j*256, 256, 181-j*181, 256, -181-j*181]; % fixed <2.8>

 %-----------------------------------------------------------------------------
 % Module 0
 %-----------------------------------------------------------------------------
 % step0_0
 % m1: din - 9bit; bfly00 - 10bit 
 bfly00_out0 = din(1:256) + din(257:512); % <4.6>
 bfly00_out1 = din(1:256) - din(257:512);

 bfly00_tmp = [bfly00_out0, bfly00_out1]; 

 for nn=1:512
	bfly00(nn) = bfly00_tmp(nn)*fac8_0(ceil(nn/128)); % <4.6>
 end

 
 % step0_1
 % m1: bfly00 - 10bit; bfly01_tmp - 11bit; bfly01 - 13bit
 for kk=1:2
  for nn=1:128
	bfly01_tmp((kk-1)*256+nn) = bfly00((kk-1)*256+nn) + bfly00((kk-1)*256+128+nn); % <5.6>
	bfly01_tmp((kk-1)*256+128+nn) = bfly00((kk-1)*256+nn) - bfly00((kk-1)*256+128+nn);
  end
 end

 fp_1=fopen('bfly01.txt','w');
 for nn=1:512
	temp_bfly01(nn) = bfly01_tmp(nn)*fac8_1(ceil(nn/64)); % <2.8> * <5.6> = <7.14>
	bfly01(nn) = round(temp_bfly01(nn)/256); % <7.14> -> <7.6>
	fprintf(fp_1, 'bfly01_tmp(%d)=%d+j%d, temp_bfly01(%d)=%d+j%d, bfly01(%d)=%d+j%d\n',nn, real(bfly01_tmp(nn)), imag(bfly01_tmp(nn)),nn,real(temp_bfly01(nn)),imag(temp_bfly01(nn)),nn,real(bfly01(nn)),imag(bfly01(nn)));
 end
 fclose(fp_1);

 % step0_2
 % m1: bfly01 - 13bit<7.6> ; bfly02_tmp - 14bit<8.6>; pre_bfly02 - 23bit; bfly02 - 11bit<5.6>
 for kk=1:4
  for nn=1:64
	bfly02_tmp((kk-1)*128+nn) = bfly01((kk-1)*128+nn) + bfly01((kk-1)*128+64+nn);
	bfly02_tmp((kk-1)*128+64+nn) = bfly01((kk-1)*128+nn) - bfly01((kk-1)*128+64+nn);
  end
 end

 for ii=1:512
 	%bfly02_tmp = sat(bfly02_tmp, 13); % Saturatin (13 bit)
 	bfly02_tmp(ii) = sat(bfly02_tmp(ii), 13); % Saturatin (13 bit) <7.6>
 end

 % Data rearrangement
 K3 = [0, 4, 2, 6, 1, 5, 3, 7];

 for kk=1:8
  for nn=1:64
	flo_twf_m0((kk-1)*64+nn) = exp(-j*2*pi*(nn-1)*(K3(kk))/512);
	twf_m0((kk-1)*64+nn) = round(flo_twf_m0((kk-1)*64+nn)*128); % twf_m0 : <2.7>
  end
 end

 for nn=1:512
	%bfly02(nn) = bfly02_tmp(nn)*twf_m0(nn); % Org          
	pre_bfly02(nn) = bfly02_tmp(nn)*twf_m0(nn); % (13bit(12+1) * 9bit = 22bit + signed 1bit = 23bit)  <2.7> * <7.6> = <9.13>
    % singeed extention을 진행해 1bit 확장을 염두 -> magdetect를 위해서.
 end


    % 출력------------------------------------------------------------------------
     fp=fopen('pre_bfly02.txt','w');
     for nn=1:512
       fprintf(fp, 'pre_bfly02(%d)=%f+j%f\n',nn,real(pre_bfly02(nn)),imag(pre_bfly02(nn)));
     end
     fclose(fp);
    %----------------------------------------------------------------------------

 % CBFP(Convergent Block Floating Point) stage0
 cnt1_re = zeros(1,8);
 cnt1_im = zeros(1,8);
 for ii=1:8
  for jj=1:64
	tmp1_re=mag_detect(real(pre_bfly02(64*(ii-1)+jj)),23);
	tmp1_im=mag_detect(imag(pre_bfly02(64*(ii-1)+jj)),23);
    % 블록 내에서 실수부/허수부 시프트 카운트의 최소값을 계속 갱신
    % (가장 큰 절댓값에 해당하는 가장 작은 시프트 카운트를 찾는 과정)
	temp1_re=min_detect(jj,tmp1_re,cnt1_re(ii));
	temp1_im=min_detect(jj,tmp1_im,cnt1_im(ii));
	cnt1_re(ii)=temp1_re;
	cnt1_im(ii)=temp1_im;
  end
 end

 % 각 블록에 대해 실수부와 허수부의 시프트 카운트 중 더 작은 값으로 통일
 for ii=1:8
  if (cnt1_re(ii)<=cnt1_im(ii))         % 실수부 시프트 카운트가 더 작거나 같으면 그대로 유지
	cnt1_re(ii)=cnt1_re(ii);
  else
	cnt1_re(ii)=cnt1_im(ii);            % 허수부 시프트 카운트가 더 작으면 실수부 시프트 카운트를 허수부로 맞춤 (더 보수적으로)
  end
 end
		
 for ii=1:8
  if (cnt1_im(ii)<=cnt1_re(ii))         % 허수부 시프트 카운트가 더 작거나 같으면 그대로 유지
	cnt1_im(ii)=cnt1_im(ii);
  else
	cnt1_im(ii)=cnt1_re(ii);            % 실수부 시프트 카운트가 더 작으면 허수부 시프트 카운트를 실수부로 맞춤 (더 보수적으로)
  end
 end

 for ii=1:8
  for jj=1:64
    % 결정된 블록별 시프트 카운트를 전체 512개 데이터에 대해 복사
	index1_re(64*(ii-1)+jj)=cnt1_re(ii);
	index1_im(64*(ii-1)+jj)=cnt1_im(ii);
  end
 end

 % CBFP (Convergent Block Floating Point) 스테이지 0 - 비트 스케일 조정 (실수부 처리)
 % 이 부분은 pre_bfly02 복소수 배열의 실수부(real) 값들을 동적으로 스케일 조정하여
 % 오버플로우를 방지하고 정밀도를 최적화하는 과정
 for ii=1:8
  for jj=1:64
   if (cnt1_re(ii)>12)  % 경우 1: 시프트 가능 비트 수(cnt1_re(ii))가 12보다 큰 경우, 여유 공간 존재
	re_bfly02(64*(ii-1)+jj)=bitshift(bitshift(real(pre_bfly02(64*(ii-1)+jj)),cnt1_re(ii), 'int32'),-12, 'int32');
    % 23중 12보다 작으면 ex)8bit면, cnt_re = 23 - 8 > 12 
    % 왼쪽으로 cnt_re=15bit 하여 23bit 만듬 그 후에 12bit를 빼서 다시 11bit으로 만듬
   else
    re_bfly02(64*(ii-1)+jj)=bitshift(real(pre_bfly02(64*(ii-1)+jj)),(-12+cnt1_re(ii)), 'int32'); 
    % 23중 12보다 크면 ex)15bit이면 cnt_re = 23 - 15 < 12
    % -12+cnt_re = -4 따라서 음수 4bit를 오르쪽 쉬프트 하여 짤라내어 11bit로 만듬(범위를 안전하게 줄임)
   end
  end
 end

 for ii=1:8
  for jj=1:64
   if (cnt1_im(ii)>12)
	im_bfly02(64*(ii-1)+jj)=bitshift(bitshift(imag(pre_bfly02(64*(ii-1)+jj)),cnt1_im(ii), 'int32'),-12, 'int32');
   else
	im_bfly02(64*(ii-1)+jj)=bitshift(imag(pre_bfly02(64*(ii-1)+jj)),(-12+cnt1_im(ii)), 'int32');
   end
  end
 end

 fp_2=fopen('cbfp_0.txt','w');
 for nn=1:512
	bfly02(nn) = re_bfly02(nn) + j*im_bfly02(nn);  
	fprintf(fp_2, 'twf_m0(%d)=%d+j%d, pre_bfly02(%d)=%d+j%d, index1_re(%d)=%d, index1_im(%d)=%d, bfly02(%d)=%d+j%d\n',nn, real(twf_m0(nn)), imag(twf_m0(nn)), nn, real(pre_bfly02(nn)), imag(pre_bfly02(nn)), nn, index1_re(nn), nn, index1_im(nn), nn, real(bfly02(nn)), imag(bfly02(nn)));
 end
 fclose(fp_2);
 
 %-----------------------------------------------------------------------------
 % Module 1
 %-----------------------------------------------------------------------------
 % step1_0
 % m1: bfly02 - 11bit; bfly10 - 12bit;

 for kk=1:8
  for nn=1:32
	bfly10_tmp((kk-1)*64+nn) = bfly02((kk-1)*64+nn) + bfly02((kk-1)*64+32+nn);
	bfly10_tmp((kk-1)*64+32+nn) = bfly02((kk-1)*64+nn) - bfly02((kk-1)*64+32+nn);
  end
 end

 for ii=1:512
 	bfly10_tmp(ii) = sat(bfly10_tmp(ii), 12); % Saturatin (12 bit)
 end

 for kk=1:8
  for nn=1:64
	bfly10((kk-1)*64+nn) = bfly10_tmp((kk-1)*64+nn)*fac8_0(ceil(nn/16)); % 12
  end
 end

    % % 출력 ----------------------------------------------------------------------
    % fp=fopen('bfly10_fixed.txt','w');
    % for nn=1:512
    %     fprintf(fp, 'bfly10(%d)=%f+j%f\n',nn,real(bfly10(nn)),imag(bfly10(nn)));
    % end
    % fclose(fp);
    % %----------------------------------------------------------------------------

 % step1_1
 % m1: bfly10 - 12bit; bfly11_tmp - 13bit; bfly11 - 15bit;
 for kk=1:16
  for nn=1:16
	bfly11_tmp((kk-1)*32+nn) = bfly10((kk-1)*32+nn) + bfly10((kk-1)*32+16+nn);
	bfly11_tmp((kk-1)*32+16+nn) = bfly10((kk-1)*32+nn) - bfly10((kk-1)*32+16+nn);
  end
 end

 for kk=1:8
  for nn=1:64
	temp_bfly11((kk-1)*64+nn) = bfly11_tmp((kk-1)*64+nn)*fac8_1(ceil(nn/8)); % 13 * 10 = 23bit
	bfly11((kk-1)*64+nn) = round(temp_bfly11((kk-1)*64+nn)/256); % 23 - 8 = 15bit
  end
 end

    % 출력 ----------------------------------------------------------------------
     fp=fopen('temp_bfly11_fixed.txt','w');
     for nn=1:512
       fprintf(fp, 'temp_bfly11(%d)=%f+j%f\n',nn,real(temp_bfly11(nn)),imag(temp_bfly11(nn)));
     end
     fclose(fp);
    %----------------------------------------------------------------------------

 fp_3=fopen('bfly11.txt','w');
 for nn=1:512
	fprintf(fp_3, 'bfly11_tmp(%d)=%d+j%d, temp_bfly11(%d)=%d+j%d, bfly11(%d)=%d+j%d\n',nn, real(bfly11_tmp(nn)), imag(bfly11_tmp(nn)),nn, real(temp_bfly11(nn)), imag(temp_bfly11(nn)),nn, real(bfly11(nn)), imag(bfly11(nn)));
 end
 fclose(fp_3);


 % step1_2
 % m1: bfly11 - 15bit; bfly12_tmp - 16bit; pre_bfly12 - 26bit; bfly12 - 12bit;
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
	flo_twf_m1((kk-1)*8+nn) = exp(-j*2*pi*(nn-1)*(K2(kk))/64);
	twf_m1((kk-1)*8+nn) = round(flo_twf_m1((kk-1)*8+nn)*128); % twf_m0 : <2.7>
  end
 end

 for kk=1:8
  for nn=1:64
	pre_bfly12((kk-1)*64+nn) = bfly12_tmp((kk-1)*64+nn)*twf_m1(nn); % (17bit(16+1) * 9bit = 26 bit) 
  end                                                               % 26이 맞긴 하지만, 교수님 기준<1.8>이라 25가 됨 이미 module0에서 늘렸기에 25도 무방
 end                   

     % 출력------------------------------------------------------------------------
     fp=fopen('pre_bfly12.txt','w');
     for nn=1:512
       fprintf(fp, 'pre_bfly12(%d)=%f+j%f\n',nn,real(pre_bfly12(nn)),imag(pre_bfly12(nn)));
     end
     fclose(fp);
    %----------------------------------------------------------------------------
                                                              
 % CBFP(Convergent Block Floating Point) stage1
 cnt2_re = zeros(1,64);
 cnt2_im = zeros(1,64);
 for ii=1:64
  for jj=1:8
	tmp2_re=mag_detect(real(pre_bfly12(8*(ii-1)+jj)),25);
	tmp2_im=mag_detect(imag(pre_bfly12(8*(ii-1)+jj)),25);
	temp2_re=min_detect(jj,tmp2_re,cnt2_re(ii));
	temp2_im=min_detect(jj,tmp2_im,cnt2_im(ii));
	cnt2_re(ii)=temp2_re;
	cnt2_im(ii)=temp2_im;
  end
 end

 %{ 
 for ii=1:64
	X=sprintf('cnt2_re(%d)=%d\n', ii, cnt2_re(ii));
	disp(X);
 end
 %}

 for ii=1:64
  if (cnt2_re(ii)<=cnt2_im(ii))
	cnt2_re(ii)=cnt2_re(ii);
  else
	cnt2_re(ii)=cnt2_im(ii);
  end
 end
		
 for ii=1:64
  if (cnt2_im(ii)<=cnt2_re(ii))
	cnt2_im(ii)=cnt2_im(ii);
  else
	cnt2_im(ii)=cnt2_re(ii);
  end
 end

 for ii=1:64
  for jj=1:8
	index2_re(8*(ii-1)+jj)=cnt2_re(ii);
	index2_im(8*(ii-1)+jj)=cnt2_im(ii);
  end
 end

 
 for ii=1:64
  for jj=1:8
   if (cnt2_re(ii)>13)
	re_bfly12(8*(ii-1)+jj)=bitshift(bitshift(real(pre_bfly12(8*(ii-1)+jj)),cnt2_re(ii), 'int32'),-13, 'int32');
   else
	re_bfly12(8*(ii-1)+jj)=bitshift(real(pre_bfly12(8*(ii-1)+jj)),(-13+cnt2_re(ii)), 'int32');
   end
  end
 end


 for ii=1:64
  for jj=1:8
   if (cnt2_im(ii)>13)
	im_bfly12(8*(ii-1)+jj)=bitshift(bitshift(imag(pre_bfly12(8*(ii-1)+jj)),cnt2_im(ii), 'int32'),-13, 'int32');
   else
	im_bfly12(8*(ii-1)+jj)=bitshift(imag(pre_bfly12(8*(ii-1)+jj)),(-13+cnt2_im(ii)), 'int32');
   end
  end
 end


 fp_4=fopen('cbfp_1.txt','w');
 for nn=1:512
	bfly12(nn) = re_bfly12(nn) + j*im_bfly12(nn);  
	%fprintf(fp_4, 'twf_m1(%d)=%d+j%d, pre_bfly12(%d)=%d+j%d, index2_re(%d)=%d, index2_im(%d)=%d, bfly12(%d)=%d+j%d\n',nn, real(twf_m1(nn)), imag(twf_m1(nn)), nn, real(pre_bfly12(nn)), imag(pre_bfly12(nn)), nn, index2_re(nn), nn, index2_im(nn), nn, real(bfly12(nn)), imag(bfly12(nn)));
	fprintf(fp_4, 'pre_bfly12(%d)=%d+j%d, index2_re(%d)=%d, index2_im(%d)=%d, bfly12(%d)=%d+j%d\n', nn, real(pre_bfly12(nn)), imag(pre_bfly12(nn)), nn, index2_re(nn), nn, index2_im(nn), nn, real(bfly12(nn)), imag(bfly12(nn)));
 end
 fclose(fp_4);


 %-----------------------------------------------------------------------------
 % Module 2
 %-----------------------------------------------------------------------------
 % step2_0
 % m1: bfly12 - 12bit; bfly20 - 13bit;
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

 % step2_1
 % m1: bfly20 - 13bit; bfly21_tmp - 14bit; bfly21 - 15bit;
 for kk=1:128
  for nn=1:2
	bfly21_tmp((kk-1)*4+nn) = bfly20((kk-1)*4+nn) + bfly20((kk-1)*4+2+nn);
	bfly21_tmp((kk-1)*4+2+nn) = bfly20((kk-1)*4+nn) - bfly20((kk-1)*4+2+nn);
  end
 end

 for ii=1:512
 	bfly21_tmp(ii) = sat(bfly21_tmp(ii), 14); % Saturatin (14 bit)
 end

 for kk=1:64
  for nn=1:8
	temp_bfly21((kk-1)*8+nn) = bfly21_tmp((kk-1)*8+nn)*fac8_1(nn);
	bfly21((kk-1)*8+nn) = round(temp_bfly21((kk-1)*8+nn)/256);
  end
 end

 fp_5=fopen('bfly21.txt','w');
 for nn=1:512
	fprintf(fp_5, 'bfly21_tmp(%d)=%d+j%d, temp_bfly21(%d)=%d+j%d, bfly21(%d)=%d+j%d\n',nn, real(bfly21_tmp(nn)), imag(bfly21_tmp(nn)),nn, real(temp_bfly21(nn)), imag(temp_bfly21(nn)),nn, real(bfly21(nn)), imag(bfly21(nn)));
 end
 fclose(fp_5);

 % step2_2
 % m1: bfly21 - 15bit; bfly22_tmp - 16bit; bfly22 - 13bit;
 for kk=1:256
	bfly22_tmp((kk-1)*2+1) = bfly21((kk-1)*2+1) + bfly21((kk-1)*2+2);
	bfly22_tmp((kk-1)*2+2) = bfly21((kk-1)*2+1) - bfly21((kk-1)*2+2);
 end

 for ii=1:512
 	bfly22_tmp(ii) = sat(bfly22_tmp(ii), 16); % Saturatin (16 bit)
 end
    
 for kk=1:512
	indexsum_re(kk)=index1_re(kk)+index2_re(kk);
	indexsum_im(kk)=index1_im(kk)+index2_im(kk);
 end

 for ii=1:512
  if (indexsum_re(ii)>=23)
	re_bfly22(ii) = 0;
  else
	re_bfly22(ii) = bitshift(real(bfly22_tmp(ii)), (9-indexsum_re(ii)), 'int32'); % 16bit => 13bit <8.5> => <9.4> (FFT)
  end
 end
 
 for ii=1:512
  if (indexsum_im(ii)>=23)
	im_bfly22(ii) = 0;
  else
	im_bfly22(ii) = bitshift(imag(bfly22_tmp(ii)), (9-indexsum_im(ii)), 'int32'); % 16bit => 13bit <9.4> (FFT)
  end
 end

 for nn=1:512
	bfly22(nn) = re_bfly22(nn) + j*im_bfly22(nn);
 end


 %bfly22 = bfly22_tmp;

 %-----------------------------------------------------------------------------
 % Index 
 %-----------------------------------------------------------------------------
 fp=fopen('fxd_reorder_index.txt','w');
 for jj=1:512
	%kk = bitget(jj-1,9)*(2^0) + bitget(jj-1,8)*(2^1) + bitget(jj-1,7)*(2^2) + bitget(jj-1,6)*(2^3) + bitget(jj-1,5)*(2^4) + bitget(jj-1,4)*(2^5) + bitget(jj-1,3)*(2^6) + bitget(jj-1,2)*(2^7) + bitget(jj-1,1)*(2^8);
	kk = bitget(jj-1,9)*1 + bitget(jj-1,8)*2 + bitget(jj-1,7)*4 + bitget(jj-1,6)*8 + bitget(jj-1,5)*16 + bitget(jj-1,4)*32 + bitget(jj-1,3)*64 + bitget(jj-1,2)*128 + bitget(jj-1,1)*256;
	dout(kk+1) = bfly22(jj); % With reorder
	fprintf(fp, 'jj=%d, kk=%d, dout(%d)=%d+j%d, indexsum=%d\n',jj, kk,(kk+1),real(dout(kk+1)),imag(dout(kk+1)),indexsum_re(kk+1));
 end
 fclose(fp);

 % 추가 코드
 if fft_mode == 1
	fft_out = dout;
	module2_out = bfly22;
 else
     fft_out = conj(dout) / 512; 
     module2_out = conj(bfly22) / 512;
 end


    % % 출력------------------------------------------------------------------------
    % fp=fopen('bfly00_tmp_fixed.txt','w');
    % for nn=1:512
    %   fprintf(fp, 'bfly00_tmp(%d)=%f+j%f\n',nn,real(bfly00_tmp(nn)),imag(bfly00_tmp(nn)));
    % end
    % fclose(fp);
    % %----------------------------------------------------------------------------
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
    %   fprintf(fp, 'bfly22_tmp(%d)=%f+j%f\n',nn,real(bfly22_tmp(nn)),imag(bfly22_tmp(nn)));
    % end
    % fclose(fp);
    % %---------------------------------------------------------------------------
    % 
    % % 출력 ----------------------------------------------------------------------
    % fp=fopen('bfly22_fixed.txt','w');
    % for nn=1:512  
    %   fprintf(fp, 'bfly22(%d)=%f+j%f\n',nn,real(bfly22(nn)),imag(bfly22(nn)));
    % end
    % fclose(fp);
    % %----------------------------------------------------------------------------