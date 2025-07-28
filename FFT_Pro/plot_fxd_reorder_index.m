% Function to parse complex numbers from a string (re-used from previous script)
function complex_val = parseComplex(str)
    % Remove 'j' and replace with 'i' for MATLAB complex number parsing
    str = strrep(str, 'j', 'i');
    complex_val = str2double(str);
end

% --- Plotting Script for fxd_reorder_index.txt ---

% File: fxd_reorder_index.txt
% This file contains dout and indexsum values.
% We will plot the indexsum against its sequential index.
try
    fid = fopen('fxd_reorder_index.txt', 'r');
    if fid == -1
        error('fxd_reorder_index.txt 파일을 열 수 없습니다.');
    end
    
    data_indexsum = []; % To store the indexsum values
    
    tline = fgetl(fid); % Read the first line
    while ischar(tline) % Loop until end of file
        % Use regular expression to extract the indexsum value
        % The pattern looks for 'indexsum=' followed by one or more digits
        tokens = regexp(tline, 'indexsum=(\d+)', 'tokens');
        
        if ~isempty(tokens)
            % Convert the extracted string to a number and add to array
            indexsum_val = str2double(tokens{1}{1});
            data_indexsum = [data_indexsum; indexsum_val];
        end
        tline = fgetl(fid); % Read the next line
    end
    fclose(fid); % Close the file

    % Create a new figure window
    figure; 
    
    % Plot the indexsum data
    % The x-axis will be the natural index of the data_indexsum array (1 to N)
    plot(data_indexsum);
    
    % Set the title and labels
    title('fxd_reorder_index.txt - Indexsum');
    xlabel('Index (N=512까지)'); % X-axis label as requested (up to N=512)
    ylabel('Index Sum'); % Y-axis label
    grid on; % Add a grid for better readability
    
    % Adjust x-axis limits if data is exactly 512 points
    % If the file contains exactly 512 entries, the x-axis will naturally go up to 512.
    % If there are more or less, you might want to adjust xlim.
    % Assuming N=512 is the expected length, we can set it explicitly.
    N_data = length(data_indexsum);
    if N_data > 0
        xlim([1 N_data]); % Set x-axis limits from 1 to the actual number of data points
    end
    
catch ME
    % Display any errors that occur during file processing or plotting
    disp(['Error processing fxd_reorder_index.txt: ' ME.message]);
end
