% Function to parse complex numbers from a string
function complex_val = parseComplex(str)
    % Remove 'j' and replace with 'i' for MATLAB complex number parsing
    str = strrep(str, 'j', 'i');
    complex_val = str2double(str);
end

% --- Plotting Script ---

% File 1: bfly01.txt
% This file contains bfly01_tmp, temp_bfly01, and bfly01 values.
% We will plot the real and imaginary parts of bfly01.
try
    fid = fopen('bfly01.txt', 'r');
    if fid == -1
        error('bfly01.txt 파일을 열 수 없습니다.');
    end
    data_bfly01_tmp = [];
    data_temp_bfly01 = [];
    data_bfly01 = [];
    
    tline = fgetl(fid);
    while ischar(tline)
        % Extract values using regular expressions
        tokens = regexp(tline, 'bfly01_tmp\((\d+)\)=([-+\d.]+j[-+\d.]+), temp_bfly01\((\d+)\)=([-+\d.]+j[-+\d.]+), bfly01\((\d+)\)=([-+\d.]+j[-+\d.]+)', 'tokens');
        if ~isempty(tokens)
            % Parse complex numbers
            bfly01_tmp_val = parseComplex(tokens{1}{2});
            temp_bfly01_val = parseComplex(tokens{1}{4});
            bfly01_val = parseComplex(tokens{1}{6});
            
            data_bfly01_tmp = [data_bfly01_tmp; bfly01_tmp_val];
            data_temp_bfly01 = [data_temp_bfly01; temp_bfly01_val];
            data_bfly01 = [data_bfly01; bfly01_val];
        end
        tline = fgetl(fid);
    end
    fclose(fid);

    figure(1);
    subplot(2,1,1);
    plot(real(data_bfly01));
    title('bfly01.txt - bfly01 Real Part');
    xlabel('Index');
    ylabel('Real Value');
    grid on;

    subplot(2,1,2);
    plot(imag(data_bfly01));
    title('bfly01.txt - bfly01 Imaginary Part');
    xlabel('Index');
    ylabel('Imaginary Value');
    grid on;
    sgtitle('bfly01.txt Data Analysis'); % Super title for the figure
    
catch ME
    disp(['Error processing bfly01.txt: ' ME.message]);
end


% File 2: bfly11.txt
% This file contains bfly11_tmp, temp_bfly11, and bfly11 values.
% We will plot the real and imaginary parts of bfly11.
try
    fid = fopen('bfly11.txt', 'r');
    if fid == -1
        error('bfly11.txt 파일을 열 수 없습니다.');
    end
    data_bfly11_tmp = [];
    data_temp_bfly11 = [];
    data_bfly11 = [];
    
    tline = fgetl(fid);
    while ischar(tline)
        tokens = regexp(tline, 'bfly11_tmp\((\d+)\)=([-+\d.]+j[-+\d.]+), temp_bfly11\((\d+)\)=([-+\d.]+j[-+\d.]+), bfly11\((\d+)\)=([-+\d.]+j[-+\d.]+)', 'tokens');
        if ~isempty(tokens)
            bfly11_tmp_val = parseComplex(tokens{1}{2});
            temp_bfly11_val = parseComplex(tokens{1}{4});
            bfly11_val = parseComplex(tokens{1}{6});
            
            data_bfly11_tmp = [data_bfly11_tmp; bfly11_tmp_val];
            data_temp_bfly11 = [data_temp_bfly11; temp_bfly11_val];
            data_bfly11 = [data_bfly11; bfly11_val];
        end
        tline = fgetl(fid);
    end
    fclose(fid);

    figure(2);
    subplot(2,1,1);
    plot(real(data_bfly11));
    title('bfly11.txt - bfly11 Real Part');
    xlabel('Index');
    ylabel('Real Value');
    grid on;

    subplot(2,1,2);
    plot(imag(data_bfly11));
    title('bfly11.txt - bfly11 Imaginary Part');
    xlabel('Index');
    ylabel('Imaginary Value');
    grid on;
    sgtitle('bfly11.txt Data Analysis');
    
catch ME
    disp(['Error processing bfly11.txt: ' ME.message]);
end

% File 3: bfly21.txt
% This file contains bfly21_tmp, temp_bfly21, and bfly21 values.
% We will plot the real and imaginary parts of bfly21.
try
    fid = fopen('bfly21.txt', 'r');
    if fid == -1
        error('bfly21.txt 파일을 열 수 없습니다.');
    end
    data_bfly21_tmp = [];
    data_temp_bfly21 = [];
    data_bfly21 = [];
    
    tline = fgetl(fid);
    while ischar(tline)
        tokens = regexp(tline, 'bfly21_tmp\((\d+)\)=([-+\d.]+j[-+\d.]+), temp_bfly21\((\d+)\)=([-+\d.]+j[-+\d.]+), bfly21\((\d+)\)=([-+\d.]+j[-+\d.]+)', 'tokens');
        if ~isempty(tokens)
            bfly21_tmp_val = parseComplex(tokens{1}{2});
            temp_bfly21_val = parseComplex(tokens{1}{4});
            bfly21_val = parseComplex(tokens{1}{6});
            
            data_bfly21_tmp = [data_bfly21_tmp; bfly21_tmp_val];
            data_temp_bfly21 = [data_temp_bfly21; temp_bfly21_val];
            data_bfly21 = [data_bfly21; bfly21_val];
        end
        tline = fgetl(fid);
    end
    fclose(fid);

    figure(3);
    subplot(2,1,1);
    plot(real(data_bfly21));
    title('bfly21.txt - bfly21 Real Part');
    xlabel('Index');
    ylabel('Real Value');
    grid on;

    subplot(2,1,2);
    plot(imag(data_bfly21));
    title('bfly21.txt - bfly21 Imaginary Part');
    xlabel('Index');
    ylabel('Imaginary Value');
    grid on;
    sgtitle('bfly21.txt Data Analysis');
    
catch ME
    disp(['Error processing bfly21.txt: ' ME.message]);
end

% File 4: cbfp_0.txt
% This file contains twf_m0, pre_bfly02, index1_re, index1_im, and bfly02 values.
% We will plot the real and imaginary parts of bfly02.
try
    fid = fopen('cbfp_0.txt', 'r');
    if fid == -1
        error('cbfp_0.txt 파일을 열 수 없습니다.');
    end
    data_twf_m0 = [];
    data_pre_bfly02 = [];
    data_index1_re = [];
    data_index1_im = [];
    data_bfly02 = [];
    
    tline = fgetl(fid);
    while ischar(tline)
        tokens = regexp(tline, 'twf_m0\((\d+)\)=([-+\d.]+j[-+\d.]+), pre_bfly02\((\d+)\)=([-+\d.]+j[-+\d.]+), index1_re\((\d+)\)=(\d+), index1_im\((\d+)\)=(\d+), bfly02\((\d+)\)=([-+\d.]+j[-+\d.]+)', 'tokens');
        if ~isempty(tokens)
            twf_m0_val = parseComplex(tokens{1}{2});
            pre_bfly02_val = parseComplex(tokens{1}{4});
            index1_re_val = str2double(tokens{1}{6});
            index1_im_val = str2double(tokens{1}{8});
            bfly02_val = parseComplex(tokens{1}{10});
            
            data_twf_m0 = [data_twf_m0; twf_m0_val];
            data_pre_bfly02 = [data_pre_bfly02; pre_bfly02_val];
            data_index1_re = [data_index1_re; index1_re_val];
            data_index1_im = [data_index1_im; index1_im_val];
            data_bfly02 = [data_bfly02; bfly02_val];
        end
        tline = fgetl(fid);
    end
    fclose(fid);

    figure(4);
    subplot(2,1,1);
    plot(real(data_bfly02));
    title('cbfp_0.txt - bfly02 Real Part');
    xlabel('Index');
    ylabel('Real Value');
    grid on;

    subplot(2,1,2);
    plot(imag(data_bfly02));
    title('cbfp_0.txt - bfly02 Imaginary Part');
    xlabel('Index');
    ylabel('Imaginary Value');
    grid on;
    sgtitle('cbfp_0.txt Data Analysis');
    
catch ME
    disp(['Error processing cbfp_0.txt: ' ME.message]);
end

% File 5: cbfp_1.txt
% This file contains pre_bfly12, index2_re, index2_im, and bfly12 values.
% We will plot the real and imaginary parts of bfly12.
try
    fid = fopen('cbfp_1.txt', 'r');
    if fid == -1
        error('cbfp_1.txt 파일을 열 수 없습니다.');
    end
    data_pre_bfly12 = [];
    data_index2_re = [];
    data_index2_im = [];
    data_bfly12 = [];
    
    tline = fgetl(fid);
    while ischar(tline)
        tokens = regexp(tline, 'pre_bfly12\((\d+)\)=([-+\d.]+j[-+\d.]+), index2_re\((\d+)\)=(\d+), index2_im\((\d+)\)=(\d+), bfly12\((\d+)\)=([-+\d.]+j[-+\d.]+)', 'tokens');
        if ~isempty(tokens)
            pre_bfly12_val = parseComplex(tokens{1}{2});
            index2_re_val = str2double(tokens{1}{4});
            index2_im_val = str2double(tokens{1}{6});
            bfly12_val = parseComplex(tokens{1}{8});
            
            data_pre_bfly12 = [data_pre_bfly12; pre_bfly12_val];
            data_index2_re = [data_index2_re; index2_re_val];
            data_index2_im = [data_index2_im; index2_im_val];
            data_bfly12 = [data_bfly12; bfly12_val];
        end
        tline = fgetl(fid);
    end
    fclose(fid);

    figure(5);
    subplot(2,1,1);
    plot(real(data_bfly12));
    title('cbfp_1.txt - bfly12 Real Part');
    xlabel('Index');
    ylabel('Real Value');
    grid on;

    subplot(2,1,2);
    plot(imag(data_bfly12));
    title('cbfp_1.txt - bfly12 Imaginary Part');
    xlabel('Index');
    ylabel('Imaginary Value');
    grid on;
    sgtitle('cbfp_1.txt Data Analysis');
    
catch ME
    disp(['Error processing cbfp_1.txt: ' ME.message]);
end

% File 6: fxd_reorder_index.txt
% This file contains dout and indexsum values.
% We will plot the real and imaginary parts of dout and the indexsum.
try
    fid = fopen('fxd_reorder_index.txt', 'r');
    if fid == -1
        error('fxd_reorder_index.txt 파일을 열 수 없습니다.');
    end
    data_dout = [];
    data_indexsum = [];
    
    tline = fgetl(fid);
    while ischar(tline)
        tokens = regexp(tline, 'dout\((\d+)\)=([-+\d.]+j[-+\d.]+), indexsum=(\d+)', 'tokens');
        if ~isempty(tokens)
            dout_val = parseComplex(tokens{1}{2});
            indexsum_val = str2double(tokens{1}{3});
            
            data_dout = [data_dout; dout_val];
            data_indexsum = [data_indexsum; indexsum_val];
        end
        tline = fgetl(fid);
    end
    fclose(fid);

    figure(6);
    subplot(3,1,1);
    plot(real(data_dout));
    title('fxd_reorder_index.txt - dout Real Part');
    xlabel('Index');
    ylabel('Real Value');
    grid on;

    subplot(3,1,2);
    plot(imag(data_dout));
    title('fxd_reorder_index.txt - dout Imaginary Part');
    xlabel('Index');
    ylabel('Imaginary Value');
    grid on;
    
    subplot(3,1,3);
    plot(data_indexsum);
    title('fxd_reorder_index.txt - indexsum');
    xlabel('Index');
    ylabel('Index Sum');
    grid on;
    sgtitle('fxd_reorder_index.txt Data Analysis');
    
catch ME
    disp(['Error processing fxd_reorder_index.txt: ' ME.message]);
end
