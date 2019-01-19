import controlP5.*;

ControlP5 cp5;

int uiHeight;

boolean isUIInitialized = false;

void setupUI()
{
  isUIInitialized = false;
  PFont font = createFont("Helvetica", 100f);

  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);

  // change the original colors
  cp5.setColorForeground(color(255, 132, 124));
  cp5.setColorBackground(color(42, 54, 59));
  cp5.setFont(font, 14);
  cp5.setColorActive(color(255, 132, 124));

  int h = inputHeight;
  h += 50;
  cp5.addLabel("Padding")
    .setPosition(10, h);

  h += 25;
  cp5.addSlider("xPadding", 10, 150, 10, h, 100, 20)
    .setRange(0.0, 0.5)
    .setNumberOfTickMarks(11)
    .showTickMarks(false)
    .setLabel("X");

  cp5.addSlider("yPadding", 10, 150, 10 + 250, h, 100, 20)
    .setRange(0, 0.5)
    .setNumberOfTickMarks(11)
    .showTickMarks(false)
    .setLabel("Y");

  h += 50;
  cp5.addLabel("Cascade Classifier")
    .setPosition(10, h);

  h += 25;
  cp5.addSlider("scaleFactor", 10, 150, 10, h, 100, 20)
    .setRange(1.0, 2.5)
    .setNumberOfTickMarks(30)
    .showTickMarks(false)
    .setLabel("Scale Factor");

  cp5.addSlider("minNeighbors", 10, 150, 10 + 250, h, 100, 20)
    .setRange(1, 30)
    .setNumberOfTickMarks(31)
    .showTickMarks(false)
    .setLabel("Min Neighbors");
  uiHeight = h + 200;

  isUIInitialized = true;
}

public String formatTime(long millis)
{
  long second = (millis / 1000) % 60;
  long minute = (millis / (1000 * 60)) % 60;
  long hour = (millis / (1000 * 60 * 60)) % 24;

  if (minute == 0 && hour == 0 && second == 0)
    return String.format("%02dms", millis);

  if (minute == 0 && hour == 0)
    return String.format("%02ds", second);

  if (hour == 0)
    return String.format("%02dm %02ds", minute, second);

  return String.format("%02dh %02dm %02ds", hour, minute, second);
}
