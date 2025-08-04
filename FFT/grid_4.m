% MATLAB 스크립트: FFT Fixed/Float 데이터 성능 비교 및 시각화
% 이 스크립트는 FFT 결과 파일들을 비교하여 정밀도 오차를 분석하고 시각화합니다.

function compare_fft_performance()

    % === 1. 폴더 경로 설정 ===
    % 실제 Fixed 및 Float 폴더 경로로 변경해주세요.
    fixed_folder = 'FFT_fixed_3'; 
    float_folder = 'FFT_float';   

    % 그래프 저장 폴더 생성 (없으면 생성)
    output_folder = 'FFT_plots';
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end

    fprintf('------------------------------------------------------------\n');
    fprintf('FFT Fixed vs Float 성능 비교 시작\n');
    fprintf('Float 폴더: %s\n', float_folder);
    fprintf('Fixed 폴더: %s\n', fixed_folder);
    fprintf('그래프 저장 폴더: %s\n', output_folder);
    fprintf('------------------------------------------------------------\n\n');

    % 모든 float 파일 정보 가져오기 ('.txt' 확장자만)
    try
        float_files_info = dir(fullfile(float_folder, '*.txt'));
        float_filenames = {float_files_info.name};
    catch ME
        fprintf('오류: Float 폴더를 찾을 수 없거나 파일 목록을 읽을 수 없습니다. 경로를 확인해주세요.\n');
        disp(ME.message);
        return; 
    end

    % 결과를 저장할 변수 초기화
    all_mean_errors = [];
    all_max_errors = [];
    all_max_indices = [];
    all_sqnr_values = [];
    all_file_labels = {}; % 플롯 및 표에 사용할 파일명 레이블 (예: 'bfly00')

    % 각 step별 절대 오차 데이터를 저장할 셀 배열
    all_abs_errors_data = {}; 

    % === 2. 오차 분석 테이블 헤더 출력 ===
    fprintf('%-25s | %-14s | %-14s | %-6s | %-7s\n', ...
        '파일', '평균 절대 오차', '최대 절대 오차', '인덱스', 'SQNR (dB)');
    fprintf('%s\n', repmat('-', 1, 75));

    % === 3. 각 파일 쌍에 대해 반복하며 오차 계산 및 개별 그래프 생성 ===
    processed_count = 0; % 실제로 처리된 파일 쌍의 수

    for k = 1:length(float_filenames)
        float_filename = float_filenames{k};
        
        % 대응하는 fixed 파일명 찾기 (예: bfly00_float.txt -> bfly00_fixed.txt)
        fixed_filename = getCorrespondingFixedFilename(float_filename);
        
        if isempty(fixed_filename)
            fprintf('[정보] %s: 대응하는 fixed 파일 패턴을 찾을 수 없습니다. (예: _float.txt -> _fixed.txt 변환 불가). 건너뜁니다.\n', float_filename);
            continue;
        end

        % 파일의 전체 경로 생성
        float_path = fullfile(float_folder, float_filename);
        fixed_path = fullfile(fixed_folder, fixed_filename);
        
        % 파일 존재 여부 확인
        if ~isfile(float_path)
            fprintf('[경고] %s: float 파일이 존재하지 않습니다. 건너뜁니다.\n', float_path);
            continue;
        end
        if ~isfile(fixed_path)
            fprintf('[경고] %s: 대응하는 fixed 파일이 존재하지 않습니다. 건너뜁니다.\n', fixed_path);
            continue;
        end

        try
            % 데이터 읽기 (제공된 read_complex_from_file 함수 사용)
            float_data = read_complex_from_file(float_path);
            fixed_data = read_complex_from_file(fixed_path);
        catch ME
            fprintf('[오류] %s 또는 %s 파일 읽기 중 오류 발생: %s. 건너뜁니다.\n', float_filename, fixed_filename, ME.message);
            continue;
        end
        
        % 데이터 길이 일치 여부 확인
        if length(float_data) ~= length(fixed_data)
            fprintf('[경고] %s vs %s: 데이터 길이 불일치 (float: %d, fixed: %d). 오차 계산을 건너뜁니다.\n', ...
                    float_filename, fixed_filename, length(float_data), length(fixed_data));
            continue;
        end

        processed_count = processed_count + 1;

        % === 오차 계산 ===
        abs_error = abs(float_data - fixed_data);
        mean_err = mean(abs_error);
        max_err = max(abs_error);
        max_idx = find(abs_error == max_err, 1) - 1; % 0부터 시작하는 인덱스 (FFT 주파수 인덱스처럼)

        % SQNR (Signal-to-Quantization Noise Ratio) 계산
        signal_power = sum(abs(float_data).^2);
        noise_power  = sum(abs(float_data - fixed_data).^2);
        
        if noise_power == 0
            sqnr_db = Inf; % 완벽하게 같을 경우 SQNR은 무한대
        else
            sqnr_db = 10 * log10(signal_power / noise_power);
        end

        % 결과 저장 (나중에 전체 플롯을 위해)
        all_mean_errors(end+1) = mean_err; %#ok<AGROW>
        all_max_errors(end+1) = max_err;   %#ok<AGROW>
        all_max_indices(end+1) = max_idx;  %#ok<AGROW>
        all_sqnr_values(end+1) = sqnr_db;  %#ok<AGROW>
        % 파일명에서 '_float.txt' 제거하여 라벨로 사용
        file_base_label = strrep(strrep(float_filename, '_float.txt', ''), '.txt', ''); 
        all_file_labels{end+1} = file_base_label; %#ok<AGROW>
        all_abs_errors_data{end+1} = abs_error; %#ok<AGROW>

        % 테이블에 현재 파일 쌍의 결과 출력
        fprintf('%-25s | %14.6f | %14.6f | %6d | %7.2f\n', ...
            file_base_label, mean_err, max_err, max_idx, sqnr_db);

        % === 개별 파일 Magnitude 비교 그래프 생성 및 저장 ===
        figure('Visible','off', 'Position', [100, 100, 800, 600]); % 화면에 보이지 않게, 크기 설정
        
        mag_fixed = abs(fixed_data);
        mag_float = abs(float_data);
        N = length(mag_fixed);
        freq = 0:N-1; % 주파수 축 (0부터 N-1까지)

        plot(freq, mag_float, 'b-', 'LineWidth', 1.5); hold on;
        plot(freq, mag_fixed, 'r--', 'LineWidth', 1.5);
        
        title(sprintf('FFT Magnitude Comparison: %s', file_base_label), 'Interpreter', 'none');
        xlabel('Frequency Index');
        ylabel('Magnitude');
        legend('Float', 'Fixed', 'Location', 'best');
        grid on;
        hold off;
        
        % 그래프 저장
        save_path = fullfile(output_folder, [file_base_label '_Magnitude_Comparison.png']);
        saveas(gcf, save_path);
        close(gcf); % 현재 Figure 닫기
    end
    fprintf('%s\n', repmat('-', 1, 75));
    fprintf('✅ 개별 파일 Magnitude 비교 그래프 %d개 생성 완료!\n', processed_count);


    % === 4. 전체 평균/최대 오차 Bar Graph ===
    if processed_count > 0
        figure('Name', 'Mean/Max Absolute Error per File', 'Position', [100, 100, 1200, 700]);
        bar_data = [all_mean_errors(:), all_max_errors(:)];
        bar(bar_data);
        
        title('각 파일별 평균 / 최대 절대 오차');
        xlabel('파일');
        ylabel('오차 값');
        legend('평균 절대 오차', '최대 절대 오차', 'Location', 'best');
        
        xticks(1:length(all_file_labels));
        xticklabels(all_file_labels);
        xtickangle(45); % x축 라벨 각도 조절
        grid on;
        
        saveas(gcf, fullfile(output_folder, 'All_Mean_Max_Error_BarGraph.png'));
        close(gcf);
        fprintf('✅ 평균/최대 오차 Bar Graph 생성 완료!\n');
    else
        fprintf('생성할 데이터가 없어 평균/최대 오차 Bar Graph는 생성되지 않습니다.\n');
    end

    % === 5. 각 파일별 오차 분포 서브플롯 ===
    if processed_count > 0
        num_plots = processed_count;
        cols = ceil(sqrt(num_plots));
        rows = ceil(num_plots / cols);

        figure('Name', 'Absolute Error Distribution per File', 'Position', [100, 100, 1600, 900]);
        for i = 1:num_plots
            subplot(rows, cols, i);
            plot(all_abs_errors_data{i}, 'Color', [0.85 0.33 0.1]); % 주황색 계열
            title(all_file_labels{i}, 'Interpreter', 'none');
            xlabel('인덱스');
            ylabel('|Float - Fixed|');
            grid on;
            box on; % 박스 테두리 추가
        end
        sgtitle('FFT Float vs Fixed 절대 오차 분포 (모든 파일)');
        
        saveas(gcf, fullfile(output_folder, 'All_Absolute_Error_Distribution_Subplots.png'));
        close(gcf);
        fprintf('✅ 절대 오차 분포 서브플롯 생성 완료!\n');
    else
        fprintf('생성할 데이터가 없어 절대 오차 분포 서브플롯은 생성되지 않습니다.\n');
    end

    fprintf('\n모든 FFT 비교 및 분석 작업 완료.\n');

end

%% === 헬퍼 함수 정의 ===
% 이 함수들은 위에 있는 주 스크립트에서 호출됩니다.

function fixed_filename = getCorrespondingFixedFilename(float_filename)
    % _float 파일을 _fixed 파일명으로 변환합니다.
    % 예: 'bfly00_float.txt' -> 'bfly00_fixed.txt'
    %     'float_reorder_index.txt' -> 'fixed_reorder_index.txt'
    if contains(float_filename, '_float.txt')
        fixed_filename = strrep(float_filename, '_float.txt', '_fixed.txt');
    elseif strcmp(float_filename, 'float_reorder_index.txt')
        fixed_filename = 'fixed_reorder_index.txt';
    elseif contains(float_filename, '_tmp_float.txt') % _tmp_float.txt 처리 추가
        fixed_filename = strrep(float_filename, '_tmp_float.txt', '_tmp_fixed.txt');
    else
        fixed_filename = ''; % 대응되는 패턴이 없는 경우 빈 문자열 반환
    end
end

function data = read_complex_from_file(filepath)
    % 파일에서 복소수 데이터를 읽는 함수 (예: 'bfly00(1)=0.1234+j0.5678' 형식)
    fid = fopen(filepath, 'r');
    if fid == -1
        error('파일 열기 실패: %s', filepath);
    end
    
    % 모든 줄을 문자열로 읽어옴
    lines = textscan(fid, '%s', 'Delimiter', '\n', 'EndOfLine', '\n');
    lines = lines{1}; % 셀 배열로 변환
    fclose(fid);
    
    N = length(lines);
    data = zeros(N,1); % 복소수 데이터를 저장할 벡터 초기화
    
    % 각 줄을 파싱하여 복소수 추출
    for i = 1:N
        line = lines{i};
        % 정규 표현식을 사용하여 실수부와 허수부를 추출
        % 패턴: '= 실수부 +j 허수부' 또는 '= 실수부 -j 허수부'
        tokens = regexp(line, '=([-+]?[0-9.eE+-]+)\s*([+-])j([-+]?[0-9.eE+-]+)', 'tokens', 'once');
        
        if ~isempty(tokens)
            real_part = str2double(tokens{1});
            sign_char = tokens{2};
            imag_part = str2double(tokens{3});
            
            % 허수부 부호 처리
            if strcmp(sign_char, '-')
                imag_part = -imag_part;
            end
            data(i) = complex(real_part, imag_part);
        else
            % 매칭되는 데이터가 없는 경우 경고 (선택 사항)
            % warning('"%s" 파일의 줄 %d ("%s"): 유효한 복소수 패턴을 찾을 수 없습니다. 0+0j로 처리됩니다.', basename(filepath), i, line);
            data(i) = complex(0, 0); 
        end
    end
end

function name = basename(filepath)
    % 파일 경로에서 파일명만 추출하는 헬퍼 함수
    [~, name, ext] = fileparts(filepath);
    name = [name ext];
end

function result = iif(condition, true_val, false_val)
    % MATLAB의 인라인 if-else (삼항 연산자)를 모방하는 헬퍼 함수
    if condition
        result = true_val;
    else
        result = false_val;
    end
end