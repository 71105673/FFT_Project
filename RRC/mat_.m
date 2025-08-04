clc;

A = [1 2; 3 4];
B = [8 7; 6 5];

C = A + B;    % Matrix Addition
D = A - B;    % Matrix Subtraction
E = A * B;    % Matrix Multiplication
F = A ^ 2;    % Matrix Square
G = A';       % Matrix Transpose

E_1 = A .* B;  % Element Multiplication
E_2 = A ./ B;  % Element Division
F_1 = A .^ 2;  % Element Square

[rows, cols] = size(A);
tot_sum = sum(A(:));
row_sum = sum(A,2);
col_sum = sum(A,1);
tot_mean = mean(A(:));
row_mean = mean(A,2);
col_mean = mean(A,1);

