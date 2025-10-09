% Added on 2024/01/29 by jihan 
function [min_val] = min_detect(index, cnt, temp) 

% index: 블록 내 데이터 번호 (1~64)

% cnt: 현재 데이터의 시프트 가능 수

% temp: 지금까지 본 데이터들 중 최소 시프트 수

  if (index==1)
	min_val=cnt;
    % 첫 데이터면 비교할 필요 없이 그냥 반환
  else
    if (temp>cnt) 
	min_val=cnt;
    else
	min_val=temp;	
    end
  end
  % 이후 데이터부터는 더 작은 시프트 수를 계속 유지해서 반환
  % 어떤 데이터라도 오버플로우 안 나려면, 
  % 가장 시프트가 덜 되는 값 기준으로 전체 블록을 시프트해야 하니까
end
