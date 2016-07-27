/* read_snowboard_1610.pde
    Read and visualize data from Snowboard and 1610 sensor
    Copyright (c) 2014-2016 Kitronyx http://www.kitronyx.com
    contact@kitronyx.com
    GPL V3.0
*/

KLib klib;
Grid grid;

void setup()
{
    klib = new KLib(this);
    // use an appropriate port number in the line below.
    klib.init("COM3", "Snowboard", "1610");
    
    int sz_rect = 30;
    grid = new Grid(klib.nrow, klib.ncol, sz_rect);
    
    
    println(sz_rect*klib.ncol, sz_rect*klib.nrow);
    //size(sz_rect*klib.ncol, sz_rect*klib.nrow);
    size(300, 480);
    
    klib.start();
}

void draw()
{
    int scale = 5;
    
    if (klib.read() == true)
    {
        //grid.draw(klib.frame, scale);
        background(0);
        lookforTouch(klib.frame);
    }
}

public class Grid
{
    private int nrow;
    private int ncol;
    private int size;
    
    public Grid(int nrow, int ncol, int size)
    {
        this.nrow = nrow;
        this.ncol = ncol;
        this.size = size;
    }
    
    public void draw(int[][] frame, int scale)
    {
        for (int i = 0; i < nrow; i++)
        {
            for (int j = 0; j < ncol; j++)
            {
                fill(scale*frame[i][j]);
                rect(j*size, i*size, size, size);
            }
        }
    }
}