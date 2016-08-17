/*
  Author: Quark Li
  quarkli@gmail.com
  MIT License
*/

final int UNO = 0;
final int DUE_H = 1;
final int DUE_V = 2;
final int QUATTRO = 3;
final int KEYBOARD = 0;
final int PAINT = 1;

KLib klib;
int mode = KEYBOARD;
int translateX = 20;
int translateY = 160;
int scnWidth = 0;
int scnHeight = 0;
int keyRows = 3;
int keyCols = 4;
String[] inText = new String[2];
char cursor = '_';
int cursorTimer = 0;
KeyButton buttons[][] = new KeyButton[keyRows][keyCols];

final String[][][] kl1 = {
  {{"Space", "Backspace", "", ""},
  {"1", "2", "3", "4"},
  {"5", "6", "7", "8"},
  {"9", "0", "x", "z"},
  {"", "", "", ""}},
  {{"<-", "->", "", ""},
  {"p", "b", "t", "d"},
  {"e", "i", "m", "n"},
  {"u", "j", "g", "k"},
  {"", "", "", ""}},
  {{"Enter", "", "", ""},
  {"a", "o", "c", "l"},
  {"h", "s", "r", "w"},
  {"v", "f", "q", "y"},
  {"", "", "", ""}}
};

final String[][][] kl2 = {
  {{"Space", "Backspace", "", ""},
  {"if", "for", "+", "-"},
  {"while", "switch", "*", "/"},
  {"=", "{}", "x", "z"},
  {"", "", "", ""}},
  {{"<-", "->", "", ""},
  {"p", "b", "t", "d"},
  {"e", "i", "m", "n"},
  {"u", "j", "g", "k"},
  {"", "", "", ""}},
  {{"Enter", "", "", ""},
  {"a", "o", "c", "l"},
  {"h", "s", "r", "w"},
  {"v", "f", "q", "y"},
  {"", "", "", ""}}
};
String[][][] keyLabels = kl2;

void settings() {
  scnWidth = drawHeight;
  scnHeight = drawWidth;
  size(scnWidth + translateX * 2,  scnHeight + translateY);
  inText[0] = inText[1] = "";
}

void setup() {
  klib = new KLib(this);
  // use an appropriate port number in the line below.
  klib.init("COM3", "Snowboard", "1610");
  klib.start();

  if (mode == KEYBOARD) {
    // create buttons
    for (int i=0; i<keyRows; i++) {
      int n = 0;
      for (int j=0; j<keyCols; j++) {
        if (j > 0) {
          buttons[i][j] = new KeyButton(QUATTRO, scnWidth/keyCols, scnHeight/keyRows, 10);
        }
        else {
          if (i > 1) {
            buttons[i][j] = new KeyButton(UNO, scnWidth/keyCols, scnHeight/keyRows, 10);
          }
          else if (i > 0) {
            buttons[i][j] = new KeyButton(DUE_H, scnWidth/keyCols, scnHeight/keyRows, 10);
          }
          else {
            buttons[i][j] = new KeyButton(DUE_V, scnWidth/keyCols, scnHeight/keyRows, 10);
          }
        }
        buttons[i][j].posX = j * scnWidth / keyCols;
        buttons[i][j].posY = i * scnHeight / keyRows;
        buttons[i][j].label[0] = keyLabels[i][j][0];
        buttons[i][j].label[1] = keyLabels[i][j][1];
        buttons[i][j].label[2] = keyLabels[i][j][2];
        buttons[i][j].label[3] = keyLabels[i][j][3];
      }
    }
  }
}

void draw() {
  background(0);

  if (cursorTimer < 10) {
    cursorTimer++;
  }
  else {
    cursorTimer = 0;
    if (cursor == '_') cursor =  ' ';
    else cursor = '_';
  }

  // draw text input area
  stroke(127, 127, 255);
  fill(0);
  rect(30, 20, scnWidth-20, 100, 10);
  fill(127, 127, 255);
  textAlign(LEFT);
  text(inText[0] + cursor + inText[1], 40, 20, scnWidth-30, 100);
  translate(translateX, translateY);

  // read touch data frame
  if (klib.read() == true)
  {
      // translate touch event
      ArrayList<TouchEvent> teList = lookforTouch(klib.frame);

      if (mode == KEYBOARD) {
        // draw buttons
        for (int i=0; i<buttons.length; i++) {
          for (int j=0; j<buttons[i].length; j++) {
            buttons[i][j].draw(teList);
          }
        }
      }
      else if (mode == PAINT) {
        paint(teList);
      }
      // draw touches
      drawTouch(teList);
  }
}

int paint_debounce = 0;
ArrayList<TouchEvent> paintList = new ArrayList<TouchEvent>();
void paint(ArrayList<TouchEvent> teList) {
  if (teList.size() == 0) {
    if (paintList.size() > 0 && paintList.get(paintList.size()-1).processed == false) {
      paint_debounce++;
    }
    else {
      paint_debounce = 0;
    }

    if (paint_debounce > 2) {
      TouchEvent tmp = new TouchEvent();
      tmp.x = 0;
      tmp.y = 0;
      tmp.processed = true;
      paintList.add(tmp);
    }
  }
  else {
    TouchEvent te = teList.get(0);

    if (paintList.size() > 0 && paintList.get(paintList.size()-1).processed == false) {
      if (te.z < touchThreshold*2) {
        paint_debounce++;
      }
      else {
        paint_debounce = 0;
      }

      if (paint_debounce > 2) {
        te.processed = true;
        paint_debounce = 0;
      }
    }
    else {
      if (te.z >= touchThreshold*2) {
        paint_debounce++;
      }
      else {
        paint_debounce = 0;
      }

      if (paint_debounce > 2) {
        te.processed = false;
        paint_debounce = 0;
      }
    }
    paintList.add(te);
  }

  for (int j=1; j<paintList.size(); j++) {
    if (j > 0) {
      TouchEvent prev = paintList.get(j-1);
      TouchEvent cur = paintList.get(j);
      if (!prev.processed && !cur.processed) {
        float r = map(prev.z, touchThreshold*3, 256, 0, touchRadius*2);
        if (r < 0) r = 0;
        strokeWeight(r);
        line(prev.x, prev.y, cur.x, cur.y);
      }
    }
  }
  strokeWeight(1);
}

void drawTouch(ArrayList<TouchEvent> teList) {
  for (int i=0; i < teList.size(); i++) {
    TouchEvent te = teList.get(i);

    if (te.processed == true) continue;

    stroke(255, 127, 127);
    if (te.z > touchThreshold*2 && te.z <= pressThreshold) {
      fill(127, 63, 63);
    }
    else if (te.z > pressThreshold) {
      fill(255, 127, 127);
    }
    else {
      fill(0, 0);
    }
    float r = map(te.z, 0, 128, 0, touchRadius);
    if (r > touchRadius) r = touchRadius;
    line(te.x+touchRadius-r, te.y, te.x+r-touchRadius, te.y);
    line(te.x, te.y+touchRadius-r, te.x, te.y+r-touchRadius);
    ellipse(te.x, te.y, r, r);
  }
}

public class KeyButton
{
  private int textColor = 0;
  private int fillColor = 0;
  private int strokeColor = 0;
  private float textX, textY;
  private float touchX = -1, touchY = -1;
  private int phase = 0;
  private int touch_debounce = 0;
  private int press_debounce = 0;
  private int strokeWeight = 1;
  private color primaryColor = color(255, 255, 255);
  private color secondaryColor = color(255, 255, 255, 127);
  private color backgroundColor = color(0, 0, 0, 255);
  private color primaryTransparent = color(0, 0, 0, 1);
  private color primaryTextColor = color(0, 255, 0);
  private color secondaryTextColor = color(0, 127, 0);

  public PShape shape;
  public PShape up, down, left, right, outter;
  public String[] label = new String[4];
  public int type = 0;
  public int posX = 0;
  public int posY = 0;
  public int width = 0;
  public int height = 0;
  public int border = 0;
  public int fontSize = 18;
  public boolean noTouch = false;

  public KeyButton(int type, int width, int height, int border) {
    this.type = type;
    this.width = width;
    this.height = height;
    this.border = border;

    switch (type) {
      case UNO:
      case RECT:
        shape = createShape(RECT, 0, 0, width - border*2, height - border*2, 5);
        break;
      case DUE_H:
        shape = createShape(GROUP);
        left = createShape(RECT, 0, 0, (width - border*2)/2, height - border*2, 5);
        left.setFill(backgroundColor);
        left.setStroke(secondaryColor);
        right = createShape(RECT, (width - border*2)/2, 0, (width - border*2)/2, height - border*2, 5);
        right.setFill(backgroundColor);
        right.setStroke(secondaryColor);
        outter = createShape(RECT, 0, 0, width - border*2, height - border*2, 5);
        outter.setFill(primaryTransparent);
        outter.setStroke(primaryColor);
        outter.setStrokeWeight(1);
        shape.addChild(left);
        shape.addChild(right);
        shape.addChild(outter);
        break;
      case DUE_V:
        shape = createShape(GROUP);
        up = createShape(RECT, 0, 0, width - border*2, (height - border*2)/2, 5);
        up.setFill(backgroundColor);
        up.setStroke(secondaryColor);
        down = createShape(RECT, 0, (height - border*2)/2, width - border*2, (height - border*2)/2, 5);
        down.setFill(backgroundColor);
        down.setStroke(secondaryColor);
        outter = createShape(RECT, 0, 0, width - border*2, height - border*2, 5);
        outter.setFill(primaryTransparent);
        outter.setStroke(primaryColor);
        outter.setStrokeWeight(1);
        shape.addChild(up);
        shape.addChild(down);
        shape.addChild(outter);
        break;
      case QUATTRO:
        shape = createShape(GROUP);
        //up = createShape(RECT, 0, 0, width - border*2, (height - border*2)/3, 5);
        up = createShape(TRIANGLE, 0, 0, width - border*2, 0, (width - border*2)/2, (height - border*2)/2);
        up.setFill(backgroundColor);
        up.setStroke(secondaryColor);
        //down = createShape(RECT, 0, (height - border*2)*2/3, width - border*2, (height - border*2)/3, 5);
        down = createShape(TRIANGLE, 0, height - border*2, width - border*2, height - border*2, (width - border*2)/2, (height - border*2)/2);
        down.setFill(backgroundColor);
        down.setStroke(secondaryColor);
        //left = createShape(RECT, 0, (height - border*2)/3, (width - border*2)/2, (height - border*2)/3, 5);
        left = createShape(TRIANGLE, 0, 0, 0, height - border*2, (width - border*2)/2, (height - border*2)/2);
        left.setFill(backgroundColor);
        left.setStroke(secondaryColor);
        //right = createShape(RECT, (width - border*2)/2, (height - border*2)/3, (width - border*2)/2, (height - border*2)/3, 5);
        right = createShape(TRIANGLE, width - border*2, 0, width - border*2, height - border*2, (width - border*2)/2, (height - border*2)/2);
        right.setFill(backgroundColor);
        right.setStroke(secondaryColor);
        outter = createShape(RECT, 0, 0, width - border*2, height - border*2, 5);
        outter.setFill(primaryTransparent);
        outter.setStroke(primaryColor);
        outter.setStrokeWeight(1);
        shape.addChild(up);
        shape.addChild(down);
        shape.addChild(left);
        shape.addChild(right);
        shape.addChild(outter);
        break;
    }

    textX = width/2;
    textY = height/2 + fontSize/3;
    strokeColor = primaryColor;
    fillColor = backgroundColor;
    textColor = primaryTextColor;
  }

  // evaluate if a point is within button's area
  private boolean evalPoint(float x, float y) {
    boolean ret = true;
    switch (this.type) {
      case ELLIPSE:
        ret = ret & pow((x-posX-width/2) * 2 / (width-border*2), 2) + pow((y-posY-height/2) * 2 / (height-border*2), 2) <= 1;
        break;
      case UNO:
      case RECT:
      default:
        ret = ret & (x >= posX + border);
        ret = ret & (x <= posX + width - border);
        ret = ret & (y >= posY + border);
        ret = ret & (y <= posY + height - border);
        break;
    }
    return ret;
  }

  int timer = 0;
  int repeat = 1;
  public void draw(ArrayList<TouchEvent> teList) {
    TouchEvent te = null;
    boolean inShape = false;

    if (!noTouch) {
      // check if button is clicked by touch
      if (teList.size() > 0) {
        for (int i=0; i < teList.size(); i++) {
          te = teList.get(i);
          inShape = evalPoint(te.x, te.y);
          if (inShape) break;
        }
      }

      // set stroke and fill based on the touch event
      if ((touchX >= 0 || inShape) && te != null && te.z > pressThreshold) {
        if (fillColor != primaryColor) press_debounce++;
        else press_debounce = 0;
        
        if (press_debounce > 2) {
          te.processed = true;
          fillColor = primaryColor;
          strokeColor = backgroundColor;
          textColor = secondaryTextColor;
          press_debounce = 0;
          touch_debounce = 0;
          timer = 0;
          repeat = 1;
          phase = 0;
          
          if (touchX < 0) touchX = te.x;
          if (touchY < 0) touchY = te.y;

          if (type != UNO) {
            if (abs(te.x - touchX) - abs(te.y - touchY) > 5) {
              if (type == DUE_H || type == QUATTRO) {
                if (te.x - touchX > 5) phase = 4;
                else if (te.x - touchX < -5) phase = 3;
              }
            }
            else if (abs(te.x - touchX) - abs(te.y - touchY) < -5){
              if (type == DUE_V || type == QUATTRO) {
                if (te.y - touchY > 5) phase = 2;
                else if (te.y - touchY < -5) phase = 1;
              }
            }
          }
        }

        if (strokeColor == backgroundColor && timer <= 0) {
          timer = 20;
          repeat++;
          int id = (type == DUE_H || type == DUE_V) ? (phase + 1) % 2 : (phase + 3) % 4;
          if (type == UNO) id = 0;
          if (label[id] == "<-") {
            if (inText[0].length() > 0) {
              inText[1] = inText[0].substring(inText[0].length()-1) + inText[1];
              if (inText[0].length() > 1) inText[0] = inText[0].substring(0, inText[0].length()-1);
              else inText[0] = "";
            }
          }
          else if (label[id] == "->") {
            if (inText[1].length() > 0) {
              inText[0] = inText[0] + inText[1].substring(0, 1);
              if (inText[1].length() > 1) inText[1] = inText[1].substring(1);
              else inText[1] = "";
            }
          }
          else if (label[id] == "Space") inText[0] += " ";
          else if (label[id] == "Enter") inText[0] += "\n";
          else if (label[id] == "Backspace" && inText[0].length() > 0) inText[0] = inText[0].substring(0, inText[0].length()-1);
          else if (label[id] == "if") {
            inText[0] += "if (";
            inText[1] = ")" + inText[1];
          }
          else if (label[id] == "for") {
            inText[0] += "for (";
            inText[1] = ")" + inText[1];
          }
          else if (label[id] == "while") {
            inText[0] += "while (";
            inText[1] = ")" + inText[1];
          }
          else if (label[id] == "if") {
            inText[0] += "switch (";
            inText[1] = ")" + inText[1];
          }
          else if (label[id] == "{}") {
            inText[0] += "{";
            inText[1] = "}" + inText[1];
          }
          else inText[0] += label[id];
        }
        timer -= repeat/2;
      }
      else if ((touchX >= 0 || inShape) && te != null && te.z > touchThreshold*2) {
        if (fillColor != secondaryColor) touch_debounce++;
        else touch_debounce = 0;
        
        if (touchX < 0) touchX = te.x;
        if (touchY < 0) touchY = te.y;

        if (type != UNO) {
          if (abs(te.x - touchX) - abs(te.y - touchY) > 5) {
            if (type == DUE_H || type == QUATTRO) {
              if (te.x - touchX > 5) phase = 4;
              else if (te.x - touchX < -5) phase = 3;
            }
          }
          else if (abs(te.x - touchX) - abs(te.y - touchY) < -5){
            if (type == DUE_V || type == QUATTRO) {
              if (te.y - touchY > 5) phase = 2;
              else if (te.y - touchY < -5) phase = 1;
            }
          }
        }

        if (touch_debounce > 2) {
          strokeWeight = 3;
          te.processed = true;
          strokeColor = primaryColor;
          fillColor = secondaryColor;
          textColor = primaryTextColor;
          press_debounce = 0;
          touch_debounce = 0;
          timer = 0;
          phase = 0;
        }
      }
      else if (fillColor != backgroundColor) {
        touch_debounce++;

        if (touch_debounce > 2) {
          strokeWeight = 1;
          strokeColor = primaryColor;
          fillColor = backgroundColor;
          textColor = primaryTextColor;
          press_debounce = 0;
          timer = 0;
          touchX = -1;
          touchY = -1;
          phase = 0;
        }
      }
    }

    // draw shape
    int child = shape.getChildCount();
    if (child > 0) {
      shape.getChild(child-1).setStrokeWeight(strokeWeight);
      for (int i=0; i<shape.getChildCount()-1; i++) {
        shape.getChild(i).setFill(backgroundColor);
      }
      switch (phase) {
        case 1:
          if (type == DUE_V || type == QUATTRO) shape.getChild(0).setFill(fillColor);
          break;
        case 2:
          if (type == DUE_V || type == QUATTRO) shape.getChild(1).setFill(fillColor);
          break;
        case 3:
          if (type == DUE_H) shape.getChild(0).setFill(fillColor);
          if (type == QUATTRO) shape.getChild(2).setFill(fillColor);
          break;
        case 4:
          if (type == DUE_H) shape.getChild(1).setFill(fillColor);
          if (type == QUATTRO) shape.getChild(3).setFill(fillColor);
          break;
      }
    }
    else {
      shape.setStrokeWeight(strokeWeight);
      shape.setStroke(strokeColor);
      shape.setFill(fillColor);
    }

    shape(shape, posX + border, posY + border);

    // draw label
    fill(textColor);
    textSize(fontSize);
    textAlign(CENTER);
    switch (type) {
      case UNO:
        text(label[0], posX + textX, posY + textY);
        break;
      case DUE_H:
        text(label[0], posX + textX/2, posY + textY);
        text(label[1], posX + textX*3/2, posY + textY);
        break;
      case DUE_V:
        text(label[0], posX + textX, posY + textY/2);
        text(label[1], posX + textX, posY + textY*3/2);
        break;
      case QUATTRO:
        text(label[0], posX + textX, posY + textY/2);
        text(label[1], posX + textX, posY + textY*3/2);
        text(label[2], posX + textX/2, posY + textY);
        text(label[3], posX + textX*3/2, posY + textY);
        break;
    }

    fill(0);
  }
}