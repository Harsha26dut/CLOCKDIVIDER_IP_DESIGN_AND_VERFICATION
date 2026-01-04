// Code your design here
module clk_gen(
input clk, rst,
input [16:0] baud,
output tx_clk
);
  
// Localparam for system clock frequency in Hz
localparam SYS_CLK_FREQ = 100_000_000; // 50 MHz default, can be changed
localparam SLOWEST_BAUD = 4800;
 
localparam CLKS_PER_SLOWEST_BAUD = SYS_CLK_FREQ / SLOWEST_BAUD;
localparam WAIT = CLKS_PER_SLOWEST_BAUD*3;
localparam real SYS_CLK_PERIOD = 1_000_000_000.0 / SYS_CLK_FREQ;
  
reg  t_clk = 0;
int  tx_max = 0;
int  tx_count = 0;

//////////////////////////////////////////////
// Calculate tx_max based on baud rate
// Formula: tx_max = SYS_CLK_FREQ / baud_rate
//////////////////////////////////////////////

always@(posedge clk) begin
    if(rst) begin
        tx_max <= 0;	
    end
    else begin 		
        case(baud)
            4800 :  begin
              tx_max <= SYS_CLK_FREQ /(16 * 4800);  // 651 for 50MHz
                    end
            9600  : begin
              tx_max <= SYS_CLK_FREQ /(16 * 9600);  // 325 for 50MHz
                    end
            14400 : begin 
              tx_max <= SYS_CLK_FREQ / (16*14400); // 217 for 50MHz
                    end
            19200 : begin 
              tx_max <= SYS_CLK_FREQ / (16*19200); // 163 for 50MHz
                    end
            38400: begin
              tx_max <= SYS_CLK_FREQ / (16*38400); // 81 for 50MHz
                    end
            57600 : begin 
              tx_max <= SYS_CLK_FREQ / (16*57600); // 54 for 50MHz
                    end 						
            default: begin 
              tx_max <= SYS_CLK_FREQ / (16*9600);  // Default 9600 baud
                    end
        endcase
    end
end

///////////////////////////////////////////
// Generate tx_clk by toggling at tx_max/2
///////////////////////////////////////////

always@(posedge clk) begin
    if(rst) begin
        tx_count <= 0;
        t_clk    <= 0;
    end
    else begin
        if(tx_count < tx_max/2) begin
            tx_count <= tx_count + 1;
        end
        else begin
            t_clk   <= ~t_clk;
            tx_count <= 0;
        end
    end
end

/////////////////////////////////////////////////////
assign tx_clk = t_clk;
endmodule

////////////////////////////////////////////////////////////////////////
// Interface for clk_gen module
////////////////////////////////////////////////////////////////////////

interface clk_if;
    logic clk, rst;
    logic [16:0] baud;
    logic tx_clk;
endinterface