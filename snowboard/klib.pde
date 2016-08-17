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
}