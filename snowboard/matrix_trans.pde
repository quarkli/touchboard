/*
  Author: Quark Li
  quarkli@gmail.com
  MIT License
*/

final int drawWidth = 360;
final int drawHeight = 480;
final int sensorWidth = 10;
final int sensorHeight = 16;
final int touchRadius = 25;
final int touchThreshold = 16;
final int pressThreshold = 160;

//**************************************
//Start of Test and Validation functions
//**************************************
int[][] genForceMap(int r, int c) {
  int[][] map = new int[r][c];

  for (int i = 0; i < r; i++) {
    for (int j = 0; j < c; j++) {
      int x = 0;
      float y = randomGaussian();
      if (y > 0.5) x = int(random(10)); 
      map[i][j] = x;
    }
  }

  return map;
}

void printMap(int[][] map) {
    for (int i = 0; i < map.length; i++){
      String c = "";
      for (int j = 0; j < map[i].length; j++){
        print(c);
        print(map[i][j]);
        c = ", ";
      }
      println();
    }
}
//**************************************
//End of Test and Validation functions
//**************************************

class ForceMap {
  int cellX = 0;
  int cellY = 0;
  int[][] map;
}

class TouchEvent {
  float x;
  float y;
  float z;
  boolean processed = false;
  //Point origin;
  //Point mark;
  //Point current;
  //float force;
}

//class Point {
//  float x;
//  float y;
//}

ArrayList<TouchEvent> lookforTouch(int[][] map){
  ArrayList<TouchEvent> teList = new ArrayList<TouchEvent>();

  for (int row = 0; row < map.length; row++){
    for (int col = 0; col < map[row].length; col++){
      boolean touch = true;
      float t = map[row][col];

      // ignore force lower than touchThreshold/2 and check if surrounded cell has higher force
      // if higher force in surrounded cells, this cell is not a centroid of force, move on to next cell
      // if no higher force in surrounded cells, copy a 3x3 array with current cell as centroid,
      // call evalForcemap() to conver it to a touch event.
      if (t > touchThreshold/2) {
        if (row > 0) {
          if (col > 0 && t <= map[row-1][col-1]) touch = false;
          if (t <= map[row-1][col]) touch = false;
          if (col+1 < map[row].length && t <= map[row-1][col+1]) touch = false;
        }

        if (col > 0 && t <= map[row][col-1]) touch = false;
        if (col+1 < map[row].length && t < map[row][col+1]) touch = false;

        if (row+1 < map.length) {
          if (col > 0 && t < map[row+1][col-1]) touch = false;
          if (t < map[row+1][col]) touch = false;
          if (col+1 < map[row].length && t < map[row+1][col+1]) touch = false;
        }

        if (touch) {
          int rows = 3;
          int cols = 3;
          int[][] tmap = new int[rows][cols];

          for (int i = 0; i < rows; i++){
            for (int j = 0; j < cols; j++){
              int force = 0;
              try {
                force = map[row + i - 1][col + j - 1];
              } catch (Exception e) {}
              tmap[i][j] = force;
            }
          }

          ForceMap fm = new ForceMap();
          fm.cellX = col;
          fm.cellY = row;
          fm.map = tmap;

          TouchEvent te = evalForcemap(fm);
          //println(te.x, te.y, te.z);
          TouchEvent evt = new TouchEvent();
          evt.x = map(drawHeight-touchRadius-te.y, 0, drawHeight, 0, drawHeight + touchRadius);
          evt.y = map(te.x, 0, drawWidth, 0, drawWidth + touchRadius);
          evt.z = te.z;
          teList.add(evt);
        }
      }
    }
  }
  
  return teList;
}


// evalForcemap() takes a 3x3 force matrix and convert it to a x, y, z force event
//
// force centroid formula:
// [a, b, c] = sum of force of a column or row
// x = (b/2 + c) / (a+b+c), x >= 0, x <=1
// x is the distance from the leftmost or topmost poinit.
//
// touch force formula:
// force = peakForce * log(totalForce) / log(peakForce)
TouchEvent evalForcemap(ForceMap fm) {
  TouchEvent te = new TouchEvent();
  int rows = fm.map.length;
  int cols = fm.map[0].length;
  float numerator = 0;
  float totalForce = 0;
  float peakForce = fm.map[1][1];
  float x = 0, y = 0, z = 0;
  float sum = 0;
  ArrayList<Float> w = new ArrayList<Float>();

  for (int row = 0; row < rows; row++) {
    for (int col = 0; col < cols; col++) {
      // sum all force
      totalForce += fm.map[row][col];
      // sum row force
      sum += fm.map[row][col];
    }
    // Add numerator of force per row, skip first row
    if (row > 0) w.add(sum);
    sum = 0;
  }

  for (int i = 0; i < w.size(); i++) {
    numerator += w.get(i) * (w.size() - 1 + i) / w.size();
  }

  y = numerator / totalForce;

  // reset parameters
  numerator = 0;
  w.clear();

  for (int col = 0; col < cols; col++) {
    for (int row = 0; row < rows; row++) {
      sum += fm.map[row][col];
    }
    // Add numerator of force per col, skip first col
    if (col > 0) w.add(sum);
    sum = 0;
  }

  for (int i = 0; i < w.size(); i++) {
    numerator += w.get(i) * (w.size() - 1 + i) / w.size();
  }
  x = numerator / totalForce;
  z = totalForce; //peakForce * log(totalForce) / log(peakForce);

  //println(x, y, z, peakForce);
  te.x = map(fm.cellX - 1 + x * 2, 0, 1, 0, drawWidth / sensorWidth);
  te.y = map(fm.cellY - 1 + y * 2, 0, 1, 0, drawHeight / sensorHeight);
  te.z = z;

  return te;
}