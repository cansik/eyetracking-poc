import java.awt.*;

int mouseSpeed = 5;
float mouseShift = 0.075;
boolean mouseMoveOn = false;

void tryMouseMove()
{  
  if (!mouseMoveOn)
    return;

  // left
  if (center.x < 0.5 - mouseShift)
    moveMouse(mouseSpeed, 0);

  // right
  if (center.x > 0.5 + mouseShift)
    moveMouse(-mouseSpeed, 0);

  // up
  if (center.y < 0.5 - mouseShift)
    moveMouse(0, -mouseSpeed);

  // down
  if (center.y > 0.5 + mouseShift)
    moveMouse(0, mouseSpeed);
}

void moveMouse(int dx, int dy)
{
  try {
    PointerInfo a = MouseInfo.getPointerInfo();
    int x = a.getLocation().x + dx;
    int y = a.getLocation().y + dy;

    Robot robot = new Robot();
    robot.mouseMove(x, y);
  } 
  catch (AWTException e) {
  }
}
