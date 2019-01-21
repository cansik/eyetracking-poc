import gab.opencv.*;
import java.awt.Rectangle;
import processing.video.*;
import org.opencv.core.*;

Capture cam;

OpenCV opencv;
Rectangle[] eyes;

int inputWidth = 640;
int inputHeight = round(inputWidth * 0.75);

int viewWidth = 640;
int viewHeight = 480;

int centerPointIndex = 0;
PVector[] centerPoints = new PVector[100];

int eyeRectIndex = 0;
Rectangle[] eyeRects = new Rectangle[50];

float xPadding = 0.05;
float yPadding = 0.05;

float scaleFactor = 1.1;
int minNeighbors = 20 ;

MovingPVector center = new MovingPVector();

void setup() {
  size(1280, 720, P2D);
  pixelDensity(2);

  setupUI();

  opencv = new OpenCV(this, inputWidth, inputHeight);
  opencv.loadCascade(OpenCV.CASCADE_EYE);

  center.x = 0.5f;
  center.y = 0.5f;

  String[] cameras = Capture.list();

  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(i + ": " + cameras[i]);
    }

    cam = new Capture(this, "name=FaceTime HD Camera,size=" + inputWidth + "x" + inputHeight + ", fps=30");
    cam.start();
  }
}

void draw() {
  background(55);

  // read camera
  if (frameCount < 5)
  {
    text("starting camera...", width / 2, height / 2);
    frameRate(30);

    return;
  }

  if (cam.available()) {
    cam.read();
  }

  if (cam.width == 0 || cam.height == 0)
  {
    return;
  }

  PImage frame = cam.copy();
  detectEyes(frame);

  // draw detections and images
  image(frame, 0, 0, viewWidth, viewHeight);
  markDetections();

  renderROIs();

  // render plot
  pushMatrix();
  translate(viewWidth, viewHeight / 2);
  plotValues(width - viewWidth, viewHeight / 2);
  popMatrix();

  // render sight
  pushMatrix();
  translate(viewWidth + 350, 20);
  plotSight(200, 200);
  popMatrix();

  center.update();

  tryMouseMove();

  cp5.draw();
  surface.setTitle(String.format(getClass().getName()+ "  [fps %6.2f]", frameRate));
}

void markDetections()
{
  noFill();
  stroke(0, 255, 0);
  strokeWeight(3);

  float xratio = viewWidth / inputWidth;
  float yratio = viewHeight / inputHeight;

  for (int i = 0; i < eyes.length; i++) {
    rect(eyes[i].x * xratio, eyes[i].y * yratio, eyes[i].width * xratio, eyes[i].height * yratio);
  }
}

void detectEyes(PImage frame)
{
  opencv.loadImage(frame);

  // double scaleFactor , int minNeighbors , int flags, int minSize , int maxSize
  eyes = opencv.detect(scaleFactor, minNeighbors, 0, 0, 1000);
}

void renderROIs()
{ 
  // add eye if there is one
  if (eyes.length > 0)
  {
    // find most right
    Rectangle rightEye = eyes[0];

    for (int i = 0; i < eyes.length; i++)
    {
      if (eyes[i].x < rightEye.x)
      {
        rightEye = eyes[i];
      }
    }

    addRect(rightEye);
  }

  Rectangle eye = getAverageRectangle();

  // read ROI  
  opencv.setROI(eye.x, eye.y, eye.width, eye.height);
  //opencv.invert();
  //opencv.threshold(120);

  PVector eyeCenter = opencv.min();
  PVector normCenter = new PVector();
  normCenter.x = eyeCenter.x / eye.width;
  normCenter.y = eyeCenter.y / eye.height;

  center.target = normCenter;

  if (normCenter.x > xPadding && normCenter.x < 1.0 - xPadding)
  {
    addCenter(normCenter);
  }

  // render output
  pushMatrix();
  translate(viewWidth, 0);
  scale(4);

  PImage roi = opencv.getOutput().get(eye.x, eye.y, eye.width, eye.height);

  PVector cPos = new PVector(50, 50);
  PVector imgPos = PVector.sub(eyeCenter, cPos);
  imgPos.mult(0.5);
  imgPos = new PVector();

  image(roi, imgPos.x, imgPos.y, roi.width, roi.height);

  noFill();
  stroke(0, 255, 0);
  strokeWeight(0.25);
  ellipse(eyeCenter.x + imgPos.x, eyeCenter.y + imgPos.y, 5, 5);

  noFill();
  stroke(255, 0, 0);
  strokeWeight(0.5);
  ellipse(center.x * eye.width + imgPos.x, center.y * eye.height + imgPos.y, 15, 15);

  popMatrix();
  opencv.releaseROI();
}

void addRect(Rectangle r)
{
  eyeRects[eyeRectIndex] = r;
  eyeRectIndex = (eyeRectIndex + 1) % eyeRects.length;
}

void addCenter(PVector p)
{
  centerPoints[centerPointIndex] = p;
  centerPointIndex = (centerPointIndex + 1) % centerPoints.length;
}

void plotValues(int w, int h)
{
  fill(0);
  stroke(255);
  strokeWeight(1);
  rect(0, 0, w, h);

  // text
  fill(255);
  textSize(12);
  textAlign(CENTER, TOP);
  text("x over time", w / 2, 5);

  // center line
  noFill();
  stroke(255);
  strokeWeight(1);
  line(0, h / 2, w, h / 2);

  // xmin padding
  noFill();
  stroke(255, 255, 0, 200);
  strokeWeight(1);
  line(0, h * xPadding, w, h * xPadding);
  line(0, h * (1.0 - xPadding), w, h * (1.0 - xPadding));

  strokeWeight(1);
  stroke(0, 255, 255);

  float space = float(w) / centerPoints.length;
  beginShape();
  for (int i = 0; i < centerPoints.length; i++)
  {
    int ri = Math.floorMod(centerPointIndex - i, centerPoints.length);
    float xv = (centerPoints[ri] == null) ? 0.0f : centerPoints[ri].x;

    vertex(i * space, map(xv, 0.0, 1.0, h, 0.0));
  }
  endShape();
}

void plotSight(int w, int h)
{
  fill(0);
  stroke(255);
  strokeWeight(1);
  rect(0, 0, w, h);

  fill(255);
  textSize(12);
  textAlign(CENTER, TOP);
  text("xy-sight", w / 2, 5);

  // center line
  noFill();
  stroke(255);
  strokeWeight(1);
  line(0, h / 2, w, h / 2);
  line(w / 2, 0, w / 2, h);

  // draw trace
  int lines = 10;
  strokeWeight(1);
  beginShape();
  for (int i = 0; i < lines; i++)
  {
    int ri = Math.floorMod(centerPointIndex - i, centerPoints.length);
    float xv = (centerPoints[ri] == null) ? 0.0f : 1.0f - centerPoints[ri].x;
    float yv = (centerPoints[ri] == null) ? 0.0f : centerPoints[ri].y;

    float b =  map(i, 0, lines - 1, 20, 255);
    stroke(255, b);
    vertex(map(xv, xPadding, 1.0 - xPadding, 0.0, w), map(yv, yPadding, 1.0 - yPadding, 0.0, h));
  } 
  endShape();

  // draw center
  noFill();
  stroke(255, 0, 0);
  strokeWeight(1);
  ellipse((1.0f - center.x) * w, center.y * h, 20, 20);
}

Rectangle getAverageRectangle()
{
  Rectangle average = new Rectangle();

  int counter = 0;
  for (int i = 0; i < eyeRects.length; i++)
  {
    if (eyeRects[i] == null)
      continue;

    average.x += eyeRects[i].x;
    average.y += eyeRects[i].y;

    average.width += eyeRects[i].width;
    average.height += eyeRects[i].height;

    counter++;
  }

  if (counter < 1)
  {
    return average;
  }

  average.x /= counter;
  average.y /= counter;

  average.width /= counter;
  average.height /= counter;

  return average;
}

void keyPressed()
{
  mouseMoveOn = !mouseMoveOn;
  println("Mouse Move On: " + mouseMoveOn);
}
