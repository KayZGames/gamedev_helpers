part of gamedev_helpers;

class WebGlCanvasCleaningSystem extends VoidEntitySystem {
  RenderingContext2 gl;

  WebGlCanvasCleaningSystem(this.gl);

  @override
  void initialize() {
    gl.clearColor(0.0, 0.0, 0.0, 1.0);
  }

  @override
  void processSystem() {
    gl.clear(
        RenderingContext2.COLOR_BUFFER_BIT | RenderingContext2.DEPTH_BUFFER_BIT);
  }
}

abstract class WebGlRenderingMixin {
  static const int fsize = Float32List.BYTES_PER_ELEMENT;

  RenderingContext2 gl;
  Program program;
  ShaderSource shaderSource;
  Buffer elementBuffer;
  Buffer indexBuffer;
  Map<String, Buffer> buffers = <String, Buffer>{};
  bool success = true;

  void initProgram() {
    final vShader =
        _createShader(RenderingContext.VERTEX_SHADER, shaderSource.vShader);
    final fShader =
        _createShader(RenderingContext.FRAGMENT_SHADER, shaderSource.fShader);

    _createProgram(vShader, fShader);
  }

  void _createProgram(Shader vShader, Shader fShader) {
    program = gl.createProgram();
    gl
      ..attachShader(program, vShader)
      ..attachShader(program, fShader)
      ..linkProgram(program);
    final linkSuccess =
        gl.getProgramParameter(program, RenderingContext2.LINK_STATUS);
    if (!linkSuccess) {
      print(
          '$runtimeType - Error linking program: ${gl.getProgramInfoLog(program)}');
      success = false;
    }
  }

  Shader _createShader(int type, String source) {
    final shader = gl.createShader(type);
    gl
      ..shaderSource(shader, source)
      ..compileShader(shader);
    final compileSuccess =
        gl.getShaderParameter(shader, RenderingContext2.COMPILE_STATUS);
    if (!compileSuccess) {
      print(
          '$runtimeType - Error compiling shader: ${gl.getShaderInfoLog(shader)}');
      success = false;
    }
    return shader;
  }

  void buffer(String attribute, Float32List items, int itemSize,
      {int usage: DYNAMIC_DRAW}) {
    var buffer = buffers[attribute];
    if (null == buffer) {
      buffer = gl.createBuffer();
      buffers[attribute] = buffer;
    }
    final attribLocation = gl.getAttribLocation(program, attribute);
    gl
      ..bindBuffer(RenderingContext.ARRAY_BUFFER, buffer)
      ..bufferData(RenderingContext.ARRAY_BUFFER, items, usage)
      ..vertexAttribPointer(
          attribLocation, itemSize, RenderingContext2.FLOAT, false, 0, 0)
      ..enableVertexAttribArray(attribLocation);
  }

  void bufferElements(
      List<Attrib> attributes, Float32List items, List<int> indices) {
    if (null == elementBuffer) {
      elementBuffer = gl.createBuffer();
      indexBuffer = gl.createBuffer();
    }
    gl
      ..bindBuffer(RenderingContext.ARRAY_BUFFER, elementBuffer)
      ..bufferData(
          RenderingContext2.ARRAY_BUFFER, items, RenderingContext2.DYNAMIC_DRAW);
    int offset = 0;
    int elementsPerItem = 0;
    for (Attrib attribute in attributes) {
      elementsPerItem += attribute.size;
    }
    for (Attrib attribute in attributes) {
      final attribLocation = gl.getAttribLocation(program, attribute.name);
      gl
        ..vertexAttribPointer(
            attribLocation,
            attribute.size,
            RenderingContext2.FLOAT,
            false,
            fsize * elementsPerItem,
            fsize * offset)
        ..enableVertexAttribArray(attribLocation);
      offset += attribute.size;
    }
    gl
      ..bindBuffer(RenderingContext.ELEMENT_ARRAY_BUFFER, indexBuffer)
      ..bufferData(RenderingContext.ELEMENT_ARRAY_BUFFER, indices,
          RenderingContext2.DYNAMIC_DRAW);
  }

  String get vShaderFile;
  String get fShaderFile;
  String get libName => null;
}

class Attrib {
  final String name;
  final int size;
  const Attrib(this.name, this.size);
}

abstract class WebGlRenderingSystem extends EntitySystem
    with WebGlRenderingMixin {
  int maxLength = 0;

  WebGlRenderingSystem(RenderingContext2 gl, Aspect aspect) : super(aspect) {
    this.gl = gl;
  }

  @override
  void initialize() {
    initProgram();
  }

  @override
  void processEntities(Iterable<Entity> entities) {
    final length = entities.length;
    if (length > 0) {
      gl.useProgram(program);
      if (length > maxLength) {
        updateLength(length);
        maxLength = length;
      }
      var index = 0;
      entities.forEach((entity) {
        processEntity(index++, entity);
      });
      render(length);
    }
  }

  @override
  bool checkProcessing() => success;

  void updateLength(int length);
  void processEntity(int index, Entity entity);
  void render(int length);
}

abstract class VoidWebGlRenderingSystem extends VoidEntitySystem
    with WebGlRenderingMixin {
  VoidWebGlRenderingSystem(RenderingContext2 gl) {
    this.gl = gl;
  }

  @override
  void initialize() {
    initProgram();
  }

  @override
  void processSystem() {
    gl.useProgram(program);
    render();
  }

  void render();
}

class ParticleRenderingSystem extends WebGlRenderingSystem {
  Mapper<Position> pm;
  Mapper<Color> cm;
  WebGlViewProjectionMatrixManager vpmm;
  TagManager tm;

  Float32List positions;
  Float32List colors;

  ParticleRenderingSystem(RenderingContext2 gl)
      : super(gl, new Aspect.forAllOf([Position, Particle, Color]));

  @override
  void processEntity(int index, Entity entity) {
    final p = pm[entity];
    final c = cm[entity];

    final pOffset = index * 2;
    final cOffset = index * 4;

    positions[pOffset] = p.x;
    positions[pOffset + 1] = p.y;

    colors[cOffset] = c.r;
    colors[cOffset + 1] = c.g;
    colors[cOffset + 2] = c.b;
    colors[cOffset + 3] = c.a;
  }

  @override
  void render(int length) {
    gl.uniformMatrix4fv(gl.getUniformLocation(program, 'uViewProjection'),
        false, vpmm.create2dViewProjectionMatrix().storage);

    buffer('aPosition', positions, 2);
    buffer('aColor', colors, 4);

    gl.drawArrays(POINTS, 0, length);
  }

  @override
  void updateLength(int length) {
    positions = new Float32List(length * 2);
    colors = new Float32List(length * 4);
  }

  @override
  String get vShaderFile => 'ParticleRenderingSystem';

  @override
  String get fShaderFile => 'ParticleRenderingSystem';

  @override
  String get libName => 'gamedev_helpers';
}

abstract class WebGlSpriteRenderingSystem extends WebGlRenderingSystem {
  Mapper<Position> pm;
  Mapper<Orientation> om;
  Mapper<Renderable> rm;
  TagManager tm;
  WebGlViewProjectionMatrixManager vpmm;

  SpriteSheet sheet;

  List<Attrib> attributes = [
    const Attrib('aPosition', 2),
    const Attrib('aTexCoord', 2)
  ];
  Float32List values;
  Uint16List indices;

  WebGlSpriteRenderingSystem(RenderingContext2 gl, this.sheet, Aspect aspect)
      : super(gl, aspect..allOf([Orientation, Renderable]));

  @override
  void initialize() {
    super.initialize();

    final texture = gl.createTexture();
    final uTexture = gl.getUniformLocation(program, 'uTexture');

    gl
      ..useProgram(program)
      ..pixelStorei(UNPACK_FLIP_Y_WEBGL, 0)
      ..activeTexture(TEXTURE0)
      ..bindTexture(TEXTURE_2D, texture)
      ..texParameteri(TEXTURE_2D, TEXTURE_MIN_FILTER, LINEAR)
      ..texParameteri(TEXTURE_2D, TEXTURE_WRAP_S, CLAMP_TO_EDGE)
      ..texImage2D(TEXTURE_2D, 0, RGBA, RGBA, UNSIGNED_BYTE, sheet.image)
      ..uniform1i(uTexture, 0)
      ..uniform2f(gl.getUniformLocation(program, 'uSize'), sheet.image.width,
          sheet.image.height);
  }

  @override
  void processEntity(int index, Entity entity) {
    final p = getPosition(entity);
    final o = om[entity];
    final r = rm[entity];
    final sprite = sheet.sprites[r.name];
    final dst = sprite.dst;
    final src = sprite.src;
    double right;
    double left;
    int dstLeft;
    int dstRight;
    if (r.facesRight) {
      left = src.left.toDouble() + 1.0;
      right = src.right.toDouble() - 1.0;
      dstLeft = (dst.left * r.scale).toInt();
      dstRight = (dst.right * r.scale).toInt();
    } else {
      right = src.left.toDouble() + 1.0;
      left = src.right.toDouble() - 1.0;
      dstLeft = (-dst.right * r.scale).toInt();
      dstRight = (-dst.left * r.scale).toInt();
    }
    final dstTop = (dst.top * r.scale).toInt();
    final dstBottom = (dst.bottom * r.scale).toInt();

    final bottom = src.bottom.toDouble();
    final top = src.top.toDouble();

    final bottomLeftAngle = atan2(dstBottom, dstLeft);
    values[index * 16] = p.x + dstLeft * cos(o.angle + bottomLeftAngle)/cos(bottomLeftAngle);
    values[index * 16 + 1] = p.y + dstBottom * sin(o.angle + bottomLeftAngle)/sin(bottomLeftAngle);
    values[index * 16 + 2] = left;
    values[index * 16 + 3] = bottom;

    final bottomRightAngle = atan2(dstBottom, dstRight);
    values[index * 16 + 4] = p.x + dstRight * cos(o.angle + bottomRightAngle)/cos(bottomRightAngle);
    values[index * 16 + 5] = p.y + dstBottom * sin(o.angle + bottomRightAngle)/sin(bottomRightAngle);
    values[index * 16 + 6] = right;
    values[index * 16 + 7] = bottom;

    final topLeftAngle = atan2(dstTop, dstLeft);
    values[index * 16 + 8] = p.x + dstLeft * cos(o.angle + topLeftAngle)/cos(topLeftAngle);
    values[index * 16 + 9] = p.y + dstTop * sin(o.angle + topLeftAngle)/sin(topLeftAngle);
    values[index * 16 + 10] = left;
    values[index * 16 + 11] = top;

    final topRightAngle = atan2(dstTop, dstRight);
    values[index * 16 + 12] = p.x + dstRight * cos(o.angle + topRightAngle)/cos(topRightAngle);
    values[index * 16 + 13] = p.y + dstTop * sin(o.angle + topRightAngle)/sin(topRightAngle);
    values[index * 16 + 14] = right;
    values[index * 16 + 15] = top;

    indices[index * 6] = index * 4;
    indices[index * 6 + 1] = index * 4 + 2;
    indices[index * 6 + 2] = index * 4 + 3;
    indices[index * 6 + 3] = index * 4;
    indices[index * 6 + 4] = index * 4 + 3;
    indices[index * 6 + 5] = index * 4 + 1;
  }

  Position getPosition(Entity entity) => pm[entity];

  @override
  void render(int length) {
    bufferElements(attributes, values, indices);

    gl
      ..uniformMatrix4fv(gl.getUniformLocation(program, 'uViewProjection'),
          false, create2dViewProjectionMatrix().storage)
      ..drawElements(TRIANGLES, length * 6, UNSIGNED_SHORT, 0);
  }

  Matrix4 create2dViewProjectionMatrix() => vpmm.create2dViewProjectionMatrix();

  @override
  void updateLength(int length) {
    values = new Float32List(length * 4 * 2 * 2);
    indices = new Uint16List(length * 6);
  }

  @override
  String get vShaderFile => 'SpriteRenderingSystem';

  @override
  String get fShaderFile => 'SpriteRenderingSystem';

  @override
  String get libName => 'gamedev_helpers';
}
