/* read_snowboard_1610.pde
    Read and visualize data from Snowboard and 1610 sensor
    Copyright (c) 2014-2016 Kitronyx http://www.kitronyx.com
    contact@kitronyx.com
    GPL V3.0
*/

KLib klib;
int translateX = 20;
int translateY = 160;
String myText = "";
KeyButton buttons[][] = new KeyButton[3][13];

final String keyLabels[][] = {
  {"1", "2", "3", "4",
   "5", "6", "7", "8",
   "9", "0", "y", "z"},
  {"a", "b", "c", "d",
   "e", "f", "g", "h",
   "m", "n", "o", "p"},
  {"q", "r", "s", "t",
   "i", "j", "k", "l",
   "u", "v", "w", "x"}
};

KeyButton btn1, btn2, btn3, btn4, btn5;

void settings()
{
  size(dispHeight+translateX*2, dispWidth+translateY);
}

void setup()
{
    klib = new KLib(this);
    // use an appropriate port number in the line below.
    klib.init("COM3", "Snowboard", "1610");
    
    klib.start();
    for (int i=0; i<buttons.length; i++) {
      int n = 0;
      for (int j=0; j<buttons[i].length/3; j++) {
        if (j > 0) {
          n++;
          buttons[i][n] = new KeyButton(ELLIPSE, 50, 40, 5);
          buttons[i][n].posX = (j-1)*dispHeight/4 + dispHeight*5/16;
          buttons[i][n].posY = i * dispWidth/3;
          buttons[i][n].label = keyLabels[i][n-1];
          n++;
          buttons[i][n] = new KeyButton(ELLIPSE, 50, 40, 5);
          buttons[i][n].posX = (j-1)*dispHeight/4 + dispHeight*5/16;
          buttons[i][n].posY = (i * dispWidth/3) + dispWidth/6;
          buttons[i][n].label = keyLabels[i][n-1];
          n++;
          buttons[i][n] = new KeyButton(ELLIPSE, 50, 40, 5);
          buttons[i][n].posX = (j-1)*dispHeight/4 + dispHeight*4/16;
          buttons[i][n].posY = (i * dispWidth/3) + dispWidth/12;
          buttons[i][n].label = keyLabels[i][n-1];
          n++;
          buttons[i][n] = new KeyButton(ELLIPSE, 50, 40, 5);
          buttons[i][n].posX = (j-1)*dispHeight/4 + dispHeight*6/16;
          buttons[i][n].posY = (i * dispWidth/3) + dispWidth/12;
          buttons[i][n].label = keyLabels[i][n-1];
        }
        else {
          buttons[i][j] = new KeyButton(RECT, dispHeight/4, dispWidth/3, 10);
          buttons[i][j].posX = 0;
          buttons[i][j].posY = i * dispWidth / 3;
          buttons[i][j].label = i==0 ? "Backspace" : i==1 ? "Enter" : "Space";
        }
      }
    }
}

void draw()
{ 
    background(0);
    stroke(127, 127, 255);
    fill(0);
    rect(30, 20, dispHeight-20, 100, 10);
    fill(127, 127, 255);
    textAlign(LEFT);
    text(myText + "_", 40, 20, dispHeight-30, 100);
    translate(translateX, translateY);
    
    if (klib.read() == true)
    {
        ArrayList<TouchEvent> teList = lookforTouch(klib.frame);      
        for (int i=0; i<buttons.length; i++) {
          for (int j=0; j<buttons[i].length; j++) {
            buttons[i][j].draw(teList);
          }
        }
        drawTouch(teList);
    }
}

void drawTouch(ArrayList<TouchEvent> teList) {
  for (int i=0; i < teList.size(); i++) {
    TouchEvent te = teList.get(i);
    
    stroke(0, 255, 255);
    if (te.z <= touchThreshold) {
      fill(0, 0);
    }
    else if (te.z > touchThreshold && te.z <= pressThreshold) {
      fill(0, 127, 127);
    }
    else if (te.z > pressThreshold) {
      fill(0, 255, 255);
    }
    ellipse(te.x, te.y, touchRadius, touchRadius);    
  }
}

public class KeyButton
{
  private int textColor = 0;
  private int fillColor = 0;
  private int strokeColor = 0;
  private float textX, textY;
  private int debounce = 0;

  public PShape shape;
  public String label = "";
  public int type = 0;
  public int posX = 0;
  public int posY = 0;
  public int width = 0;
  public int height = 0;
  public int border = 0;
  public int fontSize = 18;
  public color lightColor = color(255, 255, 255);
  public color dimColor = color(0, 0, 0);
  public color priColor = color(0, 255, 0);
  public color secColor = color(0, 127, 0); 
  
  public KeyButton(int type, int width, int height, int border) {
    this.type = type;
    this.width = width;
    this.height = height;
    this.border = border;
    
    switch (type) {
      case RECT:
        shape = createShape(RECT, 0, 0, width - border*2, height - border*2, 5);
        break;
      case ELLIPSE:
        shape = createShape(ELLIPSE, width/2-border, height/2-border, width - border*2, height - border*2); 
        break;
    }
    textX = width/2;
    textY = height/2 + fontSize/3;

    strokeColor = lightColor;
    fillColor = dimColor;
    textColor = priColor;
  }

  private boolean evalPoint(float x, float y) {
    boolean ret = true;
    switch (this.type) {
      case RECT:
        ret = ret & (x >= posX + border);
        ret = ret & (x <= posX + width - border);
        ret = ret & (y >= posY + border);
        ret = ret & (y <= posY + height - border);
        break;
      case ELLIPSE:
        ret = ret & pow((x-posX-width/2) * 2 / (width-border*2), 2) + pow((y-posY-height/2) * 2 / (height-border*2), 2) <= 1;
        break;
      case TRIANGLE:
        break;
    }
    return ret;
  }
  
  public void draw(ArrayList<TouchEvent> teList) {
    boolean inShape = false;
    
    if (teList.size() > 0) {
      for (int i=0; i < teList.size(); i++) {
        TouchEvent te = teList.get(i);
        if (te.z > pressThreshold) {
          inShape = evalPoint(te.x, te.y);
          break;
        }
      }
    }

    if (mousePressed) {
      inShape = inShape | evalPoint(mouseX - translateX, mouseY - translateY);
    }
    
    if (inShape) {
      if (strokeColor == lightColor) debounce++;
      else debounce = 0;

      if (debounce > 2) {
        strokeColor = dimColor;
        fillColor = lightColor;
        textColor = secColor;
        
        if (label.length() == 1) myText += label;
        if (label == "Space") myText += " ";
        if (label == "Enter") myText += "\n";
        if (label == "Backspace" && myText.length() > 0) myText = myText.substring(0, myText.length()-1);
        debounce = 0;
      }
    }
    else {
      if (strokeColor == dimColor) debounce++;
      else debounce = 0;

      if (debounce > 2) {
        strokeColor = lightColor;
        fillColor = dimColor;
        textColor = priColor;
        debounce = 0;
      }
    }
    
    shape.setStroke(strokeColor);
    shape.setFill(fillColor);
    shape(shape, posX + border, posY + border);

    fill(textColor);
    textSize(fontSize);
    textAlign(CENTER);
    text(label, posX + textX, posY + textY);

    fill(0);
  }
}