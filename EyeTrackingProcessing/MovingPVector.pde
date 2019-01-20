class MovingPVector extends PVector
{
  PVector target = new PVector();
  float alpha = 0.1f;

  void update()
  {
    PVector delta = PVector.sub(target, this);
    delta.mult(alpha);
    this.add(delta);
  }
}
