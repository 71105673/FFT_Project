% Added on 2024/01/29 by jihan 
% 주어진 입력 데이터의 절댓값에 따라 스케일링을 위한 쉬프트 카운터
function [cnt] = mag_detect(in_dat, num) 

  n=0;

  out_dat=dec_to_bin(in_dat, num);      % 입력 데이터를 2진수 비트 배열로 변환

  if (out_dat(num)==0)                  % 최상위 비트(MSB)가 0인 경우 (양수 또는 작은 음수)
   for i=1:num-1
    if (out_dat(num-i)==0)              % MSB 다음 비트부터 0의 개수를 셈
	n=n+1;                              % 0의 갯수를 센다
    else
	break                               % 1이 나오면 중단
    end	
   end
  else                                  % 최상위 비트(MSB)가 1인 경우 (음수)
   for i=1:num-1
    if (out_dat(num-i)==1) 
	n=n+1;
    else
	break                               % 0이 나오면 중단
    end
   end
  end

  cnt=n;                                % 계산된 0 또는 1의 연속 개수 (시프트 카운트) 반환

end

% 입력 값에 대한 절댓 값을 받는다. 