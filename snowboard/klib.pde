/* KLib.pde
    Processing API for Kitronyx's devices.
    Copyright (c) 2014-2016 Kitronyx http://www.kitronyx.com
    contact@kitronyx.com
    GPL V3.0
*/

import processing.serial.*;

public class KLib
{
    public int nrow;
    public int ncol;
    public int[][] frame;
    
    private String port;
    private int baud_rate;
    private String device;
    private String sensor;
    private int[] row_index;
    private int[] col_index;
    private String command;
    
    
    private PApplet parent;
    private Serial serial;
    
    public KLib(PApplet p)
    {
        parent = p;
    }
    
    public void init(String p, String dev, String s)
    {
        port = p;
        device = dev;
        sensor = s;
        
        if (device.equals("Snowboard") && sensor.equals("1610"))
        {
            baud_rate = 115200;
            nrow = 16;
            ncol = 10;
            frame = new int[nrow][ncol];
            row_index = new int[]{8,9,10,11,12,13,14,15,7,6,5,4,3,2,1,0};
            col_index = new int[]{0,1,2,3,4,5,6,7,8,9};
            command = "A";
        }
        else if (device.equals("MC1509") && sensor.equals("MS9705"))
        {
            baud_rate = 921600;
            nrow = 48;
            ncol = 48;
            frame = new int[nrow][ncol];
            row_index = new int[]{47,46,45,44,43,42,41,40,39,38,37,36,35,34,33,32,31,30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0};
            col_index = new int[]{47,46,45,44,43,42,41,40,39,38,37,36,35,34,33,32,31,30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0};
            command = "A";
        }
    }
    
    public void start()
    {
        serial = new Serial(parent, port, baud_rate, 'N', 8, 1);
    }
 
    public boolean read()
    {
        if (device.equals("Snowboard"))
        {
            return read_snowboard();
        }
        else if (device.equals("MC1509"))
        {
            return read_mc1509();
        }
        
        return false;
    }
    
    private boolean read_snowboard()
    {
        serial.write(command);
        String resp = serial.readStringUntil('\n');
        if (resp == null) return false;
        resp = trim(resp);
        int sensors[] = int(split(resp, ','));
        if (sensors.length != nrow*ncol) return false;
        int k = 0;
        for (int i = 0; i < frame.length; i++)
        {
            for (int j = 0; j < frame[0].length; j++)
            {
                frame[row_index[i]][col_index[j]] = sensors[k++];                
            }
        }
        return true;
    }
    
    private boolean read_mc1509()
    {
        serial.write(command);
        int[] resp = new int[nrow*ncol];
        byte[] buffer = new byte[nrow*ncol];
        int nread = 0;
        int offset = 0;
        while (true)
        {
            if (serial.available() > 0)
            {
                nread = serial.readBytes(buffer);
                for (int i = 0; i < nread; i++) resp[offset + i] = (int)(buffer[i]) & 0xFF;
                offset += nread;
            }
            if (offset == nrow*ncol) break;
        }
        
        if (offset != nrow*ncol) return false;
        
        int k = 0;
        for (int i = 0; i < frame.length; i++)
        {
            for (int j = 0; j < frame[0].length; j++)
            {
                frame[row_index[i]][col_index[j]] = resp[k++];                
            }
        }
        
        return true;
    }
}