class MovingPVector extends PVector
{
  PVector target = new PVector();
  float alpha = 0.05f;

  void update()
  {
    PVector delta = PVector.sub(target, this);
    delta.mult(alpha);
    this.add(delta);
  }
}
