function compare_all_steps()
    step_list = {};
    for n = 0:2
        for m = 0:2
            step_list{end+1} = sprintf('step%d_%d', n, m); %#ok<AGROW>
        end
    end

    mean_errors = [];
    max_errors = [];
    step_labels = {};
    all_abs_errors = {};  % 각 step별 abs error 저장

    fprintf('%-10s | %-14s | %-14s | %-6s\n', ...
        'Step', 'Mean Abs Error', 'Max Abs Error', '@Index');
    fprintf('%s\n', repmat('-', 1, 56));

    for i = 1:length(step_list)
        step = step_list{i};
        float_file = sprintf('float_%s.txt', step);
        fixed_file = sprintf('fixed_%s.txt', step);

        try
            float_data = parse_complex_file(float_file);
            fixed_data = parse_complex_file(fixed_file);
        catch ME
            warning('파일 처리 오류 (%s): %s', step, ME.message);
            continue;
        end

        if length(float_data) ~= length(fixed_data)
            warning('%s: 데이터 길이 불일치 (float: %d, fixed: %d)', ...
                    step, length(float_data), length(fixed_data));
            continue;
        end

        abs_error = abs(float_data - fixed_data);
        mean_err = mean(abs_error);
        max_err = max(abs_error);
        max_idx = find(abs_error == max_err, 1);  % 첫 번째 최대값 인덱스

        mean_errors(end+1) = mean_err;
        max_errors(end+1) = max_err;
        step_labels{end+1} = step;
        all_abs_errors{end+1} = abs_error;
        signal_power = sum(abs(float_data).^2);
        noise_power  = sum(abs(float_data - fixed_data).^2);

        if noise_power == 0
            sqnr_db = Inf;  % 이상적으로 완벽하게 같을 경우
        else
            sqnr_db = 10 * log10(signal_power / noise_power);
        end

        fprintf('%-10s | %14.6f | %14.6f | %6d | %7.2f dB\n', ...
            step, mean_err, max_err, max_idx, sqnr_db);
    end

    %% === Plot 1: 평균/최대 오차 Bar Graph ===
    figure('Name', 'Mean/Max Absolute Error per Step');
    bar_data = [mean_errors(:), max_errors(:)];
    bar(bar_data);
    title('Mean / Max Absolute Error per Step');
    xlabel('Step');
    ylabel('Error');
    legend('Mean', 'Max');
    xticks(1:length(step_labels));
    xticklabels(step_labels);
    xtickangle(45);
    grid on;

    %% === Plot 2: 각 step별 오차 분포 ===
    figure('Name', 'Absolute Error Distribution per Step');
    n_steps = length(all_abs_errors);
    rows = ceil(sqrt(n_steps));
    cols = ceil(n_steps / rows);

    for i = 1:n_steps
        subplot(rows, cols, i);
        plot(all_abs_errors{i});
        title(step_labels{i});
        xlabel('Index');
        ylabel('|Float - Fixed|');
        grid on;
    end
end

function complex_vec = parse_complex_file(filename)
    fid = fopen(filename, 'r');
    if fid == -1
        error('파일 열기 실패: %s', filename);
    end

    % 포맷: idx=N, val=REAL+jIMAG
    data = textscan(fid, 'idx=%*d, val=%f+j%f');
    fclose(fid);

    if isempty(data{1}) || isempty(data{2})
        error('데이터 추출 실패: %s', filename);
    end

    complex_vec = complex(data{1}, data{2});
end
