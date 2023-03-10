`ifndef _FONECYCLE_V_
`define _FONECYCLE_V_
`include "./params.vh"

module fonecycle(
	input [EXPWIDTH + SIGWIDTH - 1 : 0] frs1,
	input [EXPWIDTH + SIGWIDTH - 1 : 0] frs2,
	input [EXPWIDTH + SIGWIDTH - 1 : 0] frs3,
	input [31 : 0] short_rs,
	input [63 : 0] long_rs,
	input [4 : 0] ftype,
	input fcontrol,
	input [2 : 0] roundingMode,
	output reg [EXPWIDTH + SIGWIDTH - 1 : 0] farithematic_res,
	output reg [31 : 0] w_convert_res,
	output reg [63 : 0] l_convert_res,
	output reg [XLEN - 1 : 0] mv_integer_res,
	output reg fcompare_res,
	output reg [XLEN - 1 : 0] fclass_res,
	output reg [4 : 0] exception_flags
);

/* Used to hold the rec format of input */
wire [EXPWIDTH + SIGWIDTH : 0] rec_frs1;
wire [EXPWIDTH + SIGWIDTH : 0] rec_frs2;
wire [EXPWIDTH + SIGWIDTH : 0] rec_frs3;



/* Convert IEEE754 to rec format */
fNToRecFN#(
	.expWidth(EXPWIDTH),
	.sigWidth(SIGWIDTH)
) fn2recfn_frs1(
	.in(frs1),
	.out(rec_frs1)
);

fNToRecFN#(
	.expWidth(EXPWIDTH),
	.sigWidth(SIGWIDTH)
) fn2recfn_frs2(
	.in(frs2),
	.out(rec_frs2)
);

fNToRecFN#(
	.expWidth(EXPWIDTH),
	.sigWidth(SIGWIDTH)
) fn2recfn_frs3(
	.in(frs3),
	.out(rec_frs3)
);

/* Used to store rec format result */
wire [EXPWIDTH + SIGWIDTH : 0] rec_add_res;
wire [EXPWIDTH + SIGWIDTH : 0] rec_sub_res;
wire [EXPWIDTH + SIGWIDTH : 0] rec_mul_res;
wire [EXPWIDTH + SIGWIDTH : 0] rec_fmadd_res;
wire [EXPWIDTH + SIGWIDTH : 0] rec_fnmadd_res;
wire [EXPWIDTH + SIGWIDTH : 0] rec_fmsub_res;
wire [EXPWIDTH + SIGWIDTH : 0] rec_fnmsub_res;
wire [EXPWIDTH + SIGWIDTH : 0] rec_fcvtsw_res;
wire [EXPWIDTH + SIGWIDTH : 0] rec_fcvtswu_res;
wire [EXPWIDTH + SIGWIDTH : 0] rec_fcvtsl_res;
wire [EXPWIDTH + SIGWIDTH : 0] rec_fcvtslu_res;

wire [31 : 0] fcvtws_res;
wire [31 : 0] fcvtwus_res;
wire [63 : 0] fcvtls_res;
wire [63 : 0] fcvtlus_res;

/* used to store exception from different modules */
wire [4 : 0] add_exception_flags;
wire [4 : 0] sub_exception_flags;
wire [4 : 0] mul_exception_flags;
wire [4 : 0] minmax_exception_flags;
wire [4 : 0] fmadd_exception_flags;
wire [4 : 0] fnmadd_exception_flags;
wire [4 : 0] fmsub_exception_flags;
wire [4 : 0] fnmsub_exception_flags;
wire [2 : 0] fcvtws_exception_flags;
wire [2 : 0] fcvtwus_exception_flags;
wire [2 : 0] fcvtls_exception_flags;
wire [2 : 0] fcvtlus_exception_flags;
wire [4 : 0] fcvtsw_exception_flags;
wire [4 : 0] fcvtswu_exception_flags;
wire [4 : 0] fcvtsw_exception_flags;
wire [4 : 0] fcvtswu_exception_flags;
wire [4 : 0] fcvtsl_exception_flags;
wire [4 : 0] fcvtslu_exception_flags;
wire [4 : 0] ltgt_exception_flags;


/* floating point add */
addRecFN#(
	.expWidth(EXPWIDTH),
	.sigWidth(SIGWIDTH)
) fadder(
	.control(fcontrol),
	.subOp(1'b0),
	.a(rec_frs1),
	.b(rec_frs2),
	.roundingMode(roundingMode),
	.out(rec_add_res),
	.exceptionFlags(add_exception_flags)
);

/* floating point sub */
addRecFN#(
	.expWidth(EXPWIDTH),
	.sigWidth(SIGWIDTH)
) fsuber(
	.control(fcontrol),
	.subOp(1'b1),
	.a(rec_frs1),
	.b(rec_frs2),
	.roundingMode(roundingMode),
	.out(rec_sub_res),
	.exceptionFlags(sub_exception_flags)
);

/* floating point mul */
mulRecFN#(
	.expWidth(EXPWIDTH),
	.sigWidth(SIGWIDTH)
) fmuler(
	.control(fcontrol),
	.a(rec_frs1),
	.b(rec_frs2),
	.roundingMode(roundingMode),
	.out(rec_mul_res),
	.exceptionFlags(mul_exception_flags)
);

/* floating point fused multiply add */
mulAddRecFN#(
	.expWidth(EXPWIDTH),
	.sigWidth(SIGWIDTH)
) fmadder(
	.control(fcontrol),
	.op(2'b00),
	.a(rec_frs1),
	.b(rec_frs2),
	.c(rec_frs3),
	.roundingMode(roundingMode),
	.out(rec_fmadd_res),
	.exceptionFlags(fmadd_exception_flags)
);

/* floating point fused negative multiply add */
mulAddRecFN#(
	.expWidth(EXPWIDTH),
	.sigWidth(SIGWIDTH)
) fnmadder(
	.control(fcontrol),
	.op(2'b11),
	.a(rec_frs1),
	.b(rec_frs2),
	.c(rec_frs3),
	.roundingMode(roundingMode),
	.out(rec_fnmadd_res),
	.exceptionFlags(fnmadd_exception_flags)
);

/* floating point fused multiply sub */
mulAddRecFN#(
	.expWidth(EXPWIDTH),
	.sigWidth(SIGWIDTH)
) fmsuber(
	.control(fcontrol),
	.op(2'b01),
	.a(rec_frs1),
	.b(rec_frs2),
	.c(rec_frs3),
	.roundingMode(roundingMode),
	.out(rec_fmsub_res),
	.exceptionFlags(fmsub_exception_flags)
);

/* floating point fused negative multiply sub */
mulAddRecFN#(
	.expWidth(EXPWIDTH),
	.sigWidth(SIGWIDTH)
) fnmsuber(
	.control(fcontrol),
	.op(2'b10),
	.a(rec_frs1),
	.b(rec_frs2),
	.c(rec_frs3),
	.roundingMode(roundingMode),
	.out(rec_fnmsub_res),
	.exceptionFlags(fnmsub_exception_flags)
);

/* Convert float to 32 signed */
recFNToIN#(
	.expWidth(EXPWIDTH),
	.sigWidth(SIGWIDTH),
	.intWidth(32)
) fcvtws(
	.control(fcontrol),
	.in(rec_frs1),
	.roundingMode(roundingMode),
	.signedOut(1'b1),
	.out(fcvtws_res),
	.intExceptionFlags(fcvtws_exception_flags)
);

/* Convert float to 32 unsigned */
recFNToIN#(
	.expWidth(EXPWIDTH),
	.sigWidth(SIGWIDTH),
	.intWidth(32)
) fcvtwus(
	.control(fcontrol),
	.in(rec_frs1),
	.roundingMode(roundingMode),
	.signedOut(1'b0),
	.out(fcvtwus_res),
	.intExceptionFlags(fcvtwus_exception_flags)
);

/* Convert float to 64 signed */
recFNToIN#(
	.expWidth(EXPWIDTH),
	.sigWidth(SIGWIDTH),
	.intWidth(64)
) fcvtls(
	.control(fcontrol),
	.in(rec_frs1),
	.roundingMode(roundingMode),
	.signedOut(1'b1),
	.out(fcvtls_res),
	.intExceptionFlags(fcvtls_exception_flags)
);
/* Convert float to 64 unsigned */
recFNToIN#(
	.expWidth(EXPWIDTH),
	.sigWidth(SIGWIDTH),
	.intWidth(64)
) fcvtlus(
	.control(fcontrol),
	.in(rec_frs1),
	.roundingMode(roundingMode),
	.signedOut(1'b0),
	.out(fcvtlus_res),
	.intExceptionFlags(fcvtlus_exception_flags)
);

/* Convert 32bit signed integer to single float */
iNToRecFN#(
	.intWidth(32),
	.expWidth(EXPWIDTH),
	.sigWidth(SIGWIDTH)
) fcvtsw(
	.control(fcontrol),
	.signedIn(1'b1),
	.in(short_rs),
	.roundingMode(roundingMode),
	.out(rec_fcvtsw_res),
	.exceptionFlags(fcvtsw_exception_flags)
);

/* Convert 32bit unsigned integer to single float */
iNToRecFN#(
	.intWidth(32),
	.expWidth(EXPWIDTH),
	.sigWidth(SIGWIDTH)
) fcvtswu(
	.control(fcontrol),
	.signedIn(1'b0),
	.in(short_rs),
	.roundingMode(roundingMode),
	.out(rec_fcvtswu_res),
	.exceptionFlags(fcvtswu_exception_flags)
);

/* Convert 64bit signed integer to single float */
iNToRecFN#(
	.intWidth(64),
	.expWidth(EXPWIDTH),
	.sigWidth(SIGWIDTH)
) fcvtsl(
	.control(fcontrol),
	.signedIn(1'b1),
	.in(long_rs),
	.roundingMode(roundingMode),
	.out(rec_fcvtsl_res),
	.exceptionFlags(fcvtsl_exception_flags)
);

/* Convert 64bit unsigned integer to single float */
iNToRecFN#(
	.intWidth(64),
	.expWidth(EXPWIDTH),
	.sigWidth(SIGWIDTH)
) fcvtslu(
	.control(fcontrol),
	.signedIn(1'b0),
	.in(long_rs),
	.roundingMode(roundingMode),
	.out(rec_fcvtslu_res),
	.exceptionFlags(fcvtslu_exception_flags)
);
/* variables to accept the result of fmin/fmax */
wire eq, lt, gt, unordered;
wire waste_eq, waste_lt, waste_gt, waste_unordered;

/* floating point min */
compareRecFN#(
	.expWidth(EXPWIDTH),
	.sigWidth(SIGWIDTH)
) fminmaxer(
	.a(rec_frs1),
	.b(rec_frs2),
	.signaling(1'b0),
	.lt(waste_lt),
	.eq(eq),
	.gt(waste_gt),
	.unordered(unordered),
	.exceptionFlags(minmax_exception_flags)
);

compareRecFN#(
	.expWidth(EXPWIDTH),
	.sigWidth(SIGWIDTH)
) fltgter (
	.a(rec_frs1),
	.b(rec_frs2),
	.signaling(1'b1),
	.lt(lt),
	.eq(waste_eq),
	.gt(gt),
	.unordered(waste_unordered),
	.exceptionFlags(ltgt_exception_flags)
);
wire [XLEN - 1 : 0] rec_fclass_res; 
/* fclass */
fclassifier fclass(
	.frs(frs1),
	.class_res(rec_fclass_res)
);


/* Used to store IEEE754 format res */
wire [EXPWIDTH + SIGWIDTH - 1 : 0] add_res;
wire [EXPWIDTH + SIGWIDTH - 1 : 0] sub_res;
wire [EXPWIDTH + SIGWIDTH - 1 : 0] mul_res;
wire [EXPWIDTH + SIGWIDTH - 1 : 0] fmadd_res;
wire [EXPWIDTH + SIGWIDTH - 1 : 0] fnmadd_res;
wire [EXPWIDTH + SIGWIDTH - 1 : 0] fmsub_res;
wire [EXPWIDTH + SIGWIDTH - 1 : 0] fnmsub_res;
wire [EXPWIDTH + SIGWIDTH - 1 : 0] fcvtsw_res;
wire [EXPWIDTH + SIGWIDTH - 1 : 0] fcvtswu_res;
wire [EXPWIDTH + SIGWIDTH - 1 : 0] fcvtsl_res;
wire [EXPWIDTH + SIGWIDTH - 1 : 0] fcvtslu_res;

/* Convert rec format to IEEE754 format */
recFNToFN#(
	.expWidth(EXPWIDTH),
	.sigWidth(SIGWIDTH)
) rec2fn_add(
	.in(rec_add_res),
	.out(add_res)
);

recFNToFN#(
	.expWidth(EXPWIDTH),
	.sigWidth(SIGWIDTH)
) rec2fn_sub(
	.in(rec_sub_res),
	.out(sub_res)
);

recFNToFN#(
	.expWidth(EXPWIDTH),
	.sigWidth(SIGWIDTH)
) rec2fn_mul(
	.in(rec_mul_res),
	.out(mul_res)
);

recFNToFN#(
	.expWidth(EXPWIDTH),
	.sigWidth(SIGWIDTH)
) rec2fn_fmadd(
	.in(rec_fmadd_res),
	.out(fmadd_res)
);

recFNToFN#(
	.expWidth(EXPWIDTH),
	.sigWidth(SIGWIDTH)
) rec2fn_fnmadd(
	.in(rec_fnmadd_res),
	.out(fnmadd_res)
);

recFNToFN#(
	.expWidth(EXPWIDTH),
	.sigWidth(SIGWIDTH)
) rec2fn_fmsub(
	.in(rec_fmsub_res),
	.out(fmsub_res)
);

recFNToFN#(
	.expWidth(EXPWIDTH),
	.sigWidth(SIGWIDTH)
) rec2fn_fnmsub(
	.in(rec_fnmsub_res),
	.out(fnmsub_res)
);
recFNToFN#(
	.expWidth(EXPWIDTH),
	.sigWidth(SIGWIDTH)
) rec2fn_fcvtsw(
	.in(rec_fcvtsw_res),
	.out(fcvtsw_res)
);
recFNToFN#(
	.expWidth(EXPWIDTH),
	.sigWidth(SIGWIDTH)
) rec2fn_fcvtswu(
	.in(rec_fcvtswu_res),
	.out(fcvtswu_res)
);
recFNToFN#(
	.expWidth(EXPWIDTH),
	.sigWidth(SIGWIDTH)
) rec2fn_fcvtsl(
	.in(rec_fcvtsl_res),
	.out(fcvtsl_res)
);
recFNToFN#(
	.expWidth(EXPWIDTH),
	.sigWidth(SIGWIDTH)
) rec2fn_fcvtslu(
	.in(rec_fcvtslu_res),
	.out(fcvtslu_res)
);

/* Assign the output reg according to type */
always @ (*) begin
	case(ftype)
		/* fadd.s frd, frs1, frs2 */
		5'd0: begin
			farithematic_res = add_res;
			fcompare_res = 0;
			fclass_res = 0;
			w_convert_res = 0;
			l_convert_res = 0;
			exception_flags = add_exception_flags;
			mv_integer_res = 0;
		end
		/* fsub.s frd, frs1, frs2 */
		5'd1: begin
			farithematic_res = sub_res;
			fcompare_res = 0;
			fclass_res = 0;
			w_convert_res = 0;
			l_convert_res = 0;
			exception_flags = sub_exception_flags;
			mv_integer_res = 0;
			
		end
		/* fmul.s frd, frs1, frs2 */
		5'd2: begin
			farithematic_res = mul_res;
			fcompare_res = 0;
			fclass_res = 0;
			w_convert_res = 0;
			l_convert_res = 0;
			exception_flags = mul_exception_flags;
			mv_integer_res = 0;
		end
		/* fmin.s frd, frs1, frs2 */
		5'd3: begin
			if ((frs1 == 32'h80000000 && frs2 == 32'h00000000) || (frs1 == 32'h00000000 && frs2 == 32'h80000000)) begin
				farithematic_res = 32'h80000000;	
			end
			else begin
				farithematic_res = lt ? frs1 : frs2;
			end
			fcompare_res = 0;
			fclass_res = 0;
			w_convert_res = 0;
			l_convert_res = 0;
			exception_flags = minmax_exception_flags;
			mv_integer_res = 0;
		end
		/* fmax.s frd, frs1, frs2 */
		5'd4: begin
			if ((frs1 == 32'h80000000 && frs2 == 32'h00000000) || (frs1 == 32'h00000000 && frs2 == 32'h80000000)) begin
				farithematic_res = 32'h00000000;	
			end
			else begin
				farithematic_res = gt ? frs1 : frs2;
			end
			fcompare_res = 0;
			fclass_res = 0;
			w_convert_res = 0;
			l_convert_res = 0;
			exception_flags = minmax_exception_flags;
			mv_integer_res = 0;
		end
		/* fmadd.s frd, frs1, frs2, frs3 */
		5'd5: begin
			farithematic_res = fmadd_res;
			fcompare_res = 0;
			fclass_res = 0;
			w_convert_res = 0;
			l_convert_res = 0;
			exception_flags = fmadd_exception_flags;
			mv_integer_res = 0;
		end
		/* fnmadd.s frd, frs1, frs2, frs3 */
		5'd6: begin
			farithematic_res = fnmadd_res;
			fcompare_res = 0;
			fclass_res = 0;
			w_convert_res = 0;
			l_convert_res = 0;
			exception_flags = fnmadd_exception_flags;
			mv_integer_res = 0;
		end
		/* fmsub.s frd, frs1, frs2, frs3 */
		5'd7: begin
			farithematic_res = fmsub_res;
			fcompare_res = 0;
			fclass_res = 0;
			w_convert_res = 0;
			l_convert_res = 0;
			exception_flags = fmsub_exception_flags;
			mv_integer_res = 0;
		end
		/* fnmsub.s frd, frs1, frs2, frs3 */
		5'd8: begin
			farithematic_res = fnmsub_res;
			fcompare_res = 0;
			fclass_res = 0;
			w_convert_res = 0;
			l_convert_res = 0;
			exception_flags = fnmsub_exception_flags;
			mv_integer_res = 0;
		end
		/* fcvt.w.s rd, frs1 */
		5'd9: begin
			farithematic_res = 0;
			fcompare_res = 0;
			fclass_res = 0;
			w_convert_res = fcvtws_res;
			l_convert_res = 0;
			exception_flags = {fcvtws_exception_flags[2] | fcvtws_exception_flags[1], 1'b0, 1'b0, 1'b0, fcvtws_exception_flags[0]};
			mv_integer_res = 0;
		end
		/* fcvt.wu.s rd, frs1 */
		5'd10: begin
			farithematic_res = 0;
			fcompare_res = 0;
			fclass_res = 0;
			w_convert_res = fcvtwus_res;
			l_convert_res = 0;
			exception_flags = {fcvtwus_exception_flags[2] | fcvtwus_exception_flags[1], 1'b0, 1'b0, 1'b0, fcvtwus_exception_flags[0]};
			mv_integer_res = 0;
		end
		/* fcvt.l.s rd, frs1 */
		5'd11: begin
			farithematic_res = 0;
			fcompare_res = 0;
			fclass_res = 0;
			w_convert_res = 0;
			l_convert_res = fcvtls_res;
			exception_flags = {fcvtls_exception_flags[2] | fcvtls_exception_flags[1], 1'b0, 1'b0, 1'b0, fcvtls_exception_flags[0]};
			mv_integer_res = 0;
		end
		/* fcvt.lu.s rd, frs1 */
		5'd12: begin
			farithematic_res = 0;
			fcompare_res = 0;
			fclass_res = 0;
			w_convert_res = 0;
			l_convert_res = fcvtlus_res;
			exception_flags = {fcvtlus_exception_flags[2] | fcvtlus_exception_flags[1], 1'b0, 1'b0, 1'b0, fcvtlus_exception_flags[0]};
			mv_integer_res = 0;
		end
		/* fcvt.s.w frd, rs1 */
		5'd13: begin
			farithematic_res = fcvtsw_res;
			fcompare_res = 0;
			fclass_res = 0;
			w_convert_res = 0;
			l_convert_res = 0;
			exception_flags = fcvtsw_exception_flags;
			mv_integer_res = 0;
		end
		/* fcvt.s.wu frd, rs1 */
		5'd14: begin
			farithematic_res = fcvtswu_res;
			fcompare_res = 0;
			fclass_res = 0;
			w_convert_res = 0;
			l_convert_res = 0;
			exception_flags = fcvtswu_exception_flags;
			mv_integer_res = 0;
		end
		/* fcvt.s.l frd, rs1 */
		5'd15: begin
			farithematic_res = fcvtsl_res;
			fcompare_res = 0;
			fclass_res = 0;
			w_convert_res = 0;
			l_convert_res = 0;
			exception_flags = fcvtsl_exception_flags;
			mv_integer_res = 0;
		end
		/* fcvt.s.lu frd, rs1 */
		5'd16: begin
			farithematic_res = fcvtslu_res;
			fcompare_res = 0;
			fclass_res = 0;
			w_convert_res = 0;
			l_convert_res = 0;
			exception_flags = fcvtslu_exception_flags;
			mv_integer_res = 0;
		end
		/* fsgnj.s frd, frs1, frs2 */
		5'd17: begin
			farithematic_res = { frs2[FLEN - 1], frs1[FLEN - 2 : 0] };
			fcompare_res = 0;
			fclass_res = 0;
			w_convert_res = 0;
			l_convert_res = 0;
			exception_flags = 5'b0;
			mv_integer_res = 0;
		end
		/* fsgnjn.s frd, frs1, frs2 */
		5'd18: begin
			farithematic_res = { ~frs2[FLEN - 1], frs1[FLEN - 2 : 0] };
			fcompare_res = 0;
			fclass_res = 0;
			w_convert_res = 0;
			l_convert_res = 0;
			exception_flags = 5'b0;
			mv_integer_res = 0;
		end
		/* fsgnjx.s frd, frs1, frs2 */
		5'd19: begin
			farithematic_res = { frs1[FLEN - 1] ^ frs2[FLEN - 1], frs1[FLEN - 2 : 0] };
			fcompare_res = 0;
			fclass_res = 0;
			w_convert_res = 0;
			l_convert_res = 0;
			exception_flags = 5'b0;
			mv_integer_res = 0;
		end
		/* feq.s rd, frs1, frs2 */
		5'd20: begin
			farithematic_res = 0;
			fcompare_res = eq;
			fclass_res = 0;
			w_convert_res = 0;
			l_convert_res = 0;
			exception_flags = minmax_exception_flags;
			mv_integer_res = 0;
		end
		/* flt.s rd, frs1, frs2 */
		5'd21: begin
			farithematic_res = 0;
			fcompare_res = lt;
			fclass_res = 0;
			w_convert_res = 0;
			l_convert_res = 0;
			exception_flags = ltgt_exception_flags;
			mv_integer_res = 0;
		end
		/* fle.s rd, frs1, frs2 */
		5'd22: begin
			farithematic_res = 0;
			fcompare_res = lt | eq;
			fclass_res = 0;
			w_convert_res = 0;
			l_convert_res = 0;
			exception_flags = ltgt_exception_flags;
			mv_integer_res = 0;
		end
		/* fclass frs */
		5'd23: begin
			farithematic_res = 0;
			fcompare_res = 0;
			fclass_res = rec_fclass_res;
			w_convert_res = 0;
			l_convert_res = 0;
			exception_flags = 5'b0;
			mv_integer_res = 0;
		end
		/* fmv.w.x frd, rs */
		5'd24: begin
			farithematic_res = short_rs;
			fcompare_res = 0;
			fclass_res = 0;
			w_convert_res = 0;
			l_convert_res = 0;
			exception_flags = 5'b0;
			mv_integer_res = 0;
		end
		/* fmv.x.w rd, frs */
		5'd25: begin
			farithematic_res = 0;
			fcompare_res = 0;
			fclass_res = 0;
			w_convert_res = 0;
			l_convert_res = 0;
			exception_flags = 5'b0;
			mv_integer_res = frs1;
		end
		default: begin
			farithematic_res = 0;
			fcompare_res = 0;
			fclass_res = 0;
			w_convert_res = 0;
			l_convert_res = 0;
			exception_flags = 5'b0;
			mv_integer_res = 0;
		end
	endcase
end

endmodule

`endif // _FONECYCLE_V_
