module SEDE (input clk,
	     input rst,
	     input [7:0] pix_data,
	     output reg  valid, 
	     output reg[7:0] edge_out,
	     output reg busy );
	parameter x0 = 1, x1 = 0, x2 = -1;
	parameter x3 = 2, x4 = 0, x5 = -2;
	parameter x6 = 1, x7 = 0, x8 = -1;
	
	parameter y0 = 1, y1 = 2, y2 = 1;
	parameter y3 = 0, y4 = 0, y5 = 0;
	parameter y6 = -1, y7 = -2, y8 = -1;
	
	integer i;
	reg signed[11:0]sum_gx;
	reg signed[11:0]sum_gy;
	reg signed[12:0]sobel;
	
	reg [11:0]count_in;
	reg [11:0]count_out;
	
	reg [7:0]line0[0:31];
	reg [7:0]line1[0:31];
	reg [7:0]line2[0:31];
	
	wire [7:0]line0_out;
	wire [7:0]line1_out;
	wire [7:0]line2_out;
	
	reg [7:0]line0_data[0:2];
	reg [7:0]line1_data[0:2];
	reg [7:0]line2_data[0:2];
	
	always@(posedge clk or posedge rst)begin
		if(rst)
			count_out <= 0;
	 	else if(count_in >= 67)
	 		count_out = count_out + 1;
	 	else
	 		count_out = count_out;
	 end
	
	always@(posedge clk or posedge rst)begin
		if(rst)begin
			valid <= 0;
			edge_out <= 0;
		end
		else if(count_in >= 67)begin
			valid <= 1; 
			edge_out <= sobel;
		end
		else begin
			valid <= 0; 
			edge_out <= 0;
		end
	end
	
	always@(*)begin
			sum_gx = line0_data[0]*x8 + line0_data[1]*x7 + line0_data[2]*x6 +
					 line1_data[0]*x5 + line1_data[1]*x4 + line1_data[2]*x3 +
					 line2_data[0]*x2 + line2_data[1]*x1 + line2_data[2]*x0;
					 
			sum_gy = line0_data[0]*y8 + line0_data[1]*y7 + line0_data[2]*y6 +
					 line1_data[0]*y5 + line1_data[1]*y4 + line1_data[2]*y3 +
					 line2_data[0]*y2 + line2_data[1]*y1 + line2_data[2]*y0;
					 
			sobel = sum_gx + sum_gy;
			if(sobel < 0 || (count_out%32 ==0) || (count_out%32 == 31) || (count_out/32 == 31) || (count_out/32 == 0))
				sobel = 0;
			else
				sobel = (sobel/2 > 255) ? 8'hff : (sobel/2);
	end
	
	always@(posedge clk or posedge rst)begin
		if(rst)begin
			for(i = 0; i <= 2; i = i + 1)begin
				line0_data[i] <= 0;
				line1_data[i] <= 0;
				line2_data[i] <= 0;
			end
		end
		else begin
			line0_data[0] <= line0_out;
			line1_data[0] <= line1_out;
			line2_data[0] <= line2_out;
			for(i = 1; i <= 2; i = i + 1)begin
				line0_data[i] <= line0_data[i-1];
				line1_data[i] <= line1_data[i-1];
				line2_data[i] <= line2_data[i-1];
			end
		end
	end

	always@(posedge clk or posedge rst)begin
		if(rst)begin
			for(i = 0; i <= 31; i = i + 1)
				line0[i] <= 0;
		end
		else begin
			if(count_in == 0)
				line0[0] = 0;
			else if(count_in == 1)
				line0[0] <= pix_data;
			else begin
				line0[0] <= pix_data;
				for(i = 1; i <= 31; i = i + 1)
					line0[i] <= line0[i-1];
			end
		end
	end
	assign line0_out = line0[31];
	
	always@(posedge clk or posedge rst)begin
		if(rst)begin
			for(i = 0; i <= 31; i = i + 1)
				line1[i] <= 0;
		end
		else begin
				line1[0] <= line0[31];
				for(i = 1; i <= 31; i = i + 1)
					line1[i] <= line1[i-1];
			
		end
	end
	assign line1_out = line1[31];
	
	always@(posedge clk or posedge rst)begin
		if(rst)begin
			for(i = 0; i <= 31; i = i + 1)
				line2[i] <= 0;
		end
		else begin
				line2[0] <= line1[31];
				for(i = 1; i <= 31; i = i + 1)
					line2[i] <= line2[i-1];
			
		end
	end
	assign line2_out = line2[31];
	
	always@(posedge clk or posedge rst)begin
		if(rst)
			busy <= 0;
		else if(count_in >= 1024)
			busy <= 1;
		else 
			busy <= 0;
	end
	
	always@(posedge clk or posedge rst)begin
		if(rst)
			count_in <= 0;
		else if(~busy)
			count_in <= count_in + 1;
		else
			count_in <= count_in;
	end
	
endmodule
