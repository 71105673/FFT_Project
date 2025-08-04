`timescale 1ns / 1ps

module bit_reverse_512_pipeline #(
    parameter DATA_WIDTH   = 13,  // 각 데이터의 폭
    parameter ADDR_WIDTH   = 9,   // 주소 폭 (512 = 2^9)
    parameter PARALLEL_NUM = 16   // 병렬 처리 개수
) (
    input logic clk,
    input logic rst_n,
    input logic valid_in, // 입력 데이터 유효 신호

    // 실수부/허수부 분리된 입력
    input  logic signed [DATA_WIDTH-1:0]               data_in_re [0:PARALLEL_NUM-1],    // 16개 병렬 입력 실수부
    input  logic signed [DATA_WIDTH-1:0]               data_in_im [0:PARALLEL_NUM-1],    // 16개 병렬 입력 허수부

    // 실수부/허수부 분리된 중간 출력
    output logic signed [DATA_WIDTH-1:0]               data_out_re [0:PARALLEL_NUM-1],   // 16개 병렬 출력 실수부
    output logic signed [DATA_WIDTH-1:0]               data_out_im [0:PARALLEL_NUM-1],   // 16개 병렬 출력 허수부
    output logic [ADDR_WIDTH-1:0]               addr_out [0:PARALLEL_NUM-1],      // 16개 출력 주소
    output logic valid_out,  // 출력 데이터 유효 신호

    // 실수부/허수부 분리된 최종 병렬 출력
    output logic signed [DATA_WIDTH-1:0]               final_dout_re [0:PARALLEL_NUM-1], // 16개 병렬 최종 출력 실수부
    output logic signed [DATA_WIDTH-1:0]               final_dout_im [0:PARALLEL_NUM-1], // 16개 병렬 최종 출력 허수부
    output logic [5:0]                          final_block_index,               // 현재 출력 블록 인덱스 (0~31)
    output logic final_valid,  // 최종 출력 유효 신호
    output logic final_complete  // 모든 출력 완료 신호
);

    // 비트 리버스 룩업 테이블
    function logic [ADDR_WIDTH-1:0] bitrev_out(
        input logic [ADDR_WIDTH-1:0] addr);
        case (addr)
            9'd0   : bitrev_out = 9'd0;
            9'd1   : bitrev_out = 9'd256;
            9'd2   : bitrev_out = 9'd128;
            9'd3   : bitrev_out = 9'd384;
            9'd4   : bitrev_out = 9'd64;
            9'd5   : bitrev_out = 9'd320;
            9'd6   : bitrev_out = 9'd192;
            9'd7   : bitrev_out = 9'd448;
            9'd8   : bitrev_out = 9'd32;
            9'd9   : bitrev_out = 9'd288;
            9'd10  : bitrev_out = 9'd160;
            9'd11  : bitrev_out = 9'd416;
            9'd12  : bitrev_out = 9'd96;
            9'd13  : bitrev_out = 9'd352;
            9'd14  : bitrev_out = 9'd224;
            9'd15  : bitrev_out = 9'd480;
            9'd16  : bitrev_out = 9'd16;
            9'd17  : bitrev_out = 9'd272;
            9'd18  : bitrev_out = 9'd144;
            9'd19  : bitrev_out = 9'd400;
            9'd20  : bitrev_out = 9'd80;
            9'd21  : bitrev_out = 9'd336;
            9'd22  : bitrev_out = 9'd208;
            9'd23  : bitrev_out = 9'd464;
            9'd24  : bitrev_out = 9'd48;
            9'd25  : bitrev_out = 9'd304;
            9'd26  : bitrev_out = 9'd176;
            9'd27  : bitrev_out = 9'd432;
            9'd28  : bitrev_out = 9'd112;
            9'd29  : bitrev_out = 9'd368;
            9'd30  : bitrev_out = 9'd240;
            9'd31  : bitrev_out = 9'd496;
            9'd32  : bitrev_out = 9'd8;
            9'd33  : bitrev_out = 9'd264;
            9'd34  : bitrev_out = 9'd136;
            9'd35  : bitrev_out = 9'd392;
            9'd36  : bitrev_out = 9'd72;
            9'd37  : bitrev_out = 9'd328;
            9'd38  : bitrev_out = 9'd200;
            9'd39  : bitrev_out = 9'd456;
            9'd40  : bitrev_out = 9'd40;
            9'd41  : bitrev_out = 9'd296;
            9'd42  : bitrev_out = 9'd168;
            9'd43  : bitrev_out = 9'd424;
            9'd44  : bitrev_out = 9'd104;
            9'd45  : bitrev_out = 9'd360;
            9'd46  : bitrev_out = 9'd232;
            9'd47  : bitrev_out = 9'd488;
            9'd48  : bitrev_out = 9'd24;
            9'd49  : bitrev_out = 9'd280;
            9'd50  : bitrev_out = 9'd152;
            9'd51  : bitrev_out = 9'd408;
            9'd52  : bitrev_out = 9'd88;
            9'd53  : bitrev_out = 9'd344;
            9'd54  : bitrev_out = 9'd216;
            9'd55  : bitrev_out = 9'd472;
            9'd56  : bitrev_out = 9'd56;
            9'd57  : bitrev_out = 9'd312;
            9'd58  : bitrev_out = 9'd184;
            9'd59  : bitrev_out = 9'd440;
            9'd60  : bitrev_out = 9'd120;
            9'd61  : bitrev_out = 9'd376;
            9'd62  : bitrev_out = 9'd248;
            9'd63  : bitrev_out = 9'd504;
            9'd64  : bitrev_out = 9'd4;
            9'd65  : bitrev_out = 9'd260;
            9'd66  : bitrev_out = 9'd132;
            9'd67  : bitrev_out = 9'd388;
            9'd68  : bitrev_out = 9'd68;
            9'd69  : bitrev_out = 9'd324;
            9'd70  : bitrev_out = 9'd196;
            9'd71  : bitrev_out = 9'd452;
            9'd72  : bitrev_out = 9'd36;
            9'd73  : bitrev_out = 9'd292;
            9'd74  : bitrev_out = 9'd164;
            9'd75  : bitrev_out = 9'd420;
            9'd76  : bitrev_out = 9'd100;
            9'd77  : bitrev_out = 9'd356;
            9'd78  : bitrev_out = 9'd228;
            9'd79  : bitrev_out = 9'd484;
            9'd80  : bitrev_out = 9'd20;
            9'd81  : bitrev_out = 9'd276;
            9'd82  : bitrev_out = 9'd148;
            9'd83  : bitrev_out = 9'd404;
            9'd84  : bitrev_out = 9'd84;
            9'd85  : bitrev_out = 9'd340;
            9'd86  : bitrev_out = 9'd212;
            9'd87  : bitrev_out = 9'd468;
            9'd88  : bitrev_out = 9'd52;
            9'd89  : bitrev_out = 9'd308;
            9'd90  : bitrev_out = 9'd180;
            9'd91  : bitrev_out = 9'd436;
            9'd92  : bitrev_out = 9'd116;
            9'd93  : bitrev_out = 9'd372;
            9'd94  : bitrev_out = 9'd244;
            9'd95  : bitrev_out = 9'd500;
            9'd96  : bitrev_out = 9'd12;
            9'd97  : bitrev_out = 9'd268;
            9'd98  : bitrev_out = 9'd140;
            9'd99  : bitrev_out = 9'd396;
            9'd100 : bitrev_out = 9'd76;
            9'd101 : bitrev_out = 9'd332;
            9'd102 : bitrev_out = 9'd204;
            9'd103 : bitrev_out = 9'd460;
            9'd104 : bitrev_out = 9'd44;
            9'd105 : bitrev_out = 9'd300;
            9'd106 : bitrev_out = 9'd172;
            9'd107 : bitrev_out = 9'd428;
            9'd108 : bitrev_out = 9'd108;
            9'd109 : bitrev_out = 9'd364;
            9'd110 : bitrev_out = 9'd236;
            9'd111 : bitrev_out = 9'd492;
            9'd112 : bitrev_out = 9'd28;
            9'd113 : bitrev_out = 9'd284;
            9'd114 : bitrev_out = 9'd156;
            9'd115 : bitrev_out = 9'd412;
            9'd116 : bitrev_out = 9'd92;
            9'd117 : bitrev_out = 9'd348;
            9'd118 : bitrev_out = 9'd220;
            9'd119 : bitrev_out = 9'd476;
            9'd120 : bitrev_out = 9'd60;
            9'd121 : bitrev_out = 9'd316;
            9'd122 : bitrev_out = 9'd188;
            9'd123 : bitrev_out = 9'd444;
            9'd124 : bitrev_out = 9'd124;
            9'd125 : bitrev_out = 9'd380;
            9'd126 : bitrev_out = 9'd252;
            9'd127 : bitrev_out = 9'd508;
            9'd128 : bitrev_out = 9'd2;
            9'd129 : bitrev_out = 9'd258;
            9'd130 : bitrev_out = 9'd130;
            9'd131 : bitrev_out = 9'd386;
            9'd132 : bitrev_out = 9'd66;
            9'd133 : bitrev_out = 9'd322;
            9'd134 : bitrev_out = 9'd194;
            9'd135 : bitrev_out = 9'd450;
            9'd136 : bitrev_out = 9'd34;
            9'd137 : bitrev_out = 9'd290;
            9'd138 : bitrev_out = 9'd162;
            9'd139 : bitrev_out = 9'd418;
            9'd140 : bitrev_out = 9'd98;
            9'd141 : bitrev_out = 9'd354;
            9'd142 : bitrev_out = 9'd226;
            9'd143 : bitrev_out = 9'd482;
            9'd144 : bitrev_out = 9'd18;
            9'd145 : bitrev_out = 9'd274;
            9'd146 : bitrev_out = 9'd146;
            9'd147 : bitrev_out = 9'd402;
            9'd148 : bitrev_out = 9'd82;
            9'd149 : bitrev_out = 9'd338;
            9'd150 : bitrev_out = 9'd210;
            9'd151 : bitrev_out = 9'd466;
            9'd152 : bitrev_out = 9'd50;
            9'd153 : bitrev_out = 9'd306;
            9'd154 : bitrev_out = 9'd178;
            9'd155 : bitrev_out = 9'd434;
            9'd156 : bitrev_out = 9'd114;
            9'd157 : bitrev_out = 9'd370;
            9'd158 : bitrev_out = 9'd242;
            9'd159 : bitrev_out = 9'd498;
            9'd160 : bitrev_out = 9'd10;
            9'd161 : bitrev_out = 9'd266;
            9'd162 : bitrev_out = 9'd138;
            9'd163 : bitrev_out = 9'd394;
            9'd164 : bitrev_out = 9'd74;
            9'd165 : bitrev_out = 9'd330;
            9'd166 : bitrev_out = 9'd202;
            9'd167 : bitrev_out = 9'd458;
            9'd168 : bitrev_out = 9'd42;
            9'd169 : bitrev_out = 9'd298;
            9'd170 : bitrev_out = 9'd170;
            9'd171 : bitrev_out = 9'd426;
            9'd172 : bitrev_out = 9'd106;
            9'd173 : bitrev_out = 9'd362;
            9'd174 : bitrev_out = 9'd234;
            9'd175 : bitrev_out = 9'd490;
            9'd176 : bitrev_out = 9'd26;
            9'd177 : bitrev_out = 9'd282;
            9'd178 : bitrev_out = 9'd154;
            9'd179 : bitrev_out = 9'd410;
            9'd180 : bitrev_out = 9'd90;
            9'd181 : bitrev_out = 9'd346;
            9'd182 : bitrev_out = 9'd218;
            9'd183 : bitrev_out = 9'd474;
            9'd184 : bitrev_out = 9'd58;
            9'd185 : bitrev_out = 9'd314;
            9'd186 : bitrev_out = 9'd186;
            9'd187 : bitrev_out = 9'd442;
            9'd188 : bitrev_out = 9'd122;
            9'd189 : bitrev_out = 9'd378;
            9'd190 : bitrev_out = 9'd250;
            9'd191 : bitrev_out = 9'd506;
            9'd192 : bitrev_out = 9'd6;
            9'd193 : bitrev_out = 9'd262;
            9'd194 : bitrev_out = 9'd134;
            9'd195 : bitrev_out = 9'd390;
            9'd196 : bitrev_out = 9'd70;
            9'd197 : bitrev_out = 9'd326;
            9'd198 : bitrev_out = 9'd198;
            9'd199 : bitrev_out = 9'd454;
            9'd200 : bitrev_out = 9'd38;
            9'd201 : bitrev_out = 9'd294;
            9'd202 : bitrev_out = 9'd166;
            9'd203 : bitrev_out = 9'd422;
            9'd204 : bitrev_out = 9'd102;
            9'd205 : bitrev_out = 9'd358;
            9'd206 : bitrev_out = 9'd230;
            9'd207 : bitrev_out = 9'd486;
            9'd208 : bitrev_out = 9'd22;
            9'd209 : bitrev_out = 9'd278;
            9'd210 : bitrev_out = 9'd150;
            9'd211 : bitrev_out = 9'd406;
            9'd212 : bitrev_out = 9'd86;
            9'd213 : bitrev_out = 9'd342;
            9'd214 : bitrev_out = 9'd214;
            9'd215 : bitrev_out = 9'd470;
            9'd216 : bitrev_out = 9'd54;
            9'd217 : bitrev_out = 9'd310;
            9'd218 : bitrev_out = 9'd182;
            9'd219 : bitrev_out = 9'd438;
            9'd220 : bitrev_out = 9'd118;
            9'd221 : bitrev_out = 9'd374;
            9'd222 : bitrev_out = 9'd246;
            9'd223 : bitrev_out = 9'd502;
            9'd224 : bitrev_out = 9'd14;
            9'd225 : bitrev_out = 9'd270;
            9'd226 : bitrev_out = 9'd142;
            9'd227 : bitrev_out = 9'd398;
            9'd228 : bitrev_out = 9'd78;
            9'd229 : bitrev_out = 9'd334;
            9'd230 : bitrev_out = 9'd206;
            9'd231 : bitrev_out = 9'd462;
            9'd232 : bitrev_out = 9'd46;
            9'd233 : bitrev_out = 9'd302;
            9'd234 : bitrev_out = 9'd174;
            9'd235 : bitrev_out = 9'd430;
            9'd236 : bitrev_out = 9'd110;
            9'd237 : bitrev_out = 9'd366;
            9'd238 : bitrev_out = 9'd238;
            9'd239 : bitrev_out = 9'd494;
            9'd240 : bitrev_out = 9'd30;
            9'd241 : bitrev_out = 9'd286;
            9'd242 : bitrev_out = 9'd158;
            9'd243 : bitrev_out = 9'd414;
            9'd244 : bitrev_out = 9'd94;
            9'd245 : bitrev_out = 9'd350;
            9'd246 : bitrev_out = 9'd222;
            9'd247 : bitrev_out = 9'd478;
            9'd248 : bitrev_out = 9'd62;
            9'd249 : bitrev_out = 9'd318;
            9'd250 : bitrev_out = 9'd190;
            9'd251 : bitrev_out = 9'd446;
            9'd252 : bitrev_out = 9'd126;
            9'd253 : bitrev_out = 9'd382;
            9'd254 : bitrev_out = 9'd254;
            9'd255 : bitrev_out = 9'd510;
            9'd256 : bitrev_out = 9'd1;
            9'd257 : bitrev_out = 9'd257;
            9'd258 : bitrev_out = 9'd129;
            9'd259 : bitrev_out = 9'd385;
            9'd260 : bitrev_out = 9'd65;
            9'd261 : bitrev_out = 9'd321;
            9'd262 : bitrev_out = 9'd193;
            9'd263 : bitrev_out = 9'd449;
            9'd264 : bitrev_out = 9'd33;
            9'd265 : bitrev_out = 9'd289;
            9'd266 : bitrev_out = 9'd161;
            9'd267 : bitrev_out = 9'd417;
            9'd268 : bitrev_out = 9'd97;
            9'd269 : bitrev_out = 9'd353;
            9'd270 : bitrev_out = 9'd225;
            9'd271 : bitrev_out = 9'd481;
            9'd272 : bitrev_out = 9'd17;
            9'd273 : bitrev_out = 9'd273;
            9'd274 : bitrev_out = 9'd145;
            9'd275 : bitrev_out = 9'd401;
            9'd276 : bitrev_out = 9'd81;
            9'd277 : bitrev_out = 9'd337;
            9'd278 : bitrev_out = 9'd209;
            9'd279 : bitrev_out = 9'd465;
            9'd280 : bitrev_out = 9'd49;
            9'd281 : bitrev_out = 9'd305;
            9'd282 : bitrev_out = 9'd177;
            9'd283 : bitrev_out = 9'd433;
            9'd284 : bitrev_out = 9'd113;
            9'd285 : bitrev_out = 9'd369;
            9'd286 : bitrev_out = 9'd241;
            9'd287 : bitrev_out = 9'd497;
            9'd288 : bitrev_out = 9'd9;
            9'd289 : bitrev_out = 9'd265;
            9'd290 : bitrev_out = 9'd137;
            9'd291 : bitrev_out = 9'd393;
            9'd292 : bitrev_out = 9'd73;
            9'd293 : bitrev_out = 9'd329;
            9'd294 : bitrev_out = 9'd201;
            9'd295 : bitrev_out = 9'd457;
            9'd296 : bitrev_out = 9'd41;
            9'd297 : bitrev_out = 9'd297;
            9'd298 : bitrev_out = 9'd169;
            9'd299 : bitrev_out = 9'd425;
            9'd300 : bitrev_out = 9'd105;
            9'd301 : bitrev_out = 9'd361;
            9'd302 : bitrev_out = 9'd233;
            9'd303 : bitrev_out = 9'd489;
            9'd304 : bitrev_out = 9'd25;
            9'd305 : bitrev_out = 9'd281;
            9'd306 : bitrev_out = 9'd153;
            9'd307 : bitrev_out = 9'd409;
            9'd308 : bitrev_out = 9'd89;
            9'd309 : bitrev_out = 9'd345;
            9'd310 : bitrev_out = 9'd217;
            9'd311 : bitrev_out = 9'd473;
            9'd312 : bitrev_out = 9'd57;
            9'd313 : bitrev_out = 9'd313;
            9'd314 : bitrev_out = 9'd185;
            9'd315 : bitrev_out = 9'd441;
            9'd316 : bitrev_out = 9'd121;
            9'd317 : bitrev_out = 9'd377;
            9'd318 : bitrev_out = 9'd249;
            9'd319 : bitrev_out = 9'd505;
            9'd320 : bitrev_out = 9'd5;
            9'd321 : bitrev_out = 9'd261;
            9'd322 : bitrev_out = 9'd133;
            9'd323 : bitrev_out = 9'd389;
            9'd324 : bitrev_out = 9'd69;
            9'd325 : bitrev_out = 9'd325;
            9'd326 : bitrev_out = 9'd197;
            9'd327 : bitrev_out = 9'd453;
            9'd328 : bitrev_out = 9'd37;
            9'd329 : bitrev_out = 9'd293;
            9'd330 : bitrev_out = 9'd165;
            9'd331 : bitrev_out = 9'd421;
            9'd332 : bitrev_out = 9'd101;
            9'd333 : bitrev_out = 9'd357;
            9'd334 : bitrev_out = 9'd229;
            9'd335 : bitrev_out = 9'd485;
            9'd336 : bitrev_out = 9'd21;
            9'd337 : bitrev_out = 9'd277;
            9'd338 : bitrev_out = 9'd149;
            9'd339 : bitrev_out = 9'd405;
            9'd340 : bitrev_out = 9'd85;
            9'd341 : bitrev_out = 9'd341;
            9'd342 : bitrev_out = 9'd213;
            9'd343 : bitrev_out = 9'd469;
            9'd344 : bitrev_out = 9'd53;
            9'd345 : bitrev_out = 9'd309;
            9'd346 : bitrev_out = 9'd181;
            9'd347 : bitrev_out = 9'd437;
            9'd348 : bitrev_out = 9'd117;
            9'd349 : bitrev_out = 9'd373;
            9'd350 : bitrev_out = 9'd245;
            9'd351 : bitrev_out = 9'd501;
            9'd352 : bitrev_out = 9'd13;
            9'd353 : bitrev_out = 9'd269;
            9'd354 : bitrev_out = 9'd141;
            9'd355 : bitrev_out = 9'd397;
            9'd356 : bitrev_out = 9'd77;
            9'd357 : bitrev_out = 9'd333;
            9'd358 : bitrev_out = 9'd205;
            9'd359 : bitrev_out = 9'd461;
            9'd360 : bitrev_out = 9'd45;
            9'd361 : bitrev_out = 9'd301;
            9'd362 : bitrev_out = 9'd173;
            9'd363 : bitrev_out = 9'd429;
            9'd364 : bitrev_out = 9'd109;
            9'd365 : bitrev_out = 9'd365;
            9'd366 : bitrev_out = 9'd237;
            9'd367 : bitrev_out = 9'd493;
            9'd368 : bitrev_out = 9'd29;
            9'd369 : bitrev_out = 9'd285;
            9'd370 : bitrev_out = 9'd157;
            9'd371 : bitrev_out = 9'd413;
            9'd372 : bitrev_out = 9'd93;
            9'd373 : bitrev_out = 9'd349;
            9'd374 : bitrev_out = 9'd221;
            9'd375 : bitrev_out = 9'd477;
            9'd376 : bitrev_out = 9'd61;
            9'd377 : bitrev_out = 9'd317;
            9'd378 : bitrev_out = 9'd189;
            9'd379 : bitrev_out = 9'd445;
            9'd380 : bitrev_out = 9'd125;
            9'd381 : bitrev_out = 9'd381;
            9'd382 : bitrev_out = 9'd253;
            9'd383 : bitrev_out = 9'd509;
            9'd384 : bitrev_out = 9'd3;
            9'd385 : bitrev_out = 9'd259;
            9'd386 : bitrev_out = 9'd131;
            9'd387 : bitrev_out = 9'd387;
            9'd388 : bitrev_out = 9'd67;
            9'd389 : bitrev_out = 9'd323;
            9'd390 : bitrev_out = 9'd195;
            9'd391 : bitrev_out = 9'd451;
            9'd392 : bitrev_out = 9'd35;
            9'd393 : bitrev_out = 9'd291;
            9'd394 : bitrev_out = 9'd163;
            9'd395 : bitrev_out = 9'd419;
            9'd396 : bitrev_out = 9'd99;
            9'd397 : bitrev_out = 9'd355;
            9'd398 : bitrev_out = 9'd227;
            9'd399 : bitrev_out = 9'd483;
            9'd400 : bitrev_out = 9'd19;
            9'd401 : bitrev_out = 9'd275;
            9'd402 : bitrev_out = 9'd147;
            9'd403 : bitrev_out = 9'd403;
            9'd404 : bitrev_out = 9'd83;
            9'd405 : bitrev_out = 9'd339;
            9'd406 : bitrev_out = 9'd211;
            9'd407 : bitrev_out = 9'd467;
            9'd408 : bitrev_out = 9'd51;
            9'd409 : bitrev_out = 9'd307;
            9'd410 : bitrev_out = 9'd179;
            9'd411 : bitrev_out = 9'd435;
            9'd412 : bitrev_out = 9'd115;
            9'd413 : bitrev_out = 9'd371;
            9'd414 : bitrev_out = 9'd243;
            9'd415 : bitrev_out = 9'd499;
            9'd416 : bitrev_out = 9'd11;
            9'd417 : bitrev_out = 9'd267;
            9'd418 : bitrev_out = 9'd139;
            9'd419 : bitrev_out = 9'd395;
            9'd420 : bitrev_out = 9'd75;
            9'd421 : bitrev_out = 9'd331;
            9'd422 : bitrev_out = 9'd203;
            9'd423 : bitrev_out = 9'd459;
            9'd424 : bitrev_out = 9'd43;
            9'd425 : bitrev_out = 9'd299;
            9'd426 : bitrev_out = 9'd171;
            9'd427 : bitrev_out = 9'd427;
            9'd428 : bitrev_out = 9'd107;
            9'd429 : bitrev_out = 9'd363;
            9'd430 : bitrev_out = 9'd235;
            9'd431 : bitrev_out = 9'd491;
            9'd432 : bitrev_out = 9'd27;
            9'd433 : bitrev_out = 9'd283;
            9'd434 : bitrev_out = 9'd155;
            9'd435 : bitrev_out = 9'd411;
            9'd436 : bitrev_out = 9'd91;
            9'd437 : bitrev_out = 9'd347;
            9'd438 : bitrev_out = 9'd219;
            9'd439 : bitrev_out = 9'd475;
            9'd440 : bitrev_out = 9'd59;
            9'd441 : bitrev_out = 9'd315;
            9'd442 : bitrev_out = 9'd187;
            9'd443 : bitrev_out = 9'd443;
            9'd444 : bitrev_out = 9'd123;
            9'd445 : bitrev_out = 9'd379;
            9'd446 : bitrev_out = 9'd251;
            9'd447 : bitrev_out = 9'd507;
            9'd448 : bitrev_out = 9'd7;
            9'd449 : bitrev_out = 9'd263;
            9'd450 : bitrev_out = 9'd135;
            9'd451 : bitrev_out = 9'd391;
            9'd452 : bitrev_out = 9'd71;
            9'd453 : bitrev_out = 9'd327;
            9'd454 : bitrev_out = 9'd199;
            9'd455 : bitrev_out = 9'd455;
            9'd456 : bitrev_out = 9'd39;
            9'd457 : bitrev_out = 9'd295;
            9'd458 : bitrev_out = 9'd167;
            9'd459 : bitrev_out = 9'd423;
            9'd460 : bitrev_out = 9'd103;
            9'd461 : bitrev_out = 9'd359;
            9'd462 : bitrev_out = 9'd231;
            9'd463 : bitrev_out = 9'd487;
            9'd464 : bitrev_out = 9'd23;
            9'd465 : bitrev_out = 9'd279;
            9'd466 : bitrev_out = 9'd151;
            9'd467 : bitrev_out = 9'd407;
            9'd468 : bitrev_out = 9'd87;
            9'd469 : bitrev_out = 9'd343;
            9'd470 : bitrev_out = 9'd215;
            9'd471 : bitrev_out = 9'd471;
            9'd472 : bitrev_out = 9'd55;
            9'd473 : bitrev_out = 9'd311;
            9'd474 : bitrev_out = 9'd183;
            9'd475 : bitrev_out = 9'd439;
            9'd476 : bitrev_out = 9'd119;
            9'd477 : bitrev_out = 9'd375;
            9'd478 : bitrev_out = 9'd247;
            9'd479 : bitrev_out = 9'd503;
            9'd480 : bitrev_out = 9'd15;
            9'd481 : bitrev_out = 9'd271;
            9'd482 : bitrev_out = 9'd143;
            9'd483 : bitrev_out = 9'd399;
            9'd484 : bitrev_out = 9'd79;
            9'd485 : bitrev_out = 9'd335;
            9'd486 : bitrev_out = 9'd207;
            9'd487 : bitrev_out = 9'd463;
            9'd488 : bitrev_out = 9'd47;
            9'd489 : bitrev_out = 9'd303;
            9'd490 : bitrev_out = 9'd175;
            9'd491 : bitrev_out = 9'd431;
            9'd492 : bitrev_out = 9'd111;
            9'd493 : bitrev_out = 9'd367;
            9'd494 : bitrev_out = 9'd239;
            9'd495 : bitrev_out = 9'd495;
            9'd496 : bitrev_out = 9'd31;
            9'd497 : bitrev_out = 9'd287;
            9'd498 : bitrev_out = 9'd159;
            9'd499 : bitrev_out = 9'd415;
            9'd500 : bitrev_out = 9'd95;
            9'd501 : bitrev_out = 9'd351;
            9'd502 : bitrev_out = 9'd223;
            9'd503 : bitrev_out = 9'd479;
            9'd504 : bitrev_out = 9'd63;
            9'd505 : bitrev_out = 9'd319;
            9'd506 : bitrev_out = 9'd191;
            9'd507 : bitrev_out = 9'd447;
            9'd508 : bitrev_out = 9'd127;
            9'd509 : bitrev_out = 9'd383;
            9'd510 : bitrev_out = 9'd255;
            9'd511 : bitrev_out = 9'd511;
            default : bitrev_out = 9'd0;
        endcase
    endfunction

    // 내부 신호들
    logic [5:0] input_block_counter;  // 입력 블록 카운터 (0-31)
    logic [5:0] output_block_counter;  // 출력 블록 카운터 (0-31)

    // 실수부/허수부 분리된 메모리
    logic signed [DATA_WIDTH-1:0] memory_re[0:511];
    logic signed [DATA_WIDTH-1:0] memory_im[0:511];

    // 파이프라인 제어 신호
    logic [5:0] blocks_stored;  // 저장된 블록 수
    logic [5:0] blocks_output;  // 출력된 블록 수

    // 최종 출력 제어 신호들
    logic [5:0] final_output_counter;  // 최종 출력 블록 카운터 (0-31)
    logic all_blocks_stored;  // 모든 512개 데이터 저장 완료
    logic final_output_active;  // 최종 출력 활성화

    // 실수부/허수부 분리된 최종 메모리
    logic signed [DATA_WIDTH-1:0] final_memory_re[0:511];
    logic signed [DATA_WIDTH-1:0] final_memory_im[0:511];

    // 입력 블록 카운터 및 데이터 저장
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            input_block_counter <= 0;
            blocks_stored <= 0;
            all_blocks_stored <= 0;
        end else begin
            if (valid_in) begin
                // 16개 데이터를 병렬로 메모리에 저장 (실수부/허수부 분리)
                for (int i = 0; i < PARALLEL_NUM; i++) begin
                    memory_re[input_block_counter * PARALLEL_NUM + i] <= data_in_re[i];
                    memory_im[input_block_counter * PARALLEL_NUM + i] <= data_in_im[i];
                end

                // 입력 블록 카운터 및 저장된 블록 수 업데이트
                if (input_block_counter == 31) begin
                    input_block_counter <= 0;
                    all_blocks_stored   <= 1;
                end else begin
                    input_block_counter <= input_block_counter + 1;
                end

                blocks_stored <= blocks_stored + 1;
            end
        end
    end

    // 출력 블록 카운터 및 제어
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            output_block_counter <= 0;
            blocks_output <= 0;
        end else begin
            if (valid_out) begin
                output_block_counter <= output_block_counter + 1;
                blocks_output <= blocks_output + 1;
            end
        end
    end

    // 출력 valid 신호 생성
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_out <= 0;
        end else begin
            // 저장된 블록이 출력된 블록보다 많고, 출력 블록이 32개 미만일 때만 출력
            if (blocks_stored > blocks_output && blocks_output < 31) begin
                valid_out <= 1;
            end else begin
                valid_out <= 0;
            end
        end
    end

    // 병렬 출력 데이터 및 주소 생성
    always_comb begin
        if (valid_out) begin
            for (int i = 0; i < PARALLEL_NUM; i++) begin
                logic [ADDR_WIDTH-1:0] sequential_addr;
                logic [ADDR_WIDTH-1:0] bit_reversed_addr;

                // 현재 출력 블록의 주소 계산
                sequential_addr = output_block_counter * PARALLEL_NUM + i;

                // 비트 리버스된 주소 계산
                bit_reversed_addr = bitrev_out(sequential_addr);

                // 중간 출력 (디버그용) - 실수부/허수부 분리
                data_out_re[i] = memory_re[sequential_addr];
                data_out_im[i] = memory_im[sequential_addr];
                addr_out[i] = bit_reversed_addr;
            end
        end else begin
            for (int i = 0; i < PARALLEL_NUM; i++) begin
                data_out_re[i] = '0;
                data_out_im[i] = '0;
                addr_out[i] = '0;
            end
        end
    end

    // 비트 리버스된 데이터를 final_memory에 저장
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 512; i++) begin
                final_memory_re[i] <= '0;
                final_memory_im[i] <= '0;
            end
        end else begin
            if (valid_out) begin
                for (int i = 0; i < PARALLEL_NUM; i++) begin
                    logic [ADDR_WIDTH-1:0] jj;  // Sequential index
                    logic [ADDR_WIDTH-1:0] kk;  // Bit reversed index

                    jj = output_block_counter * PARALLEL_NUM + i;
                    kk = bitrev_out(jj);

                    // 비트 리버스된 위치에 데이터 저장 (실수부/허수부 분리)
                    final_memory_re[kk] <= memory_re[jj];
                    final_memory_im[kk] <= memory_im[jj];
                end
            end
        end
    end

    // 최종 출력 제어
    logic [3:0] wait_counter;  // 8클럭 대기용 카운터
    logic       waiting;  // 8클럭 대기 상태 플래그

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            final_output_counter <= 0;
            final_output_active <= 0;
            final_valid <= 0;
            final_complete <= 0;
            wait_counter <= 0;
            waiting <= 0;
        end else begin
            if (!final_output_active && !final_complete && !waiting) begin
                if (all_blocks_stored && blocks_output == 32) begin
                    final_output_active <= 1;
                    final_valid <= 1;
                    final_output_counter <= 0;
                end else begin
                    final_valid <= 0;
                end
            end else if (final_output_active) begin
                final_valid <= 1;
                if (final_output_counter == 31) begin
                    final_output_active <= 0;
                    final_complete <= 1;
                    final_valid <= 0;
                    final_output_counter <= 0;
                    waiting <= 1;
                    wait_counter <= 0;
                end else begin
                    final_output_counter <= final_output_counter + 1;
                end
            end else if (waiting) begin
                if (wait_counter == 7) begin
                    waiting <= 0;
                    final_complete <= 0;
                    final_output_active <= 1;
                    final_valid <= 1;
                    final_output_counter <= 0;
                end else begin
                    wait_counter <= wait_counter + 1;
                end
            end else begin
                final_valid <= 0;
            end
        end
    end

    // 최종 병렬 출력 데이터 생성
    always_comb begin
        final_block_index = final_output_counter;

        if (final_valid) begin
            for (int i = 0; i < PARALLEL_NUM; i++) begin
                final_dout_re[i] = final_memory_re[final_output_counter * PARALLEL_NUM + i];
                final_dout_im[i] = final_memory_im[final_output_counter * PARALLEL_NUM + i];
            end
        end else begin
            for (int i = 0; i < PARALLEL_NUM; i++) begin
                final_dout_re[i] = '0;
                final_dout_im[i] = '0;
            end
        end
    end

endmodule
