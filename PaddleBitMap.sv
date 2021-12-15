
module	PaddleBitMap	(	
					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY,
					input	logic	InsideRectangle, //input that the pixel is within a bracket 

					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout  //rgb value from the bitmap 
					 
 ) ;

// this is the devider used to acess the right pixel 
localparam  int OBJECT_NUMBER_OF_Y_BITS = 4;  // 2^5 = 32 
localparam  int OBJECT_NUMBER_OF_X_BITS = 6;  // 2^6 = 64 


localparam  int OBJECT_HEIGHT_Y = 1 <<  OBJECT_NUMBER_OF_Y_BITS ;
localparam  int OBJECT_WIDTH_X = 1 <<  OBJECT_NUMBER_OF_X_BITS;

// this is the devider used to acess the right pixel 
localparam  int OBJECT_HEIGHT_Y_DIVIDER = OBJECT_NUMBER_OF_Y_BITS - 2; //how many pixel bits are in every collision pixel
localparam  int OBJECT_WIDTH_X_DIVIDER =  OBJECT_NUMBER_OF_X_BITS - 2;

// generating a smiley bitmap

localparam logic [7:0] TRANSPARENT_ENCODING = 8'h11 ;// RGB value in the bitmap representing a transparent pixel 

logic [0:OBJECT_HEIGHT_Y-1] [0:OBJECT_WIDTH_X-1] [7:0] object_colors = {
{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h92, 8'h92, 8'h92, 8'h92, 8'h92, 8'h92, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h92, 8'h92, 8'h92, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h92, 8'h92, 8'h92, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h92, 8'h92, 8'h92, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h92, 8'h92, 8'h92, 8'h92, 8'h92, 8'h92, 8'h92, 8'h11, 8'h11, 8'h11, 8'h11 },
{8'h11, 8'h11, 8'h11, 8'h92, 8'h92, 8'h92, 8'h11, 8'h92, 8'h92, 8'h92, 8'h92, 8'h11, 8'h92, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'h92, 8'h92, 8'h92, 8'h11, 8'h92, 8'hB6, 8'hB6, 8'hB6, 8'h92, 8'h11, 8'h92, 8'h92, 8'h92, 8'hB6, 8'hB6, 8'hB6, 8'h92, 8'h92, 8'h92, 8'h11, 8'h92, 8'hB6, 8'hB6, 8'hB6, 8'h92, 8'h11, 8'h92, 8'h92, 8'h92, 8'h92, 8'h11, 8'h92, 8'h92, 8'h92, 8'hB6, 8'hB6, 8'hB6, 8'h92, 8'hB6, 8'hB6, 8'hB6, 8'h92, 8'h11, 8'h11, 8'h11 },
{8'h11, 8'h11, 8'h92, 8'hB6, 8'hB6, 8'hB6, 8'h92, 8'h92, 8'hB6, 8'hB6, 8'hB6, 8'h92, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'h92, 8'hB6, 8'h92, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'h92, 8'hB6, 8'hB6, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'h92, 8'hB6, 8'h92, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'h92, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'h92, 8'hB6, 8'h92, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h92, 8'hFF, 8'hFF, 8'hB6, 8'h92, 8'h11, 8'h11 },
{8'h11, 8'h92, 8'hB6, 8'hB6, 8'hFF, 8'h92, 8'hB6, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'hFF, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'hFF, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'hFF, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'h92, 8'h11, 8'h11 },
{8'h11, 8'h92, 8'hB6, 8'hFF, 8'h92, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'h92, 8'h11, 8'h11 },
{8'h11, 8'h92, 8'hB6, 8'hFF, 8'h92, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h24, 8'hFF, 8'hFF, 8'h24, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'hB6, 8'h92, 8'h11, 8'h11 },
{8'h11, 8'h11, 8'h92, 8'hB6, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h24, 8'hFF, 8'hFF, 8'h24, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'hFF, 8'h92, 8'h11 },
{8'h11, 8'h11, 8'h92, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h24, 8'hFF, 8'hFF, 8'h24, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h92, 8'h11 },
{8'h11, 8'h11, 8'h92, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h92 },
{8'h11, 8'h11, 8'h92, 8'h92, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hE0, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hE0, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'hFF, 8'hFF, 8'h92 },
{8'h11, 8'h92, 8'hB6, 8'hFF, 8'h92, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'hFF, 8'hFF, 8'hE0, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hE0, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'hB6, 8'hFF, 8'hFF, 8'h92 },
{8'h11, 8'h92, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'hFF, 8'hFF, 8'hB6, 8'hFF, 8'hFF, 8'hB6, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'hB6, 8'hFF, 8'hFF, 8'hB6, 8'hFF, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hFF, 8'hFF, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'hB6, 8'hFF, 8'hFF, 8'hB6, 8'hFF, 8'hFF, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'hB6, 8'hFF, 8'hFF, 8'hB6, 8'h92 },
{8'h11, 8'h92, 8'hB6, 8'hB6, 8'hFF, 8'hB6, 8'hFF, 8'hFF, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'hFF, 8'hB6, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'hFF, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'hFF, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'hB6, 8'hB6, 8'h92, 8'hFF, 8'hB6, 8'h92, 8'h11 },
{8'h11, 8'h11, 8'h92, 8'hB6, 8'hB6, 8'hFF, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'h92, 8'hB6, 8'hB6, 8'hB6, 8'h92, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'h92, 8'hB6, 8'hB6, 8'hB6, 8'h92, 8'hB6, 8'hB6, 8'hB6, 8'h92, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'h92, 8'hB6, 8'hB6, 8'hB6, 8'h92, 8'hB6, 8'hB6, 8'hB6, 8'h92, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'h92, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'h92, 8'h92, 8'hB6, 8'hB6, 8'hB6, 8'h92, 8'h11 },
{8'h11, 8'h11, 8'h11, 8'h92, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'h92, 8'h92, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'h92, 8'h92, 8'h92, 8'h92, 8'h92, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'h92, 8'h92, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'h92, 8'h92, 8'h92, 8'h92, 8'h92, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'h92, 8'h92, 8'hB6, 8'hB6, 8'h92, 8'h92, 8'h92, 8'h92, 8'h92, 8'hB6, 8'hB6, 8'hB6, 8'h92, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'h92, 8'h11, 8'h11 },
{8'h11, 8'h11, 8'h11, 8'h11, 8'h92, 8'h92, 8'h92, 8'h92, 8'h92, 8'h92, 8'h11, 8'h11, 8'h92, 8'h92, 8'h92, 8'h92, 8'h92, 8'h92, 8'h92, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h92, 8'h92, 8'h92, 8'h92, 8'h11, 8'h11, 8'h92, 8'h92, 8'h92, 8'h92, 8'h92, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h92, 8'h92, 8'h92, 8'h92, 8'h11, 8'h11, 8'h92, 8'h92, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h92, 8'h92, 8'h92, 8'h11, 8'h92, 8'h92, 8'h92, 8'h92, 8'h11, 8'h11, 8'h11 }
};
//////////--------------------------------------------------------------------------------------------------------------=
//hit bit map has one bit per edge:  hit_colors[3:0] =   {Left, Top, Right, Bottom}	
//there is one bit per edge, in the corner two bits are set  


logic [0:3] [0:3] [3:0] hit_colors = 
		  {16'hC446,     
			16'h8C62,    
			16'h8932,
			16'h9113};

 

// pipeline (ff) to get the pixel color from the array 	 

//////////--------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout <=	8'h00;
	
	end

	else begin
		RGBout <= TRANSPARENT_ENCODING ; // default  
		if (InsideRectangle == 1'b1 ) 
		begin // inside an external bracket  
			RGBout <= object_colors[offsetY][offsetX];
		end  	
	end
		
end

//////////--------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 
assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   

endmodule