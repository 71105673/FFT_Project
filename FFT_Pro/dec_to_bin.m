% Added on 2024/01/29 by jihan 
% 10진수 정수를 2진수 비트 배열로 변환하는 함수입니다. 
function [out_dat] = dec_to_bin(in_dat, num) 

  if (in_dat>=0) 
   for i=1:num
	out_dat(i)=mod(in_dat,2);   % 2로 나눈 나머지
	in_dat=floor(in_dat/2);     % 2로 나눈 몫
   end
  else                          % 음수의 경우
	in_dat=(-in_dat)-1;         % 2의 보수 계산을 위한 전처리
   for i=1:num
	out_dat(i)=mod(in_dat,2);
	out_dat(i)=xor(out_dat(i),1);
	in_dat=floor(in_dat/2);
   end
  end

end
