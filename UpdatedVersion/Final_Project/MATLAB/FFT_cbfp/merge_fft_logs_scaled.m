function merge_fft_logs_scaled(float_file, fixed_file, output_file, n)
    scale = 2^n;

    % 파일 열기
    fp_float = fopen(float_file, 'r');
    fp_fixed = fopen(fixed_file, 'r');
    fp_out = fopen(output_file, 'w');

    % 헤더 작성
    fprintf(fp_out, 'jj\tkk\tFloat_Real\tFloat_Imag\tFixed_Real\tFixed_Imag\n');

    while true
        % 각 줄 읽기
        line_flt = fgetl(fp_float);
        line_fix = fgetl(fp_fixed);

        if ~ischar(line_flt) || ~ischar(line_fix)
            break;  % 파일 끝
        end

        % float.txt에서 jj, kk, float_real, float_imag 추출
        tokens_flt = regexp(line_flt, ...
            'jj=(\d+), kk=(\d+), dout\(\d+\)=([-\d\.Ee+]+)\+j([-\d\.Ee+]+)', 'tokens');
        tokens_flt = tokens_flt{1};
        jj = str2double(tokens_flt{1});
        kk = str2double(tokens_flt{2});
        flt_re = str2double(tokens_flt{3});
        flt_im = str2double(tokens_flt{4});

        % fixed.txt에서 fixed_real, fixed_imag 추출
        tokens_fix = regexp(line_fix, ...
            'jj=\d+, kk=\d+, dout\(\d+\)=([-\d\.Ee+]+)\+j([-\d\.Ee+]+)', 'tokens');
        tokens_fix = tokens_fix{1};
        fix_re = str2double(tokens_fix{1}) / scale;
        fix_im = str2double(tokens_fix{2}) / scale;

        % 출력
        fprintf(fp_out, '%d\t%d\t%.10f\t%.10f\t%.10f\t%.10f\n', ...
            jj, kk, flt_re, flt_im, fix_re, fix_im);
    end

    % 파일 닫기
    fclose(fp_float);
    fclose(fp_fixed);
    fclose(fp_out);
end