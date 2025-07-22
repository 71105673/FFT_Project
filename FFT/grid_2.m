% FFT fixed/float 폴더 경로 설정
fixed_folder = 'FFT_fixed_3';
float_folder = 'FFT_float';

% *_fixed.txt 파일 목록 가져오기
fixed_files = dir(fullfile(fixed_folder, '*_fixed.txt'));

% 그래프 저장 폴더
output_folder = 'FFT_plots';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% 각 fixed 파일에 대해 반복
for k = 1:length(fixed_files)
    fixed_filename = fixed_files(k).name;
    
    % '_fixed.txt' → '_float.txt'로 파일명 변경
    float_filename = strrep(fixed_filename, '_fixed.txt', '_float.txt');
    
    % 파일 경로 생성
    fixed_path = fullfile(fixed_folder, fixed_filename);
    float_path = fullfile(float_folder, float_filename);
    
    % float 파일 존재 여부 확인
    if ~isfile(float_path)
        fprintf('[경고] %s에 대응하는 float 파일 없음. 건너뜀.\n', fixed_filename);
        continue;
    end

    % 데이터 읽기
    fixed_data = read_complex_from_file(fixed_path);
    float_data = read_complex_from_file(float_path);

    % Magnitude 계산
    mag_fixed = abs(fixed_data);
    mag_float = abs(float_data);

    % Frequency 축
    N = length(mag_fixed);
    freq = 0:N-1;

    % 그래프 그리기
    figure('Visible','off');
    plot(freq, mag_float, 'b-', 'LineWidth', 1.5); hold on;
    plot(freq, mag_fixed, 'r--', 'LineWidth', 1.5);
    title(sprintf('FFT Comparison: %s', strrep(fixed_filename, '_fixed.txt', '')));
    xlabel('Frequency Index');
    ylabel('Magnitude');
    legend('Float', 'Fixed');
    grid on;

    % 저장
    save_path = fullfile(output_folder, [strrep(fixed_filename, '.txt', '') '.png']);
    saveas(gcf, save_path);
    close;
end

disp('✅ 그래프 생성 완료!');

% ----------------------------
% 복소수 추출 함수 정의
% ----------------------------
function data = read_complex_from_file(filepath)
    fid = fopen(filepath, 'r');
    lines = textscan(fid, '%s', 'Delimiter', '\n');
    lines = lines{1};
    fclose(fid);

    N = length(lines);
    data = zeros(N,1);

    for i = 1:N
        line = lines{i};
        % 예: 'bfly00(1)=0.1234+j0.5678'
        tokens = regexp(line, '=([-+]?[0-9.eE+-]+)\+j([-+]?[0-9.eE+-]+)', 'tokens');
        if ~isempty(tokens)
            real_part = str2double(tokens{1}{1});
            imag_part = str2double(tokens{1}{2});
            data(i) = complex(real_part, imag_part);
        end
    end
end


% -------------------------------------------
% 모든 fixed/float 쌍을 subplot으로 비교 표시
% -------------------------------------------

num_files = length(fixed_files);
cols = ceil(sqrt(num_files));
rows = ceil(num_files / cols);

figure('Name', 'All FFT Comparison (Float vs Fixed)', 'Position', [100, 100, 1400, 800]);

for i = 1:num_files
    fixed_filename = fixed_files(i).name;
    float_filename = strrep(fixed_filename, '_fixed.txt', '_float.txt');

    fixed_path = fullfile(fixed_folder, fixed_filename);
    float_path = fullfile(float_folder, float_filename);

    if ~isfile(float_path)
        fprintf('[경고] %s에 대응하는 float 파일 없음. subplot 생략.\n', fixed_filename);
        continue;
    end

    % 데이터 읽기
    fixed_data = read_complex_from_file(fixed_path);
    float_data = read_complex_from_file(float_path);

    mag_fixed = abs(fixed_data);
    mag_float = abs(float_data);
    N = length(mag_fixed);
    freq = 0:N-1;

    % subplot
    subplot(rows, cols, i);
    plot(freq, mag_float, 'b-', 'LineWidth', 1.2); hold on;
    plot(freq, mag_fixed, 'r--', 'LineWidth', 1.2);
    title(strrep(fixed_filename, '_fixed.txt', ''), 'Interpreter', 'none');
    xlabel('Freq Idx'); ylabel('Mag');
    legend('Float', 'Fixed');
    grid on;
end

sgtitle('FFT Float vs Fixed Comparison (All Files)');

% 저장할 수도 있음
saveas(gcf, fullfile(output_folder, 'All_Comparison_Subplots.png'));
