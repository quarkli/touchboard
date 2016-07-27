final int dispWidth = 320;
final int dispHeight = 200;
final int senseWidth = 16;
final int senseHeight = 10;
final int senseScale = 10;
final int forceScale = 16;

// test and validation functions
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

class ForceMap {
  int cellX = 0;
  int cellY = 0;
  int[][] map;
}

class TouchEvent {
  float x;
  float y;
  float z;
}

void setup(){
  ArrayList<ForceMap> fmlist = new ArrayList<ForceMap>();

  //int[][] testMap = genForceMap(10, 16);
  int[][] testMap =new int[][]{
    {0, 0, 6},
    {0, 0, 0},
    {6, 0, 0}
  };
  printMap(testMap);
  println();
  lookforTouch(testMap);
}

void lookforTouch(int[][] map){
  for (int row = 0; row < map.length; row++){
    for (int col = 0; col < map[row].length; col++){
      boolean touch = true;
      float t = map[row][col];

      // ignore force lower than senseScale/4 and check if surrounded cell has higher force
      // if higher force in surrounded cells, this cell is not a centroid of force, move on to next cell
      // if no higher force in surrounded cells, copy a 3x3 array with current cell as centroid,
      // call evalForcemap() to conver it to a touch event.
      if (t > senseScale / 4) {
        if (row > 0) {
          if (col > 0 && map[row][col] <= map[row-1][col-1]) touch = false;
          if (map[row][col] <= map[row-1][col]) touch = false;
          if (col+1 < map[row].length && map[row][col] <= map[row-1][col+1]) touch = false;
        }

        if (col > 0 && map[row][col] <= map[row][col-1]) touch = false;
        if (col+1 < map[row].length && map[row][col] < map[row][col+1]) touch = false;

        if (row+1 < map.length) {
          if (col > 0 && map[row][col] < map[row+1][col-1]) touch = false;
          if (map[row][col] < map[row+1][col]) touch = false;
          if (col+1 < map[row].length && map[row][col] < map[row+1][col+1]) touch = false;
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
          println(te.x, te.y, te.z);
        }
      }
    }
  }
}

// force centroid formula: [a, b, c, d, e, ...] = sum of force of a column or row
// 2x2 map = b / (a+b)
// 3x3 map = (b/2 + c) / (a+b+c)
// 4x4 map = (b/3 + 2c/3 + d) / (a+b+c+d)
// 5x5 map = (b/4 + 2c/4 + 3d/4 + e) / (a+b+c+d+e)
// ...

// touch force formula:
// force = peak_force x (1 + log10(total_force / sense_scale));
TouchEvent evalForcemap(ForceMap fm) {
  TouchEvent te = new TouchEvent();
  int rows = fm.map.length;
  int cols = fm.map[0].length;
  float numerator = 0;
  float totalForce = 0;
  float peakForce = 0;
  float x = 0, y = 0, z = 0;
  float sum = 0;
  int leftShift = 0, rightShift = 0, offset = 0;
  ArrayList<Float> w = new ArrayList<Float>();
//printMap(fm.map);

  for (int row = 0; row < rows; row++) {
    for (int col = 0; col < cols; col++) {
      // look for the maximum force
      if (fm.map[row][col] > peakForce) peakForce = fm.map[row][col];
      // sum all force
      totalForce += fm.map[row][col];
      // sum row force
      sum += fm.map[row][col];
    }
    // Add numerator of force per row, skip first row
    if (row > 0) {
      w.add(sum);
      if (row == rows - 1 && sum == 0) rightShift = 1;
    }
    else if (sum == 0) leftShift = -1;
    sum = 0;
  }

  offset = -leftShift | rightShift;
  for (int i = 0; i < w.size(); i++) {
    numerator += w.get(i) * (w.size() - offset + i - 1) / (w.size() - offset);
  }

  y = numerator / totalForce - ((1 - offset) / 2);
  y = rightShift == 1 ? -y : y;
  numerator = 0;
  w.clear();
  leftShift = 0;
  rightShift = 0;
  offset = 0;

  for (int col = 0; col < cols; col++) {
    for (int row = 0; row < rows; row++) {
      sum += fm.map[row][col];
    }
    // Add numerator of force per col, skip first col
    if (col > 0) {
      w.add(sum);
      if (col == cols -1 && sum == 0) rightShift = 1;
    }
    else if (sum == 0) leftShift = -1;
    sum = 0;
  }

  offset = -leftShift | rightShift;
  for (int i = 0; i < w.size(); i++) {
    numerator += w.get(i) * (w.size() - offset + i - 1) / (w.size() - offset);
  }

  x = numerator / totalForce - ((1 - offset) / 2);
  x = rightShift == 1? -x : x;
  z = peakForce * (1 + log(totalForce / senseScale) / log(10));
//println(x, y);
  te.x = map(fm.cellX + x, 0, 1, 0, dispWidth / senseWidth);
  te.y = map(fm.cellY + y, 0, 1, 0, dispHeight / senseHeight);
  te.z = map(z, 0, senseScale, 0, forceScale);

  return te;
}