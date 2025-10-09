% Added on 2024/01/29 by jihan 
function [cnt] = mag_detect(in_dat, num) 

  n=0;
  % 가장 앞 비트에서부터 얼마나 많은 
  % 동일한 비트(0 또는 1)가 연속되는지를 세기 위한 카운터.

  out_dat=dec_to_bin(in_dat, num); 
  % in_dat는 고정소수점 정수형 데이터
  % in_dat를 num비트짜리 2진수 문자열 또는 벡터로 바꿈.

  if (out_dat(num)==0) 
  % MSB(가장 상위 비트, 부호 비트)가 0이면 양수, 1이면 음수
   for i=1:num-1
    if (out_dat(num-i)==0) 
	n=n+1;
    else
	break
    end	
   end
   % MSB 쪽부터 0이 얼마나 연속되는지 센다
   % 즉, 정수의 절대값이 작을수록 더 많은 leading 0이 있으므로, 시프트 가능성이 크다.
  else
   for i=1:num-1
    if (out_dat(num-i)==1) 
	n=n+1;
    else
	break
    end
   end
  end
  % 음수는 2의 보수 표현이기 때문에 leading 1이 많으면 값이 작다. 
  % → 이 경우는 leading 1의 개수를 세서 시프트 여유를 본다.

  cnt=n;
  % 최종적으로 시프트할 수 있는 여유 비트 수(cnt)를 반환

end
