
module	TilesMatrixBitMap	(	
					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY,
					input	logic	InsideRectangle, //input that the pixel is within a bracket 
					input logic [10:0] pixelX,
					input logic [10:0] pixelY,
					input logic [10:0] MatTopX,
					input logic [10:0] MatTopY,
					input logic collision,
					
					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output   logic [3:0] Bricks,
					output   logic win,
					output	logic	[7:0] RGBout  //rgb value from the bitmap 
					
 ) ;
 

// Size represented as Number of X and Y bits 
localparam logic [7:0] TRANSPARENT_ENCODING = 8'h11 ;// RGB value in the bitmap representing a transparent pixel 
 /*  end generated by the tool */
// the screen is 640*480  or  20 * 15 squares of 32*32  bits ,  we wiil round up to 32*16 and use only the top left 20*15 pixels  
// this is the bitmap  of the maze , if there is a one  the na whole 32*32 rectange will be drawn on the screen 
// all numbers here are hard coded to simplify the  understanding 
 
int tiles = 20;


logic [0:15] [0:15]  turtle_BitmapMask= 
{16'b	0000000000000000,
16'b	0000010101010100,
16'b	0000010101010100,
16'b	0000010101010100,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000};

logic [0:15] [0:15]  boxBitMapmask= 
{16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000001010000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000};

logic [0:15] [0:15]  showingFace_BitmapMask= 
{16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000001010100000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000};

logic [0:15] [0:15]  hidingFace_BitmapMask= 
{16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000,
16'b	0000000000000000};
 
 logic [0:3] [0:31] [0:31] [7:0]  object_colors  = {
//TURTLE WITH WINGs
	{{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h68, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'hA8, 8'hA8, 8'hA8, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'hA8, 8'hFF, 8'hA8, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h88, 8'hFF, 8'hFF, 8'hFF, 8'hA8, 8'h11, 8'h11, 8'h11, 8'h11, 8'hA8, 8'hFF, 8'hFF, 8'hFF, 8'hA8, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'hA8, 8'hF1, 8'hFF, 8'hFF, 8'hFF, 8'hA8, 8'h11, 8'h11, 8'h11, 8'hA8, 8'hFF, 8'hFF, 8'hFF, 8'hA8, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'hA8, 8'hF1, 8'hF1, 8'hFF, 8'hFF, 8'hA8, 8'h11, 8'h11, 8'h11, 8'hA8, 8'hFF, 8'hFF, 8'h24, 8'hF1, 8'hA8, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'hA8, 8'hF1, 8'hF1, 8'hFF, 8'hFF, 8'hA8, 8'h11, 8'hA8, 8'hA8, 8'hFF, 8'hFF, 8'h24, 8'hF1, 8'hA8, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'hA8, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hA8, 8'h11, 8'hA8, 8'hA8, 8'hFF, 8'hFF, 8'hFF, 8'hF1, 8'hA8, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'hA8, 8'hF1, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hA8, 8'hA8, 8'hF1, 8'hA8, 8'hFF, 8'hA8, 8'hF1, 8'h24, 8'hA8, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'hA8, 8'hF1, 8'hF1, 8'hFF, 8'hFF, 8'hFF, 8'hA8, 8'hA8, 8'hF1, 8'hF1, 8'hA8, 8'hF1, 8'hF1, 8'hF1, 8'hA8, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'hA8, 8'hFF, 8'hA8, 8'hF1, 8'hF1, 8'hFF, 8'hFF, 8'hA8, 8'h11, 8'hA8, 8'hF1, 8'hF1, 8'hF1, 8'hF1, 8'hF1, 8'hA8, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'hA8, 8'hF1, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hA8, 8'hA0, 8'hA0, 8'hF1, 8'hA8, 8'hA8, 8'hF1, 8'hF1, 8'hA8, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'hA8, 8'hF1, 8'hF1, 8'hFF, 8'hFF, 8'hF1, 8'hA8, 8'hA0, 8'hFF, 8'hA8, 8'hA8, 8'h11, 8'hA8, 8'hA8, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'hA0, 8'hA8, 8'hA8, 8'hF1, 8'hF1, 8'hA8, 8'hE0, 8'hE0, 8'hA0, 8'hFF, 8'hA8, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'hA0, 8'hE0, 8'hE0, 8'hA8, 8'hA8, 8'hE0, 8'hE0, 8'hE0, 8'hA0, 8'hFF, 8'hA8, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'hA0, 8'h24, 8'hED, 8'h24, 8'hE0, 8'h24, 8'hED, 8'hE0, 8'h24, 8'hFF, 8'hF1, 8'hA8, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'hA0, 8'hE0, 8'h24, 8'hED, 8'hED, 8'hED, 8'h24, 8'h24, 8'hE0, 8'hA0, 8'hFF, 8'hA8, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'hA0, 8'hE0, 8'h24, 8'hE0, 8'hE0, 8'hE0, 8'h24, 8'hE0, 8'h24, 8'hA0, 8'hFF, 8'hA8, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'hDF, 8'hA0, 8'hE0, 8'hE0, 8'h24, 8'hE0, 8'h24, 8'hE0, 8'hE0, 8'hE0, 8'h24, 8'hFF, 8'hA8, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'hFF, 8'hFF, 8'hA0, 8'hE0, 8'hE0, 8'h24, 8'hE0, 8'hE0, 8'hE0, 8'hA0, 8'hFF, 8'hFF, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'hFF, 8'hFF, 8'hA0, 8'h24, 8'hA0, 8'h24, 8'hE0, 8'hA0, 8'hA0, 8'hFF, 8'hFF, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'hA8, 8'hFF, 8'hFF, 8'hFF, 8'hA0, 8'hA0, 8'hA0, 8'hFF, 8'hFF, 8'hFF, 8'hA8, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'hA8, 8'hF1, 8'hA8, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hA8, 8'hF1, 8'hA8, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'hA8, 8'hF1, 8'hF1, 8'hA8, 8'h11, 8'h11, 8'h11, 8'hA8, 8'hF1, 8'hA8, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'hA8, 8'hA8, 8'hA8, 8'h11, 8'h11, 8'h11, 8'hA8, 8'hA8, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 }
	},
// BOX [?]
	{{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
{8'h11, 8'h11, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h11, 8'h11 },
{8'h11, 8'h11, 8'h00, 8'h00, 8'h20, 8'h8C, 8'h8C, 8'h8C, 8'h8C, 8'h8C, 8'h8C, 8'h8C, 8'h8C, 8'h8C, 8'h8C, 8'h8C, 8'h8C, 8'h8C, 8'h8C, 8'h8C, 8'h8C, 8'h8C, 8'h8C, 8'h8C, 8'h8C, 8'h8C, 8'h8C, 8'h20, 8'h00, 8'h00, 8'h11, 8'h11 },
{8'h11, 8'h11, 8'h00, 8'h00, 8'h44, 8'hF4, 8'hF4, 8'hF4, 8'hD4, 8'hD0, 8'hD0, 8'hD0, 8'hD0, 8'hD0, 8'hD0, 8'hD0, 8'hD0, 8'hD0, 8'hD0, 8'hD0, 8'hD0, 8'hD4, 8'hF4, 8'hF4, 8'hF4, 8'hF4, 8'hF4, 8'h44, 8'h00, 8'h00, 8'h11, 8'h11 },
{8'h11, 8'h11, 8'h00, 8'hAC, 8'hD4, 8'hF9, 8'hF9, 8'hFD, 8'h91, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h6C, 8'hFD, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hD4, 8'hAC, 8'h00, 8'h11, 8'h11 },
{8'h11, 8'h11, 8'h00, 8'hB0, 8'hF4, 8'hF9, 8'hD9, 8'hB5, 8'h8D, 8'h49, 8'h49, 8'h49, 8'h49, 8'h49, 8'h49, 8'h49, 8'h49, 8'h49, 8'h49, 8'h49, 8'h49, 8'h6D, 8'hB5, 8'hD9, 8'hF9, 8'hF9, 8'hF9, 8'hF4, 8'hB0, 8'h00, 8'h11, 8'h11 },
{8'h11, 8'h11, 8'h00, 8'hB0, 8'hD4, 8'hFE, 8'hB5, 8'h00, 8'h6D, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h92, 8'h00, 8'h8D, 8'hFE, 8'hF9, 8'hF9, 8'hF4, 8'hAC, 8'h00, 8'h11, 8'h11 },
{8'h11, 8'h11, 8'h00, 8'hB0, 8'hD0, 8'h91, 8'h8D, 8'h6D, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'h6D, 8'h8D, 8'h91, 8'hD5, 8'hF9, 8'hF4, 8'hAC, 8'h00, 8'h11, 8'h11 },
{8'h11, 8'h11, 8'h00, 8'hB0, 8'hB0, 8'h00, 8'h49, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h6D, 8'h00, 8'hB1, 8'hFD, 8'hD4, 8'hAC, 8'h00, 8'h11, 8'h11 },
{8'h11, 8'h11, 8'h00, 8'hB0, 8'hB0, 8'h00, 8'h49, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h92, 8'h49, 8'h49, 8'h49, 8'h49, 8'h6D, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h6D, 8'h00, 8'hB1, 8'hFD, 8'hD4, 8'hAC, 8'h00, 8'h11, 8'h11 },
{8'h11, 8'h11, 8'h00, 8'hB0, 8'hB0, 8'h00, 8'h49, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h49, 8'h00, 8'h00, 8'h00, 8'h00, 8'h24, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h6D, 8'h00, 8'hB1, 8'hFD, 8'hD4, 8'hAC, 8'h00, 8'h11, 8'h11 },
{8'h11, 8'h11, 8'h00, 8'hB0, 8'hD4, 8'hD9, 8'h91, 8'h24, 8'h24, 8'h24, 8'h24, 8'h24, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h24, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h6D, 8'h00, 8'hB1, 8'hFD, 8'hD4, 8'hAC, 8'h00, 8'h11, 8'h11 },
{8'h11, 8'h11, 8'h00, 8'hB0, 8'hD4, 8'hFD, 8'hB5, 8'h24, 8'h24, 8'h24, 8'h00, 8'h00, 8'h24, 8'h24, 8'h24, 8'h24, 8'h24, 8'h49, 8'hFF, 8'hFF, 8'hFF, 8'hDB, 8'hDB, 8'h6D, 8'h24, 8'hB5, 8'hFD, 8'hD4, 8'hAC, 8'h00, 8'h11, 8'h11 },
{8'h11, 8'h11, 8'h00, 8'hB0, 8'hF4, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hFD, 8'h6D, 8'h00, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h92, 8'h00, 8'h8D, 8'hFD, 8'hF9, 8'hF9, 8'hF4, 8'hAC, 8'h00, 8'h11, 8'h11 },
{8'h11, 8'h11, 8'h00, 8'hB0, 8'hF4, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hFD, 8'h6D, 8'h00, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hDB, 8'hB6, 8'hB2, 8'hB6, 8'h91, 8'h48, 8'hB1, 8'hFD, 8'hF9, 8'hF9, 8'hF4, 8'hAC, 8'h00, 8'h11, 8'h11 },
{8'h11, 8'h11, 8'h00, 8'hB0, 8'hF4, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hFD, 8'h6D, 8'h00, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hDB, 8'h00, 8'h00, 8'h00, 8'h68, 8'hFE, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF4, 8'hAC, 8'h00, 8'h11, 8'h11 },
{8'h11, 8'h11, 8'h00, 8'hB0, 8'hF4, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hB5, 8'h91, 8'h6D, 8'h6D, 8'h6D, 8'h6D, 8'h6D, 8'h6D, 8'h91, 8'h91, 8'h91, 8'hB5, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF4, 8'hAC, 8'h00, 8'h11, 8'h11 },
{8'h11, 8'h11, 8'h00, 8'hB0, 8'hF4, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hFD, 8'hFE, 8'h48, 8'h00, 8'h00, 8'h00, 8'h00, 8'h24, 8'hFD, 8'hFD, 8'hFD, 8'hFD, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF4, 8'hAC, 8'h00, 8'h11, 8'h11 },
{8'h11, 8'h11, 8'h00, 8'hB0, 8'hF4, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hFD, 8'h8D, 8'h24, 8'h92, 8'hDA, 8'hB6, 8'hB6, 8'hDA, 8'hB6, 8'h24, 8'h6D, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF4, 8'hAC, 8'h00, 8'h11, 8'h11 },
{8'h11, 8'h11, 8'h00, 8'hB0, 8'hF4, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hFD, 8'h6D, 8'h00, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hDB, 8'h00, 8'h48, 8'hFD, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF4, 8'hAC, 8'h00, 8'h11, 8'h11 },
{8'h11, 8'h11, 8'h00, 8'hB0, 8'hF4, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hFD, 8'h6D, 8'h00, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hDB, 8'h00, 8'h48, 8'hFD, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF4, 8'hAC, 8'h00, 8'h11, 8'h11 },
{8'h11, 8'h11, 8'h00, 8'hB0, 8'hF4, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hFD, 8'h91, 8'h48, 8'h92, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'h48, 8'h6D, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF4, 8'hAC, 8'h00, 8'h11, 8'h11 },
{8'h11, 8'h11, 8'h00, 8'hB0, 8'hF4, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hFD, 8'h44, 8'h00, 8'h00, 8'h00, 8'h00, 8'h20, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF4, 8'hAC, 8'h00, 8'h11, 8'h11 },
{8'h11, 8'h11, 8'h00, 8'hB0, 8'hD4, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'h91, 8'h6D, 8'h6D, 8'h6D, 8'h6D, 8'h8D, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF4, 8'hAC, 8'h00, 8'h11, 8'h11 },
{8'h11, 8'h11, 8'h00, 8'hB0, 8'hF4, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hFD, 8'hFE, 8'hFE, 8'hFE, 8'hFE, 8'hFE, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF9, 8'hF4, 8'hB0, 8'h00, 8'h11, 8'h11 },
{8'h11, 8'h11, 8'h00, 8'h44, 8'h68, 8'hF4, 8'hF4, 8'hF4, 8'hF4, 8'hF4, 8'hF4, 8'hF4, 8'hD4, 8'hD4, 8'hD4, 8'hD4, 8'hD4, 8'hD4, 8'hF4, 8'hF4, 8'hF4, 8'hF4, 8'hF4, 8'hF4, 8'hF4, 8'hF4, 8'hF4, 8'h68, 8'h44, 8'h00, 8'h11, 8'h11 },
{8'h11, 8'h11, 8'h00, 8'h00, 8'h20, 8'hD0, 8'hD0, 8'hD0, 8'hD0, 8'hD0, 8'hD0, 8'hD0, 8'hD0, 8'hD0, 8'hD0, 8'hD0, 8'hD0, 8'hD0, 8'hD0, 8'hD0, 8'hD0, 8'hD0, 8'hD0, 8'hD0, 8'hD0, 8'hD0, 8'hD0, 8'h20, 8'h00, 8'h00, 8'h11, 8'h11 },
{8'h11, 8'h11, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h11, 8'h11 },
{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 }
},

// ENEMY SHOWING FACE
	{{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h88, 8'h88, 8'h88, 8'h88, 8'h88, 8'h88, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'hA8, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hF5, 8'hA8, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h24, 8'h24, 8'h24, 8'hF5, 8'h24, 8'h24, 8'h24, 8'hF5, 8'hA8, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h24, 8'h1D, 8'h1D, 8'hFF, 8'h24, 8'hFF, 8'h1D, 8'h1D, 8'h24, 8'hF5, 8'hA8, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h24, 8'h1D, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h1D, 8'h24, 8'hF5, 8'hA8, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h24, 8'hFF, 8'hFF, 8'h24, 8'hFF, 8'h24, 8'hFF, 8'hFF, 8'h24, 8'hF5, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h24, 8'hFF, 8'hFF, 8'h24, 8'hFF, 8'h24, 8'hFF, 8'hFF, 8'h24, 8'hA8, 8'h1D, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h24, 8'h24, 8'h24, 8'hA8, 8'h24, 8'h24, 8'h24, 8'h11, 8'h11, 8'h15, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'hA8, 8'hA8, 8'hA8, 8'h11, 8'hA8, 8'hA8, 8'h11, 8'hA8, 8'hA8, 8'hA8, 8'h15, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'hA8, 8'hF5, 8'hF5, 8'hF5, 8'hA8, 8'h11, 8'h11, 8'hA8, 8'hF5, 8'hF5, 8'hF5, 8'hA8, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h24, 8'hA8, 8'hA8, 8'hF5, 8'hA8, 8'hA8, 8'h92, 8'h92, 8'hA8, 8'hA8, 8'hF5, 8'hA8, 8'hA8, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h24, 8'h92, 8'hA8, 8'hA8, 8'hA8, 8'h92, 8'hB6, 8'hB6, 8'h92, 8'hA8, 8'hA8, 8'hA8, 8'h92, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h24, 8'hB6, 8'h92, 8'h92, 8'h92, 8'hB6, 8'hFF, 8'hFF, 8'hB6, 8'h92, 8'h92, 8'h92, 8'hB6, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h24, 8'hB6, 8'hFF, 8'hB6, 8'hB6, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'hB6, 8'hB6, 8'hFF, 8'hB6, 8'h24, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h24, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h49, 8'hFF, 8'hFF, 8'h49, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'h24, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h24, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h49, 8'hFF, 8'hFF, 8'h49, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'h24, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h24, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h49, 8'hFF, 8'hFF, 8'h49, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'h24, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h24, 8'hB6, 8'hFF, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'hFF, 8'hB6, 8'h24, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h24, 8'hB6, 8'h24, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'h24, 8'hB6, 8'h24, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h24, 8'hB6, 8'hFF, 8'hFF, 8'h49, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h49, 8'hFF, 8'hFF, 8'hB6, 8'h24, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h24, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'h49, 8'h49, 8'h49, 8'h49, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'h24, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h24, 8'hB6, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'hB6, 8'h24, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h24, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'h24, 8'h24, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'h24, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h25, 8'h25, 8'h25, 8'h25, 8'h11, 8'h11, 8'h25, 8'h25, 8'h25, 8'h25, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 }
	},
	//EMENY HIDING FACE
	{{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'hA8, 8'hA8, 8'hA8, 8'h11, 8'h11, 8'h11, 8'h11, 8'hA8, 8'hA8, 8'hA8, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'hA8, 8'hF5, 8'hF5, 8'hF5, 8'hA8, 8'h24, 8'h24, 8'hA8, 8'hF5, 8'hF5, 8'hF5, 8'hA8, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'hA8, 8'hA8, 8'hF5, 8'hA8, 8'hA8, 8'h92, 8'h92, 8'hA8, 8'hA8, 8'hF5, 8'hA8, 8'hA8, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h24, 8'hA8, 8'hA8, 8'hA8, 8'h92, 8'hB6, 8'hB6, 8'h92, 8'hA8, 8'hA8, 8'hA8, 8'h24, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h24, 8'hB6, 8'h92, 8'h92, 8'h92, 8'hB6, 8'hFF, 8'hFF, 8'hB6, 8'h92, 8'h92, 8'h92, 8'hB6, 8'h24, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h24, 8'hB6, 8'hFF, 8'hB6, 8'hB6, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'hB6, 8'hB6, 8'hFF, 8'hB6, 8'h24, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h24, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h49, 8'hFF, 8'hFF, 8'h49, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'h24, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h24, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h49, 8'hFF, 8'hFF, 8'h49, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'h24, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h24, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h49, 8'hFF, 8'hFF, 8'h49, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'h24, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h24, 8'hB6, 8'hFF, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'hFF, 8'hB6, 8'h24, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h24, 8'hB6, 8'h24, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'h24, 8'hB6, 8'h24, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h24, 8'hB6, 8'hFF, 8'hFF, 8'h49, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h49, 8'hFF, 8'hFF, 8'hB6, 8'h24, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h24, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'h49, 8'h49, 8'h49, 8'h49, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'h24, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h24, 8'hB6, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'hB6, 8'h24, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h24, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'h24, 8'h24, 8'hB6, 8'hB6, 8'hB6, 8'hB6, 8'h24, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h24, 8'h24, 8'h24, 8'h24, 8'h11, 8'h11, 8'h24, 8'h24, 8'h24, 8'h24, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 },
	{8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11, 8'h11 }
	}};
// pipeline (ff) to get the pixel color from the array 	 

//==----------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout <=	8'h00;
		Bricks = 4'b0101;
	end
	else begin
		RGBout <= TRANSPARENT_ENCODING ; // default 
		Bricks = 4'b0;

		if ((InsideRectangle == 1'b1 )		& 	// only if inside the external bracket 
		   (turtle_BitmapMask[offsetY[8:5] ][offsetX[8:5]] == 1'b1 )) // take bits 5,6,7,8,9,10 from address to select  position in the maze    
						RGBout <= object_colors[0][offsetY[4:0]][offsetX[4:0]] ; 
		if ((InsideRectangle == 1'b1 )		& 	// only if inside the external bracket 
		   (boxBitMapmask[offsetY[8:5] ][offsetX[8:5]] == 1'b1 )) // take bits 5,6,7,8,9,10 from address to select  position in the maze    
						RGBout <= object_colors[1][offsetY[4:0]][offsetX[4:0]] ; 
		if ((InsideRectangle == 1'b1 )		& 	// only if inside the external bracket 
		   (showingFace_BitmapMask[offsetY[8:5] ][offsetX[8:5]] == 1'b1 )) // take bits 5,6,7,8,9,10 from address to select  position in the maze    
						RGBout <= object_colors[2][offsetY[4:0]][offsetX[4:0]] ;
		if ((InsideRectangle == 1'b1 )		& 	// only if inside the external bracket 
		   (hidingFace_BitmapMask[offsetY[8:5] ][offsetX[8:5]] == 1'b1 )) // take bits 5,6,7,8,9,10 from address to select  position in the maze    
						RGBout <= object_colors[3][offsetY[4:0]][offsetX[4:0]] ;
	
		if((InsideRectangle==1'b1)& collision) begin
		
			if(turtle_BitmapMask[pixelY[8:5]-MatTopY[8:5]][pixelX[8:5]-MatTopX[8:5]] ==1'b1) begin
				turtle_BitmapMask[pixelY[8:5]-MatTopY[8:5]][pixelX[8:5]-MatTopX[8:5]] =1'b0;
				Bricks = 4'b0001;
				tiles--;
				end
			else if(boxBitMapmask[pixelY[8:5]-MatTopY[8:5]][pixelX[8:5]-MatTopX[8:5]] == 1'b1) begin
					boxBitMapmask[pixelY[8:5]-MatTopY[8:5]][pixelX[8:5]-MatTopX[8:5]] = 1'b0;
					Bricks = 4'b0010;
					tiles--;
					end
			else if(hidingFace_BitmapMask[pixelY[8:5]-MatTopY[8:5]][pixelX[8:5]-MatTopX[8:5]] == 1'b1) begin
				hidingFace_BitmapMask[pixelY[8:5]-MatTopY[8:5]][pixelX[8:5]-MatTopX[8:5]] = 1'b0;
				Bricks = 4'b0011;
				tiles--;
				end
			else if(showingFace_BitmapMask[pixelY[8:5]-MatTopY[8:5]][pixelX[8:5]-MatTopX[8:5]] == 1'b1) begin
			showingFace_BitmapMask[pixelY[8:5]-MatTopY[8:5]][pixelX[8:5]-MatTopX[8:5]] = 1'b0;
				hidingFace_BitmapMask[pixelY[8:5]-MatTopY[8:5+1'b1]][pixelX[8:5]-MatTopX[8:5]] = 1'b1;
				end
			win <= (tiles==0);
			RGBout <= object_colors[1][offsetY[4:0]][offsetX[4:0]] ; 
			RGBout <= object_colors[0][offsetY[4:0]][offsetX[4:0]] ;
			RGBout <= object_colors[2][offsetY[4:0]][offsetX[4:0]] ;
			RGBout <= object_colors[3][offsetY[4:0]][offsetX[4:0]] ;
			end
		end 
end

//==----------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 
assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   
endmodule

