// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */

module user_proj_example #(
    parameter BITS = 32
)(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // IRQ
    output [2:0] irq
);
    wire clk;
    wire rst;

    wire [`MPRJ_IO_PADS-1:0] io_in;
    wire [`MPRJ_IO_PADS-1:0] io_out;
    wire [`MPRJ_IO_PADS-1:0] io_oeb;

    wire [31:0] rdata; 
    wire [31:0] wdata;
    wire [BITS-1:0] count;

    wire valid;
    wire [3:0] wstrb;
    wire [31:0] la_write;

    // WB MI A
    assign valid = wbs_cyc_i && wbs_stb_i; 
    assign wstrb = wbs_sel_i & {4{wbs_we_i}};
    assign wbs_dat_o = rdata;
    assign wdata = wbs_dat_i;

    // IO
    assign io_out = count;
    assign io_oeb = {(`MPRJ_IO_PADS-1){rst}};

    // IRQ
    assign irq = 3'b000;	// Unused

    // LA
    assign la_data_out = {{(127-BITS){1'b0}}, count};
    // Assuming LA probes [63:32] are for controlling the count register  
    assign la_write = ~la_oenb[63:32] & ~{BITS{valid}};
    // Assuming LA probes [65:64] are for controlling the count clk & reset  
    assign clk = (~la_oenb[64]) ? la_data_in[64]: wb_clk_i;
    assign rst = (~la_oenb[65]) ? la_data_in[65]: wb_rst_i;

ksa16 dut(.a(rdata[16:0]), .b(rdata[32:17]), .cin(rdata[33]), .sum(count[16:0]), .carryout(count[17]));

endmodule

module ksa16
    (
input [15:0]a,
input [15:0]b,
input cin,
output [15:0]sum,
output carryout
    );
wire [15:0] p,g,p1,g1,p2,g2,p3,g3,p4,g4;
wire c;

assign p=a^b;
assign g=a&b;

assign g1[0]=(g[0]);
assign p1[0]=(p[0]);

assign g1[1]=(p[1]&g[0])|g[1];
assign p1[1]=(p[1]&p[0]);

assign g1[2]=(p[2]&g[1])|g[2];
assign p1[2]=p[2]&p[1];

assign g1[3]=(p[3]&g[2])|g[3];
assign p1[3]=p[3]&p[2];

assign g1[4]=(p[4]&g[3])|g[4];
assign p1[4]=p[4]&p[3];

assign g1[5]=(p[5]&g[4])|g[5];
assign p1[5]=p[5]&p[4];

assign g1[6]=(p[6]&g[5])|g[6];
assign p1[6]=p[6]&p[5];

assign g1[7]=(p[7]&g[6])|g[7];
assign p1[7]=p[7]&p[6];

assign g1[8]=(p[8]&g[7])|g[8];
assign p1[8]=p[8]&p[7];

assign g1[9]=(p[9]&g[8])|g[9];
assign p1[9]=p[9]&p[8];

assign g1[10]=(p[10]&g[9])|g[10];
assign p1[10]=p[10]&p[9];

assign g1[11]=(p[11]&g[10])|g[11];
assign p1[11]=p[11]&p[10];

assign g1[12]=(p[12]&g[11])|g[12];
assign p1[12]=p[12]&p[11];

assign g1[13]=(p[13]&g[12])|g[13];
assign p1[13]=p[13]&p[12];

assign g1[14]=(p[14]&g[13])|g[14];
assign p1[14]=p[14]&p[13];

assign g1[15]=(p[15]&g[14])|g[15];
assign p1[15]=p[15]&p[14];

assign g2[0]=g1[0];
assign p2[0]=p1[0];

assign g2[1]=g1[1];
assign p2[1]=p1[1];

assign g2[2]=(p1[2]&g1[0])|g1[2];
assign p2[2]=p1[2]&p1[0];

assign g2[3]=(p1[3]&g1[1])|g1[3];
assign p2[3]=p1[3]&p1[1];

assign g2[4]=(p1[4]&g1[2])|g1[4];
assign p2[4]=p1[4]&p1[2];

assign g2[5]=(p1[5]&g1[3])|g1[5];
assign p2[5]=p1[5]&p1[3];

assign g2[6]=(p1[6]&g1[4])|g1[6];
assign p2[6]=p1[6]&p1[4];

assign g2[7]=(p1[7]&g1[5])|g1[7];
assign p2[7]=p1[7]&p1[5];

assign g2[8]=(p1[8]&g1[6])|g1[8];
assign p2[8]=p1[8]&p1[6];

assign g2[9]=(p1[9]&g1[7])|g1[9];
assign p2[9]=p1[9]&p1[7];

assign g2[10]=(p1[10]&g1[8])|g1[10];
assign p2[10]=p1[10]&p1[8];

assign g2[11]=(p1[11]&g1[9])|g1[11];
assign p2[11]=p1[11]&p1[9];

assign g2[12]=(p1[12]&g1[10])|g1[12];
assign p2[12]=p1[12]&p1[10];

assign g2[13]=(p1[13]&g1[11])|g1[13];
assign p2[13]=p1[13]&p1[11];

assign g2[14]=(p1[14]&g1[12])|g1[14];
assign p2[14]=p1[14]&p1[12];

assign g2[15]=(p1[15]&g1[13])|g1[15];
assign p2[15]=p1[15]&p1[13];

assign g3[0]=g2[0];
assign p3[0]=p2[0];

assign g3[1]=g2[1];
assign p3[1]=p2[1];

assign g3[2]=g2[2];
assign p3[2]=p2[2];

assign g3[3]=g2[3];
assign p3[3]=p2[3];

assign g3[4]=(p2[4]&g2[0])|g2[4];
assign p3[4]=p2[4]&p2[0];

assign g3[5]=(p2[5]&g2[1])|g2[5];
assign p3[5]=p2[5]&p2[1];

assign g3[6]=(p2[6]&g2[2])|g2[6];
assign p3[6]=p2[6]&p2[2];

assign g3[7]=(p2[7]&g2[3])|g2[7];
assign p3[7]=p2[7]&p2[3];

assign g3[8]=(p2[8]&g2[4])|g2[8];
assign p3[8]=p2[8]&p2[4];

assign g3[9]=(p2[9]&g2[5])|g2[9];
assign p3[9]=p2[9]&p2[5];

assign g3[10]=(p2[10]&g2[6])|g2[10];
assign p3[10]=p2[10]&p2[6];

assign g3[11]=(p2[11]&g2[7])|g2[11];
assign p3[11]=p2[11]&p2[7];

assign g3[12]=(p2[12]&g2[8])|g2[12];
assign p3[12]=p2[12]&p2[8];

assign g3[13]=(p2[13]&g2[9])|g2[13];
assign p3[13]=p2[13]&p2[9];

assign g3[14]=(p2[14]&g2[10])|g2[14];
assign p3[14]=p2[14]&p2[10];

assign g3[15]=(p2[15]&g2[11])|g2[15];
assign p3[15]=p2[15]&p2[11];

assign g4[0]=g3[0];
assign p3[0]=p3[0];

assign g4[1]=g3[1];
assign p3[1]=p3[1];

assign g4[2]=g3[2];
assign p3[2]=p3[2];

assign g4[3]=g3[3];
assign p3[3]=p3[3];

assign g4[4]=g3[4];
assign p3[4]=p3[4];

assign g4[5]=g3[5];
assign p4[5]=p3[5];

assign g4[6]=g3[6];
assign p4[6]=p3[6];
        
assign g4[7]=g3[7];
assign p4[7]=p3[7];

assign g4[8]=(p3[8]&g3[0])|g3[8];
assign p4[8]=p3[8]&p3[0];

assign g4[9]=(p3[9]&g3[1])|g3[9];
assign p4[9]=p3[9]&p3[1];

assign g4[10]=(p3[10]&g3[2])|g3[10];
assign p4[10]=p3[10]&p3[2];

assign g4[11]=(p3[11]&g3[3])|g3[11];
assign p4[11]=p3[11]&p3[3];

assign g4[12]=(p3[12]&g3[4])|g3[12];
assign p4[12]=p3[12]&p3[4];

assign g4[13]=(p3[13]&g3[5])|g3[13];
assign p4[13]=p3[13]&p3[5];

assign g4[14]=(p3[14]&g3[6])|g3[14];
assign p4[14]=p3[14]&p3[6];

assign g4[15]=(p3[15]&g3[7])|g3[15];
assign p4[15]=p3[15]&p3[7];


assign c=g4[15];
assign sum[0]=p[0]^cin;
assign sum[1]=p[1]^g[0];
assign sum[2]=p[2]^g1[1];
assign sum[3]=p[3]^g2[2];
assign sum[4]=p[4]^g2[3];
assign sum[5]=p[5]^g3[4];
assign sum[6]=p[6]^g3[5];
assign sum[7]=p[7]^g3[6];
assign sum[8]=p[8]^g3[7];
assign sum[9]=p[9]^g4[8];
assign sum[10]=p[10]^g4[9];
assign sum[11]=p[11]^g4[10];
assign sum[12]=p[12]^g4[11];
assign sum[13]=p[13]^g4[12];
assign sum[14]=p[14]^g4[13];
assign sum[15]=p[15]^g4[14];
assign carryout=c;

endmodule

`default_nettype wire
