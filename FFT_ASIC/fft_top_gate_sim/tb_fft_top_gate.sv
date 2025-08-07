`timescale 1ns/10ps

module tb_fft_top;

    parameter WIDTH = 9;
    parameter WIDTH_DO = 13;

    logic clk, rstn;
    logic fft_mode;
    logic di_en;
    logic signed [143:0] di_re;
    logic signed [143:0] di_im;

    logic signed [207:0] do_re;
    logic signed [207:0] do_im;

    integer fp;

    // // DUT
    // sdf1 #(
    //     .N(512),
    //     .M(512),
    //     .WIDTH(WIDTH),
    //     .WIDTH_DO(WIDTH_DO)
    // ) dut (
    //     .clk(clk),
    //     .rstn(rstn),
    //     .fft_mode(fft_mode),
    //     .di_en(di_en),
    //     .di_re(di_re),
    //     .di_im(di_im),

    //     .do_index(do_index),
    //     .do_en(do_en),
    //     .do_re(do_re),
    //     .do_im(do_im)
    // );

    fft_top #(
        .WIDTH(9)
    ) dut (
        .clk(clk),
        .rstn(rstn),
        .fft_mode(fft_mode),

        .din_i(di_re),
        .din_q(di_im),
        .din_valid(di_en),

        .do_re(do_re),
        .do_im(do_im),
        .do_en(do_en)
    );

    // Clock
    initial clk = 0;
    always #5 clk = ~clk;

    // Stimulus
    initial begin
        #0;
        rstn = 0;
        di_en = 0;
        fft_mode = 1;
        #20;
        rstn = 1;
        #10;
        @(posedge clk);
        di_en = 1;
        di_re[8:0]     = 63;
        di_re[17:9]    = 64;
        di_re[26:18]   = 64;
        di_re[35:27]   = 64;
        di_re[44:36]   = 64;
        di_re[53:45]   = 64;
        di_re[62:54]   = 64;
        di_re[71:63]   = 64;
        di_re[80:72]   = 64;
        di_re[89:81]   = 64;
        di_re[98:90]   = 64;
        di_re[107:99]  = 63;
        di_re[116:108] = 63;
        di_re[125:117] = 63;
        di_re[134:126] = 63;
        di_re[143:135] = 63;
        di_im = '0;

        @(posedge clk);
        di_en = 1;
        di_re[8:0]     = 63;
        di_re[17:9]    = 63;
        di_re[26:18]   = 62;
        di_re[35:27]   = 62;
        di_re[44:36]   = 62;
        di_re[53:45]   = 62;
        di_re[62:54]   = 62;
        di_re[71:63]   = 61;
        di_re[80:72]   = 61;
        di_re[89:81]   = 61;
        di_re[98:90]   = 61;
        di_re[107:99]  = 61;
        di_re[116:108] = 60;
        di_re[125:117] = 60;
        di_re[134:126] = 60;
        di_re[143:135] = 59;
        di_im = '0;

        @(posedge clk);
        di_en = 1;
        di_re[8:0]     = 59;
        di_re[17:9]    = 59;
        di_re[26:18]   = 59;
        di_re[35:27]   = 58;
        di_re[44:36]   = 58;
        di_re[53:45]   = 58;
        di_re[62:54]   = 57;
        di_re[71:63]   = 57;
        di_re[80:72]   = 56;
        di_re[89:81]   = 56;
        di_re[98:90]   = 56;
        di_re[107:99]  = 55;
        di_re[116:108] = 55;
        di_re[125:117] = 54;
        di_re[134:126] = 54;
        di_re[143:135] = 54;
        di_im = '0;

        @(posedge clk);
        di_en = 1;
        di_re[8:0]     = 53;
        di_re[17:9]    = 53;
        di_re[26:18]   = 52;
        di_re[35:27]   = 52;
        di_re[44:36]   = 51;
        di_re[53:45]   = 51;
        di_re[62:54]   = 50;
        di_re[71:63]   = 50;
        di_re[80:72]   = 49;
        di_re[89:81]   = 49;
        di_re[98:90]   = 48;
        di_re[107:99]  = 48;
        di_re[116:108] = 47;
        di_re[125:117] = 47;
        di_re[134:126] = 46;
        di_re[143:135] = 46;
        di_im = '0;

        @(posedge clk);
        di_en = 1;
        di_re[8:0]     = 45;
        di_re[17:9]    = 45;
        di_re[26:18]   = 44;
        di_re[35:27]   = 44;
        di_re[44:36]   = 43;
        di_re[53:45]   = 42;
        di_re[62:54]   = 42;
        di_re[71:63]   = 41;
        di_re[80:72]   = 41;
        di_re[89:81]   = 40;
        di_re[98:90]   = 39;
        di_re[107:99]  = 39;
        di_re[116:108] = 38;
        di_re[125:117] = 37;
        di_re[134:126] = 37;
        di_re[143:135] = 36;
        di_im = '0;

        @(posedge clk);
        di_en = 1;
        di_re[8:0]     = 36;
        di_re[17:9]    = 35;
        di_re[26:18]   = 34;
        di_re[35:27]   = 34;
        di_re[44:36]   = 33;
        di_re[53:45]   = 32;
        di_re[62:54]   = 32;
        di_re[71:63]   = 31;
        di_re[80:72]   = 30;
        di_re[89:81]   = 29;
        di_re[98:90]   = 29;
        di_re[107:99]  = 28;
        di_re[116:108] = 27;
        di_re[125:117] = 27;
        di_re[134:126] = 26;
        di_re[143:135] = 25;
        di_im = '0;

        @(posedge clk);
        di_en = 1;
        di_re[8:0]     = 24;
        di_re[17:9]    = 24;
        di_re[26:18]   = 23;
        di_re[35:27]   = 22;
        di_re[44:36]   = 22;
        di_re[53:45]   = 21;
        di_re[62:54]   = 20;
        di_re[71:63]   = 19;
        di_re[80:72]   = 19;
        di_re[89:81]   = 18;
        di_re[98:90]   = 17;
        di_re[107:99]  = 16;
        di_re[116:108] = 16;
        di_re[125:117] = 15;
        di_re[134:126] = 14;
        di_re[143:135] = 13;
        di_im = '0;

        @(posedge clk);
        di_en = 1;
        di_re[8:0]     = 12;
        di_re[17:9]    = 12;
        di_re[26:18]   = 11;
        di_re[35:27]   = 10;
        di_re[44:36]   = 9;
        di_re[53:45]   = 9;
        di_re[62:54]   = 8;
        di_re[71:63]   = 7;
        di_re[80:72]   = 6;
        di_re[89:81]   = 5;
        di_re[98:90]   = 5;
        di_re[107:99]  = 4;
        di_re[116:108] = 3;
        di_re[125:117] = 2;
        di_re[134:126] = 2;
        di_re[143:135] = 1;
        di_im = '0;

        @(posedge clk);
        di_en = 1;
        di_re[8:0]     = 0;
        di_re[17:9]    = -1;
        di_re[26:18]   = -2;
        di_re[35:27]   = -2;
        di_re[44:36]   = -3;
        di_re[53:45]   = -4;
        di_re[62:54]   = -5;
        di_re[71:63]   = -5;
        di_re[80:72]   = -6;
        di_re[89:81]   = -7;
        di_re[98:90]   = -8;
        di_re[107:99]  = -9;
        di_re[116:108] = -9;
        di_re[125:117] = -10;
        di_re[134:126] = -11;
        di_re[143:135] = -12;
        di_im = '0;

        @(posedge clk);
        di_en = 1;
        di_re[8:0]     = -12;
        di_re[17:9]    = -13;
        di_re[26:18]   = -14;
        di_re[35:27]   = -15;
        di_re[44:36]   = -16;
        di_re[53:45]   = -16;
        di_re[62:54]   = -17;
        di_re[71:63]   = -18;
        di_re[80:72]   = -19;
        di_re[89:81]   = -19;
        di_re[98:90]   = -20;
        di_re[107:99]  = -21;
        di_re[116:108] = -22;
        di_re[125:117] = -22;
        di_re[134:126] = -23;
        di_re[143:135] = -24;
        di_im = '0;

        @(posedge clk);
        di_en = 1;
        di_re[8:0]     = -24;
        di_re[17:9]    = -25;
        di_re[26:18]   = -26;
        di_re[35:27]   = -27;
        di_re[44:36]   = -27;
        di_re[53:45]   = -28;
        di_re[62:54]   = -29;
        di_re[71:63]   = -29;
        di_re[80:72]   = -30;
        di_re[89:81]   = -31;
        di_re[98:90]   = -32;
        di_re[107:99]  = -32;
        di_re[116:108] = -33;
        di_re[125:117] = -34;
        di_re[134:126] = -34;
        di_re[143:135] = -35;
        di_im = '0;

        @(posedge clk);
        di_en = 1;
        di_re[8:0]     = -36;
        di_re[17:9]    = -36;
        di_re[26:18]   = -37;
        di_re[35:27]   = -37;
        di_re[44:36]   = -38;
        di_re[53:45]   = -39;
        di_re[62:54]   = -39;
        di_re[71:63]   = -40;
        di_re[80:72]   = -41;
        di_re[89:81]   = -41;
        di_re[98:90]   = -42;
        di_re[107:99]  = -42;
        di_re[116:108] = -43;
        di_re[125:117] = -44;
        di_re[134:126] = -44;
        di_re[143:135] = -45;
        di_im = '0;

        @(posedge clk);
        di_en = 1;
        di_re[8:0]     = -45;
        di_re[17:9]    = -46;
        di_re[26:18]   = -46;
        di_re[35:27]   = -47;
        di_re[44:36]   = -47;
        di_re[53:45]   = -48;
        di_re[62:54]   = -48;
        di_re[71:63]   = -49;
        di_re[80:72]   = -49;
        di_re[89:81]   = -50;
        di_re[98:90]   = -50;
        di_re[107:99]  = -51;
        di_re[116:108] = -51;
        di_re[125:117] = -52;
        di_re[134:126] = -52;
        di_re[143:135] = -53;
        di_im = '0;

        @(posedge clk);
        di_en = 1;
        di_re[8:0]     = -53;
        di_re[17:9]    = -54;
        di_re[26:18]   = -54;
        di_re[35:27]   = -54;
        di_re[44:36]   = -55;
        di_re[53:45]   = -55;
        di_re[62:54]   = -56;
        di_re[71:63]   = -56;
        di_re[80:72]   = -56;
        di_re[89:81]   = -57;
        di_re[98:90]   = -57;
        di_re[107:99]  = -58;
        di_re[116:108] = -58;
        di_re[125:117] = -58;
        di_re[134:126] = -59;
        di_re[143:135] = -59;
        di_im = '0;

        @(posedge clk);
        di_en = 1;
        di_re[8:0]     = -59;
        di_re[17:9]    = -59;
        di_re[26:18]   = -60;
        di_re[35:27]   = -60;
        di_re[44:36]   = -60;
        di_re[53:45]   = -61;
        di_re[62:54]   = -61;
        di_re[71:63]   = -61;
        di_re[80:72]   = -61;
        di_re[89:81]   = -61;
        di_re[98:90]   = -62;
        di_re[107:99]  = -62;
        di_re[116:108] = -62;
        di_re[125:117] = -62;
        di_re[134:126] = -62;
        di_re[143:135] = -63;
        di_im = '0;

        @(posedge clk);
        di_en = 1;
        di_re[8:0]     = -63;
        di_re[17:9]    = -63;
        di_re[26:18]   = -63;
        di_re[35:27]   = -63;
        di_re[44:36]   = -63;
        di_re[53:45]   = -63;
        di_re[62:54]   = -64;
        di_re[71:63]   = -64;
        di_re[80:72]   = -64;
        di_re[89:81]   = -64;
        di_re[98:90]   = -64;
        di_re[107:99]  = -64;
        di_re[116:108] = -64;
        di_re[125:117] = -64;
        di_re[134:126] = -64;
        di_re[143:135] = -64;
        di_im = '0;

        @(posedge clk);
        di_en = 1;
        di_re[8:0]     = -64;
        di_re[17:9]    = -64;
        di_re[26:18]   = -64;
        di_re[35:27]   = -64;
        di_re[44:36]   = -64;
        di_re[53:45]   = -64;
        di_re[62:54]   = -64;
        di_re[71:63]   = -64;
        di_re[80:72]   = -64;
        di_re[89:81]   = -64;
        di_re[98:90]   = -64;
        di_re[107:99]  = -63;
        di_re[116:108] = -63;
        di_re[125:117] = -63;
        di_re[134:126] = -63;
        di_re[143:135] = -63;
        di_im = '0;

        @(posedge clk);
        di_en = 1;
        di_re[8:0]     = -63;
        di_re[17:9]    = -63;
        di_re[26:18]   = -62;
        di_re[35:27]   = -62;
        di_re[44:36]   = -62;
        di_re[53:45]   = -62;
        di_re[62:54]   = -62;
        di_re[71:63]   = -61;
        di_re[80:72]   = -61;
        di_re[89:81]   = -61;
        di_re[98:90]   = -61;
        di_re[107:99]  = -61;
        di_re[116:108] = -60;
        di_re[125:117] = -60;
        di_re[134:126] = -60;
        di_re[143:135] = -59;
        di_im = '0;

        @(posedge clk);
        di_en = 1;
        di_re[8:0]     = -59;
        di_re[17:9]    = -59;
        di_re[26:18]   = -59;
        di_re[35:27]   = -58;
        di_re[44:36]   = -58;
        di_re[53:45]   = -58;
        di_re[62:54]   = -57;
        di_re[71:63]   = -57;
        di_re[80:72]   = -56;
        di_re[89:81]   = -56;
        di_re[98:90]   = -56;
        di_re[107:99]  = -55;
        di_re[116:108] = -55;
        di_re[125:117] = -54;
        di_re[134:126] = -54;
        di_re[143:135] = -54;
        di_im = '0;

        @(posedge clk);
        di_en = 1;
        di_re[8:0]     = -53;
        di_re[17:9]    = -53;
        di_re[26:18]   = -52;
        di_re[35:27]   = -52;
        di_re[44:36]   = -51;
        di_re[53:45]   = -51;
        di_re[62:54]   = -50;
        di_re[71:63]   = -50;
        di_re[80:72]   = -49;
        di_re[89:81]   = -49;
        di_re[98:90]   = -48;
        di_re[107:99]  = -48;
        di_re[116:108] = -47;
        di_re[125:117] = -47;
        di_re[134:126] = -46;
        di_re[143:135] = -46;
        di_im = '0;

        @(posedge clk);
        di_en = 1;
        di_re[8:0]     = -45;
        di_re[17:9]    = -45;
        di_re[26:18]   = -44;
        di_re[35:27]   = -44;
        di_re[44:36]   = -43;
        di_re[53:45]   = -42;
        di_re[62:54]   = -42;
        di_re[71:63]   = -41;
        di_re[80:72]   = -41;
        di_re[89:81]   = -40;
        di_re[98:90]   = -39;
        di_re[107:99]  = -39;
        di_re[116:108] = -38;
        di_re[125:117] = -37;
        di_re[134:126] = -37;
        di_re[143:135] = -36;
        di_im = '0;

        @(posedge clk);
        di_en = 1;
        di_re[8:0]     = -36;
        di_re[17:9]    = -35;
        di_re[26:18]   = -34;
        di_re[35:27]   = -34;
        di_re[44:36]   = -33;
        di_re[53:45]   = -32;
        di_re[62:54]   = -32;
        di_re[71:63]   = -31;
        di_re[80:72]   = -30;
        di_re[89:81]   = -29;
        di_re[98:90]   = -29;
        di_re[107:99]  = -28;
        di_re[116:108] = -27;
        di_re[125:117] = -27;
        di_re[134:126] = -26;
        di_re[143:135] = -25;
        di_im = '0;

        @(posedge clk);
        di_en = 1;
        di_re[8:0]     = -24;
        di_re[17:9]    = -24;
        di_re[26:18]   = -23;
        di_re[35:27]   = -22;
        di_re[44:36]   = -22;
        di_re[53:45]   = -21;
        di_re[62:54]   = -20;
        di_re[71:63]   = -19;
        di_re[80:72]   = -19;
        di_re[89:81]   = -18;
        di_re[98:90]   = -17;
        di_re[107:99]  = -16;
        di_re[116:108] = -16;
        di_re[125:117] = -15;
        di_re[134:126] = -14;
        di_re[143:135] = -13;
        di_im = '0;

        @(posedge clk);
        di_en = 1;
        di_re[8:0]     = -12;
        di_re[17:9]    = -12;
        di_re[26:18]   = -11;
        di_re[35:27]   = -10;
        di_re[44:36]   = -9;
        di_re[53:45]   = -9;
        di_re[62:54]   = -8;
        di_re[71:63]   = -7;
        di_re[80:72]   = -6;
        di_re[89:81]   = -5;
        di_re[98:90]   = -5;
        di_re[107:99]  = -4;
        di_re[116:108] = -3;
        di_re[125:117] = -2;
        di_re[134:126] = -2;
        di_re[143:135] = -1;
        di_im = '0;

        @(posedge clk);
        di_en = 1;
        di_re[8:0]     = 0;
        di_re[17:9]    = 1;
        di_re[26:18]   = 2;
        di_re[35:27]   = 2;
        di_re[44:36]   = 3;
        di_re[53:45]   = 4;
        di_re[62:54]   = 5;
        di_re[71:63]   = 5;
        di_re[80:72]   = 6;
        di_re[89:81]   = 7;
        di_re[98:90]   = 8;
        di_re[107:99]  = 9;
        di_re[116:108] = 9;
        di_re[125:117] = 10;
        di_re[134:126] = 11;
        di_re[143:135] = 12;
        di_im = '0;

        @(posedge clk);
        di_en = 1;
        di_re[8:0]     = 12;
        di_re[17:9]    = 13;
        di_re[26:18]   = 14;
        di_re[35:27]   = 15;
        di_re[44:36]   = 16;
        di_re[53:45]   = 16;
        di_re[62:54]   = 17;
        di_re[71:63]   = 18;
        di_re[80:72]   = 19;
        di_re[89:81]   = 19;
        di_re[98:90]   = 20;
        di_re[107:99]  = 21;
        di_re[116:108] = 22;
        di_re[125:117] = 22;
        di_re[134:126] = 23;
        di_re[143:135] = 24;
        di_im = '0;

        @(posedge clk);
        di_en = 1;
        di_re[8:0]     = 24;
        di_re[17:9]    = 25;
        di_re[26:18]   = 26;
        di_re[35:27]   = 27;
        di_re[44:36]   = 27;
        di_re[53:45]   = 28;
        di_re[62:54]   = 29;
        di_re[71:63]   = 29;
        di_re[80:72]   = 30;
        di_re[89:81]   = 31;
        di_re[98:90]   = 32;
        di_re[107:99]  = 32;
        di_re[116:108] = 33;
        di_re[125:117] = 34;
        di_re[134:126] = 34;
        di_re[143:135] = 35;
        di_im = '0;

        @(posedge clk);
        di_en = 1;
        di_re[8:0]     = 36;
        di_re[17:9]    = 36;
        di_re[26:18]   = 37;
        di_re[35:27]   = 37;
        di_re[44:36]   = 38;
        di_re[53:45]   = 39;
        di_re[62:54]   = 39;
        di_re[71:63]   = 40;
        di_re[80:72]   = 41;
        di_re[89:81]   = 41;
        di_re[98:90]   = 42;
        di_re[107:99]  = 42;
        di_re[116:108] = 43;
        di_re[125:117] = 44;
        di_re[134:126] = 44;
        di_re[143:135] = 45;
        di_im = '0;

        @(posedge clk);
        di_en = 1;
        di_re[8:0]     = 45;
        di_re[17:9]    = 46;
        di_re[26:18]   = 46;
        di_re[35:27]   = 47;
        di_re[44:36]   = 47;
        di_re[53:45]   = 48;
        di_re[62:54]   = 48;
        di_re[71:63]   = 49;
        di_re[80:72]   = 49;
        di_re[89:81]   = 50;
        di_re[98:90]   = 50;
        di_re[107:99]  = 51;
        di_re[116:108] = 51;
        di_re[125:117] = 52;
        di_re[134:126] = 52;
        di_re[143:135] = 53;
        di_im = '0;

        @(posedge clk);
        di_en = 1;
        di_re[8:0]     = 53;
        di_re[17:9]    = 54;
        di_re[26:18]   = 54;
        di_re[35:27]   = 54;
        di_re[44:36]   = 55;
        di_re[53:45]   = 55;
        di_re[62:54]   = 56;
        di_re[71:63]   = 56;
        di_re[80:72]   = 56;
        di_re[89:81]   = 57;
        di_re[98:90]   = 57;
        di_re[107:99]  = 58;
        di_re[116:108] = 58;
        di_re[125:117] = 58;
        di_re[134:126] = 59;
        di_re[143:135] = 59;
        di_im = '0;

        @(posedge clk);
        di_en = 1;
        di_re[8:0]     = 59;
        di_re[17:9]    = 59;
        di_re[26:18]   = 60;
        di_re[35:27]   = 60;
        di_re[44:36]   = 60;
        di_re[53:45]   = 61;
        di_re[62:54]   = 61;
        di_re[71:63]   = 61;
        di_re[80:72]   = 61;
        di_re[89:81]   = 61;
        di_re[98:90]   = 62;
        di_re[107:99]  = 62;
        di_re[116:108] = 62;
        di_re[125:117] = 62;
        di_re[134:126] = 62;
        di_re[143:135] = 63;
        di_im = '0;

        @(posedge clk);
        di_en = 1;
        di_re[8:0]     = 63;
        di_re[17:9]    = 63;
        di_re[26:18]   = 63;
        di_re[35:27]   = 63;
        di_re[44:36]   = 63;
        di_re[53:45]   = 63;
        di_re[62:54]   = 64;
        di_re[71:63]   = 64;
        di_re[80:72]   = 64;
        di_re[89:81]   = 64;
        di_re[98:90]   = 64;
        di_re[107:99]  = 64;
        di_re[116:108] = 64;
        di_re[125:117] = 64;
        di_re[134:126] = 64;
        di_re[143:135] = 64;
        di_im = '0;

        @(posedge clk);
        di_en = 0;
        #3000;  // 시뮬레이션 진행 시간 확보

        $display("[TB] Simulation finished");
        $finish;
    end

    // ✅ do 출력 결과를 시뮬레이션 동안 기록

    initial begin
        fp = $fopen("do_output.txt", "w");
    end

    always @(posedge clk) begin
        for (int i = 0; i < 16; i++) begin
            $fwrite(fp, "bfly02=%0d+j%0d\n", do_re[i], do_im[i]);
        end
    end

    final begin
        $fclose(fp);
    end
endmodule

