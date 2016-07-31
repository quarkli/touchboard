/* read_snowboard_1610.pde
    Read and visualize data from Snowboard and 1610 sensor
    Copyright (c) 2014-2016 Kitronyx http://www.kitronyx.com
    contact@kitronyx.com
    GPL V3.0
*/

KLib klib;
int translateX = 20;
int translateY = 20;
PShape buttons[][] = new PShape[3][13];

final char keymap[][] = {
  {'1', '2', 'a', 'b', 'm', 'n', 
   '5', '6', 'e', 'f', 'q', 'r', 
   '9', '0', 'i', 'j', 'u', 'v',
   '3', '4', 'c', 'd', 'o', 'p',
   '7', '8', 'g', 'h', 's', 't',
   'y', 'z', 'k', 'l', 'w', 'x'},
  {'!', '@', 'A', 'B', 'M', 'N', 
   '%', '^', 'E', 'F', 'Q', 'R', 
   '(', ')', 'I', 'J', 'U', 'V',
   '#', '$', 'C', 'D', 'O', 'P',
   '&', '*', 'G', 'H', 'S', 'T',
   'Y', 'Z', 'K', 'L', 'W', 'X'}
};

KeyButton btn1, btn2, btn3, btn4, btn5;

void settings()
{
  size(dispHeight+translateX*2, dispWidth+translateY*2);
}

void setup()
{
    klib = new KLib(this);
    // use an appropriate port number in the line below.
    klib.init("COM3", "Snowboard", "1610");
    
    klib.start();
    btn1 = new KeyButton(RECT, dispHeight/4, dispWidth/3, 5);
    btn1.posX = 0;
    btn1.posY = 0;
    btn1.label = "A";
    btn2 = new KeyButton(ELLIPSE, 45, 45, 5);
    btn2.posX = dispHeight*5/16;
    btn2.posY = 0;
    btn2.label = "1";
    btn3 = new KeyButton(ELLIPSE, 45, 45, 5);
    btn3.posX = dispHeight*5/16;
    btn3.posY = dispWidth/6;
    btn3.label = "2";
    btn4 = new KeyButton(ELLIPSE, 45, 45, 5);
    btn4.posX = dispHeight*4/16;
    btn4.posY = dispWidth/12;
    btn4.label = "3";
    btn5 = new KeyButton(ELLIPSE, 45, 45, 5);
    btn5.posX = dispHeight*6/16;
    btn5.posY = dispWidth/12;
    btn5.label = "4";
}

void draw()
{ 
    background(0);
    translate(translateX, translateY);
    
    if (klib.read() == true)
    {
        ArrayList<TouchEvent> teList = lookforTouch(klib.frame);      
        btn1.draw(teList);
        btn2.draw(teList);
        btn3.draw(teList);
        btn4.draw(teList);
        btn5.draw(teList);
        drawTouch(teList);
    }
}

void drawTouch(ArrayList<TouchEvent> teList) {
  for (int i=0; i < teList.size(); i++) {
    TouchEvent te = teList.get(i);
    
    stroke(0, 255, 255);
    if (te.z <= 2) {
      fill(0, 0);
    }
    else if (te.z > 3 && te.z <= 5) {
      fill(0, 127, 127);
    }
    else if (te.z > 5) {
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
        textX = width/2;
        textY = height/2 + fontSize/3;
        break;
      case TRIANGLE:
        shape = createShape(TRIANGLE, 0, 0, width - border*2, height - border*2); 
        textX = width/2 + border;
        textY = height/2 + border/2 + fontSize/2;
        break;
      case ELLIPSE:
        shape = createShape(ELLIPSE, width/2-border, height/2-border, width - border*2, height - border*2); 
        textX = width/2;
        textY = height/2 + fontSize/3;
        break;
    }
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
        if (te.z > 5) {
          inShape = evalPoint(te.x, te.y);
          break;
        }
      }
    }

    if (mousePressed) {
      inShape = inShape | evalPoint(mouseX - translateX, mouseY - translateY);
    }
    
    if (inShape) {
      strokeColor = dimColor;
      fillColor = lightColor;
      textColor = secColor;
    }
    else {
      strokeColor = lightColor;
      fillColor = dimColor;
      textColor = priColor;
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