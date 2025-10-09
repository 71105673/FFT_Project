function [fft_out, module2_out] = save_table_single(bfly22, fft_mode, file_name)
% save_fft_reorder_result - FFT 또는 IFFT 결과를 비트 리버스 순서로 저장
% 입력:
%   bfly22     : FFT 연산 결과 (복소수 배열, 길이 512)
%   fft_mode   : 1이면 FFT, 0이면 IFFT
%   file_name  : 저장할 텍스트 파일 이름 (예: 'reorder_index_fixed.txt')
%
% 출력:
%   fft_out      : FFT 또는 IFFT 결과 (reordered)
%   module2_out  : 원래 bfly22 혹은 conj(bfly22)/512 결과

    if nargin < 2
        fft_mode = 1;  % 기본값은 FFT
    end
    if nargin < 3
        file_name = 'reorder_index_fixed.txt';  % 기본 저장 파일 이름
    end

    N = length(bfly22);
    dout = complex(zeros(1, N));  % 결과 배열 초기화

    fp = fopen(file_name, 'w');

    for jj = 1:N
        % 비트 반전 인덱스 계산 (9비트 기준, 0-based index)
        kk = bitget(jj-1,9)*1 + bitget(jj-1,8)*2 + bitget(jj-1,7)*4 + ...
             bitget(jj-1,6)*8 + bitget(jj-1,5)*16 + bitget(jj-1,4)*32 + ...
             bitget(jj-1,3)*64 + bitget(jj-1,2)*128 + bitget(jj-1,1)*256;
        dout(kk+1) = bfly22(jj);  % reorder 적용
        fprintf(fp, 'jj=%d, kk=%d, dout(%d)=%.10f+j%.10f\n', ...
                jj, kk, kk+1, real(dout(kk+1)), imag(dout(kk+1)));
    end

    fclose(fp);

    % FFT or IFFT 처리
    if fft_mode == 1
        fft_out = dout;
        module2_out = bfly22;
    else
        fft_out = conj(dout) / N;
        module2_out = conj(bfly22) / N;
    end
end
