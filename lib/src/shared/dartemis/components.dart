part of gamedev_helpers_shared;

class Sound extends Component {
  String clipName;
  Sound(this.clipName);
}

class Acceleration extends Component {
  double x, y;

  Acceleration(this.x, this.y);
}

class Velocity extends Component {
  double x, y;

  Velocity(this.x, this.y);
}

class Position extends Component {
  double x, y;

  Position(this.x, this.y);
}

class Mass extends Component {}

class Orientation extends Component {
  double angle;

  Orientation(this.angle);
}

class Particle extends Component {}

class Color extends Component {
  double r, g, b, a, l, realAlpha, realR, realG, realB;

  Color(this.r, this.g, this.b, this.a)
      : realAlpha = a,
        realR = r,
        realG = g,
        realB = b,
        l = rgbToHsl(r, g, b)[2];

  Color.fromHsl(double h, double s, this.l, this.a) {
    final rgb = hslToRgb(h, s, l);
    r = rgb[0];
    g = rgb[1];
    b = rgb[2];
    realR = r;
    realG = g;
    realB = b;
    realAlpha = a;
  }

  void setLightness(double lightness) {
    final hsl = rgbToHsl(r, g, b);
    hsl[2] = lightness;
    final rgb = hslToRgb(hsl[0], hsl[1], hsl[2]);
    r = rgb[0];
    g = rgb[1];
    b = rgb[2];
  }
}

class Renderable extends Component {
  String name;
  int maxFrames;
  double timePerFrame;
  double time;
  double scale;
  bool facesRight;
  Renderable(this.name,
      {this.maxFrames = 1,
      this.timePerFrame = 0.2,
      this.facesRight = true,
      this.time = 0.0,
      this.scale = 1.0});

  Renderable.fromRenderable(Renderable other, this.time, this.scale)
      : name = other.name,
        maxFrames = other.maxFrames,
        timePerFrame = other.timePerFrame,
        facesRight = other.facesRight;

  String get spriteName =>
      '${name}_${maxFrames - (time / timePerFrame % maxFrames).toInt() - 1}';
}

class Camera extends Component {
  double zoom;
  Camera({this.zoom = 1.0});
}
