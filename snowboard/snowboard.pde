/* read_snowboard_1610.pde
    Read and visualize data from Snowboard and 1610 sensor
    Copyright (c) 2014-2016 Kitronyx http://www.kitronyx.com
    contact@kitronyx.com
    GPL V3.0
*/

KLib klib;
int translateX = 20;
int translateY = 160;
int keyRows = 4;
int keyCols = 4;
String myText = "";
KeyButton buttons[][] = new KeyButton[keyRows][keyCols];

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
    
  if (false) {
    // create buttons
    for (int i=0; i<keyRows; i++) {
      int n = 0;
      for (int j=0; j<keyCols; j++) {
        //if (j > 0) {
        //  n++;
        //  buttons[i][n] = new KeyButton(ELLIPSE, 50, 40, 5);
        //  buttons[i][n].posX = (j-1)*dispHeight/4 + dispHeight*5/16;
        //  buttons[i][n].posY = i * dispWidth/3;
        //  buttons[i][n].label = keyLabels[i][n-1];
        //  buttons[i][n].noTouch = true;
        //  n++;
        //  buttons[i][n] = new KeyButton(ELLIPSE, 50, 40, 5);
        //  buttons[i][n].posX = (j-1)*dispHeight/4 + dispHeight*5/16;
        //  buttons[i][n].posY = (i * dispWidth/3) + dispWidth/6;
        //  buttons[i][n].label = keyLabels[i][n-1];
        //  buttons[i][n].noTouch = true;
        //  n++;
        //  buttons[i][n] = new KeyButton(ELLIPSE, 50, 40, 5);
        //  buttons[i][n].posX = (j-1)*dispHeight/4 + dispHeight*4/16;
        //  buttons[i][n].posY = (i * dispWidth/3) + dispWidth/12;
        //  buttons[i][n].label = keyLabels[i][n-1];
        //  buttons[i][n].noTouch = true;
        //  n++;
        //  buttons[i][n] = new KeyButton(ELLIPSE, 50, 40, 5);
        //  buttons[i][n].posX = (j-1)*dispHeight/4 + dispHeight*6/16;
        //  buttons[i][n].posY = (i * dispWidth/3) + dispWidth/12;
        //  buttons[i][n].label = keyLabels[i][n-1];
        //  buttons[i][n].noTouch = true;
        //}
        //else {
          buttons[i][j] = new KeyButton(RECT, dispHeight/keyCols, dispWidth/keyRows, 10);
          buttons[i][j].posX = j * dispHeight / keyCols;
          buttons[i][j].posY = i * dispWidth / keyRows;
          buttons[i][j].label = "" + (i*keyCols+j+1); //i==0 ? "Backspace" : i==1 ? "Enter" : "Space";
        //}
      }
    }
  }
}

int startX = -1, startY = -1;
TouchEvent actTe;
void draw()
{ 
    background(0);
    
    // draw text input area
    stroke(127, 127, 255);
    fill(0);
    rect(30, 20, dispHeight-20, 100, 10);
    fill(127, 127, 255);
    textAlign(LEFT);
    text(myText + "_", 40, 20, dispHeight-30, 100);
    translate(translateX, translateY);
    
    // read touch data frame
    if (klib.read() == true)
    {
        // translate touch event
        ArrayList<TouchEvent> teList = lookforTouch(klib.frame);
        // draw buttons
        //for (int i=0; i<buttons.length; i++) {
        //  for (int j=0; j<buttons[i].length; j++) {
        //    buttons[i][j].draw(teList);
        //  }
        //}
        // draw touches
        fill(0);
        if (mousePressed) {
          if (startX < 0) startX = mouseX;
          if (startY < 0) startY = mouseY;
          fill(255);
        }
        else {
          startX = -1;
          startY = -1;
        }
        ellipse(dispHeight/2, dispWidth/2, 50, 50);
        if (startX > 0 && startY > 0) line(dispHeight/2, dispWidth/2, dispHeight/2+mouseX-startX, dispWidth/2+mouseY-startY);
        drawTouch(teList);
    }
}

void drawTouch(ArrayList<TouchEvent> teList) {
  for (int i=0; i < teList.size(); i++) {
    TouchEvent te = teList.get(i);
    
    stroke(255, 127, 127);
    if (te.z > touchThreshold*2 && te.z <= pressThreshold) {
      fill(127, 63, 63);
    }
    else if (te.z > pressThreshold) {
      fill(255, 127, 127);
      actTe = te;
    }
    else {
      fill(0, 0);
    }
    float r = map(te.z, 0, 128, 0, touchRadius);
    if (r > touchRadius) r = touchRadius;
    line(te.x+touchRadius/2-r, te.y, te.x+r-touchRadius/2, te.y);
    line(te.x, te.y+touchRadius/2-r, te.x, te.y+r-touchRadius/2);
    ellipse(te.x, te.y, r, r);    
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
  public boolean noTouch = false;
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

  // evaluate if a point is within button's area
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
  
  int timer = 10;
  public void draw(ArrayList<TouchEvent> teList) {
    boolean inShape = false;
    
    if (!noTouch) {
      // check if button is clicked by touch
      if (teList.size() > 0) {
        for (int i=0; i < teList.size(); i++) {
          TouchEvent te = teList.get(i);
          if (te.z > pressThreshold) {
            inShape = evalPoint(te.x, te.y);
            break;
          }
        }
      }
  
      // check if button is clicked by mouse
      if (mousePressed) {
        inShape = inShape | evalPoint(mouseX - translateX, mouseY - translateY);
      }
  
      // set stroke and fill based on the touch event
      if (inShape) {
        if (strokeColor == lightColor) debounce++;
        else debounce = 0;
  
        if (debounce > 2) {
          strokeColor = dimColor;
          fillColor = lightColor;
          textColor = secColor;
          debounce = 0;
          timer = 0;
        }
          
        if (strokeColor == dimColor && timer == 0) {
          timer = 10;
          if (label.length() == 1) myText += label;
          if (label == "Space") myText += " ";
          if (label == "Enter") myText += "\n";
          if (label == "Backspace" && myText.length() > 0) myText = myText.substring(0, myText.length()-1);
        }
        timer--;
      }
      else {
        if (strokeColor == dimColor) debounce++;
        else debounce = 0;
  
        if (debounce > 2) {
          strokeColor = lightColor;
          fillColor = dimColor;
          textColor = priColor;
          debounce = 0;
          timer = 0;
        }
      }
    }
    
    // draw shape
    shape.setStroke(strokeColor);
    shape.setFill(fillColor);
    shape(shape, posX + border, posY + border);

    // draw label
    fill(textColor);
    textSize(fontSize);
    textAlign(CENTER);
    text(label, posX + textX, posY + textY);

    fill(0);
  }
}