part of gamedev_helpers;

class WebGlCanvasCleaningSystem extends VoidEntitySystem {
  RenderingContext gl;

  WebGlCanvasCleaningSystem(this.gl);

  @override
  void initialize() {
    gl.clearColor(0.0, 0.0, 0.0, 1.0);
  }

  @override
  void processSystem() {
    gl.clear(WebGL.COLOR_BUFFER_BIT | WebGL.DEPTH_BUFFER_BIT);
  }
}

mixin _WebGlRenderingMixin {
  static const int fsize = Float32List.bytesPerElement;

  RenderingContext gl;
  Program program;
  ShaderSource shaderSource;
  Buffer elementBuffer;
  Buffer indexBuffer;
  Map<String, Buffer> buffers = <String, Buffer>{};
  bool success = true;
  final Map<String, UniformLocation> _uniforms = {};
  final Set<String> _usedUniforms = {};

  void initProgram() {
    final vShader =
        _createShader(WebGL.VERTEX_SHADER, shaderSource.vShader, 'vertex');
    if (success) {
      final fShader = _createShader(
          WebGL.FRAGMENT_SHADER, shaderSource.fShader, 'fragment');
      if (success) {
        _createProgram(vShader, fShader);
      }
    }
    _initUniformLocations();
  }

  void _initUniformLocations() {
    initUniformLocations();
    if (_uniforms.isNotEmpty) {
      throw Exception('''
unused uniforms: ${_uniforms.keys} in $runtimeType
use this:
${_uniforms.keys.map((key) => '${key}Location = getUniformLocation(\'$key\');').join('\n')}
''');
    }
  }

  UniformLocation getUniformLocation(String name) {
    if (_usedUniforms.contains(name)) {
      throw Exception('uniform $name already initialized in $runtimeType');
    }
    final result = _uniforms.remove(name);
    if (result == null) {
      throw Exception(
          '''tried to get uniform location of unknown name $name from ${_uniforms.keys} in $runtimeType''');
    }
    _usedUniforms.add(name);
    return result;
  }

  void _createProgram(Shader vShader, Shader fShader) {
    program = gl.createProgram();
    gl
      ..attachShader(program, vShader)
      ..attachShader(program, fShader)
      ..linkProgram(program);
    final linkSuccess =
        gl.getProgramParameter(program, WebGL.LINK_STATUS) as bool;
    if (linkSuccess) {
      final uniformCount =
          gl.getProgramParameter(program, WebGL.ACTIVE_UNIFORMS) as int;
      for (var i = 0; i < uniformCount; i++) {
        final uniformName = gl.getActiveUniform(program, i).name;
        _uniforms[uniformName] = gl.getUniformLocation(program, uniformName);
      }
    } else {
      print(
          '''$runtimeType - Error linking program: ${gl.getProgramInfoLog(program)}''');
      success = false;
    }
  }

  Shader _createShader(int type, String source, String shaderType) {
    final shader = gl.createShader(type);
    gl
      ..shaderSource(shader, source)
      ..compileShader(shader);
    final compileSuccess =
        gl.getShaderParameter(shader, WebGL.COMPILE_STATUS) as bool;
    if (!compileSuccess) {
      // will only kind of work in dev mode and not at all when minified
      print(
          '''$runtimeType - Error compiling $shaderType shader for $runtimeType: ${gl.getShaderInfoLog(shader)}''');
      success = false;
    }
    return shader;
  }

  void buffer(String attribute, Float32List items, int itemSize,
      {int usage = WebGL.DYNAMIC_DRAW}) {
    var buffer = buffers[attribute];
    if (null == buffer) {
      buffer = gl.createBuffer();
      buffers[attribute] = buffer;
    }
    final attribLocation = gl.getAttribLocation(program, attribute);
    if (attribLocation == -1) {
      throw ArgumentError(
          'Attribute $attribute not found in vertex shader for $runtimeType}');
    }
    gl
      ..bindBuffer(WebGL.ARRAY_BUFFER, buffer)
      ..bufferData(WebGL.ARRAY_BUFFER, items, usage)
      ..vertexAttribPointer(attribLocation, itemSize, WebGL.FLOAT, false, 0, 0)
      ..enableVertexAttribArray(attribLocation);
  }

  void bufferElements(
      List<Attrib> attributes, Float32List items, Uint16List indices) {
    if (null == elementBuffer) {
      elementBuffer = gl.createBuffer();
      indexBuffer = gl.createBuffer();
    }
    gl
      ..bindBuffer(WebGL.ARRAY_BUFFER, elementBuffer)
      ..bufferData(WebGL.ARRAY_BUFFER, items, WebGL.DYNAMIC_DRAW);
    var offset = 0;
    var elementsPerItem = 0;
    for (final attribute in attributes) {
      elementsPerItem += attribute.size;
    }
    for (final attribute in attributes) {
      final attribLocation = gl.getAttribLocation(program, attribute.name);
      if (attribLocation == -1) {
        throw ArgumentError(
            '''Attribute ${attribute.name} not found in vertex shader for $runtimeType}''');
      }
      gl
        ..vertexAttribPointer(attribLocation, attribute.size, WebGL.FLOAT,
            false, fsize * elementsPerItem, fsize * offset)
        ..enableVertexAttribArray(attribLocation);
      offset += attribute.size;
    }
    gl
      ..bindBuffer(WebGL.ELEMENT_ARRAY_BUFFER, indexBuffer)
      ..bufferData(WebGL.ELEMENT_ARRAY_BUFFER, indices, WebGL.DYNAMIC_DRAW);
  }

  void drawTriangles(List<Attrib> attributes, Float32List items,
      Uint16List indices, int length) {
    bufferElements(attributes, items, indices);
    gl.drawElements(WebGL.TRIANGLES, length, WebGL.UNSIGNED_SHORT, 0);
  }

  void drawPoints(List<Attrib> attributes, Float32List items,
      Uint16List indices, int length) {
    bufferElements(attributes, items, indices);
    gl.drawElements(WebGL.POINTS, length, WebGL.UNSIGNED_SHORT, 0);
  }

  TextAsset get vShaderAsset;
  TextAsset get fShaderAsset;
  String get libName => null;
  void initUniformLocations();
}

class Attrib {
  final String name;
  final int size;
  const Attrib(this.name, this.size);
}

abstract class WebGlRenderingSystem extends EntitySystem
    with _WebGlRenderingMixin {
  int maxLength = 0;

  WebGlRenderingSystem(RenderingContext gl, Aspect aspect) : super(aspect) {
    this.gl = gl;
  }

  @override
  void initialize() {
    initProgram();
  }

  @override
  void processEntities(Iterable<int> entities) {
    final length = entities.length;
    if (length > 0) {
      gl.useProgram(program);
      if (length > maxLength) {
        updateLength(length);
        maxLength = length;
      }
      var index = 0;
      for (final entity in entities) {
        if (processEntity(index, entity)) {
          index++;
        }
      }
      render(index);
    }
  }

  @override
  bool checkProcessing() => success;

  void updateLength(int length);
  bool processEntity(int index, int entity);
  void render(int length);
}

abstract class VoidWebGlRenderingSystem extends VoidEntitySystem
    with _WebGlRenderingMixin {
  VoidWebGlRenderingSystem(RenderingContext gl) {
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

@Generate(
  WebGlRenderingSystem,
  allOf: [
    Position,
    Particle,
    Color,
  ],
  manager: [
    ViewProjectionMatrixManager,
    TagManager,
    CameraManager,
  ],
)
class ParticleRenderingSystem extends _$ParticleRenderingSystem {
  Float32List positions;
  Float32List colors;
  Float32List radius;

  UniformLocation uViewProjectionLocation;

  ParticleRenderingSystem(RenderingContext gl) : super(gl);

  @override
  bool processEntity(int index, int entity) {
    final p = positionMapper[entity];
    final c = colorMapper[entity];

    final pOffset = index * 2;
    final cOffset = index * 4;

    positions[pOffset] = p.x;
    positions[pOffset + 1] = p.y;
    radius[index] = 1.0 / cameraManager.scalingFactor;

    colors[cOffset] = c.r;
    colors[cOffset + 1] = c.g;
    colors[cOffset + 2] = c.b;
    colors[cOffset + 3] = c.a;

    return true;
  }

  @override
  void render(int length) {
    final cameraEntity = tagManager.getEntity(cameraTag);
    gl.uniformMatrix4fv(
        uViewProjectionLocation,
        false,
        viewProjectionMatrixManager
            .create2dViewProjectionMatrix(cameraEntity)
            .storage);

    buffer('aPosition', positions, 2);
    buffer('aRadius', radius, 1);
    buffer('aColor', colors, 4);

    gl.drawArrays(WebGL.POINTS, 0, length);
  }

  @override
  void updateLength(int length) {
    positions = Float32List(length * 3);
    radius = Float32List(length);
    colors = Float32List(length * 4);
  }

  @override
  TextAsset get vShaderAsset => vShaderParticleRendering;

  @override
  TextAsset get fShaderAsset => fShaderParticleRendering;

  @override
  String get libName => 'gamedev_helpers';

  @override
  void initUniformLocations() {
    uViewProjectionLocation = getUniformLocation('uViewProjection');
  }
}

@Generate(
  WebGlRenderingSystem,
  allOf: [Orientation, Renderable],
  mapper: [
    Position,
    Camera,
  ],
  manager: [
    TagManager,
    ViewProjectionMatrixManager,
  ],
)
abstract class WebGlSpriteRenderingSystem extends _$WebGlSpriteRenderingSystem {
  SpriteSheet sheet;

  List<Attrib> attributes = [
    const Attrib('aPosition', 2),
    const Attrib('aTexCoord', 2)
  ];
  Float32List values;
  Uint16List indices;

  WebGlSpriteRenderingSystem(RenderingContext gl, this.sheet, Aspect aspect)
      : super(gl, aspect);

  @override
  void initialize() {
    super.initialize();

    final texture = gl.createTexture();
    final uTexture = gl.getUniformLocation(program, 'uTexture');

    gl
      ..useProgram(program)
      ..pixelStorei(WebGL.UNPACK_FLIP_Y_WEBGL, 0)
      ..activeTexture(WebGL.TEXTURE0)
      ..bindTexture(WebGL.TEXTURE_2D, texture)
      ..texParameteri(WebGL.TEXTURE_2D, WebGL.TEXTURE_MIN_FILTER, WebGL.LINEAR)
      ..texParameteri(
          WebGL.TEXTURE_2D, WebGL.TEXTURE_WRAP_S, WebGL.CLAMP_TO_EDGE)
      ..texImage2D(WebGL.TEXTURE_2D, 0, WebGL.RGBA, WebGL.RGBA,
          WebGL.UNSIGNED_BYTE, sheet.image)
      ..uniform1i(uTexture, 0)
      ..uniform2f(gl.getUniformLocation(program, 'uSize'), sheet.image.width,
          sheet.image.height);
  }

  @override
  bool processEntity(int index, int entity) {
    final p = getPosition(entity);
    final o = orientationMapper[entity];
    final r = renderableMapper[entity];
    final sprite = sheet.sprites[r._spriteName];
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
    values[index * 16] =
        p.x + dstLeft * cos(o.angle + bottomLeftAngle) / cos(bottomLeftAngle);
    values[index * 16 + 1] =
        p.y + dstBottom * sin(o.angle + bottomLeftAngle) / sin(bottomLeftAngle);
    values[index * 16 + 2] = left;
    values[index * 16 + 3] = bottom;

    final bottomRightAngle = atan2(dstBottom, dstRight);
    values[index * 16 + 4] = p.x +
        dstRight * cos(o.angle + bottomRightAngle) / cos(bottomRightAngle);
    values[index * 16 + 5] = p.y +
        dstBottom * sin(o.angle + bottomRightAngle) / sin(bottomRightAngle);
    values[index * 16 + 6] = right;
    values[index * 16 + 7] = bottom;

    final topLeftAngle = atan2(dstTop, dstLeft);
    values[index * 16 + 8] =
        p.x + dstLeft * cos(o.angle + topLeftAngle) / cos(topLeftAngle);
    values[index * 16 + 9] =
        p.y + dstTop * sin(o.angle + topLeftAngle) / sin(topLeftAngle);
    values[index * 16 + 10] = left;
    values[index * 16 + 11] = top;

    final topRightAngle = atan2(dstTop, dstRight);
    values[index * 16 + 12] =
        p.x + dstRight * cos(o.angle + topRightAngle) / cos(topRightAngle);
    values[index * 16 + 13] =
        p.y + dstTop * sin(o.angle + topRightAngle) / sin(topRightAngle);
    values[index * 16 + 14] = right;
    values[index * 16 + 15] = top;

    indices[index * 6] = index * 4;
    indices[index * 6 + 1] = index * 4 + 2;
    indices[index * 6 + 2] = index * 4 + 3;
    indices[index * 6 + 3] = index * 4;
    indices[index * 6 + 4] = index * 4 + 3;
    indices[index * 6 + 5] = index * 4 + 1;

    return true;
  }

  Position getPosition(int entity) => positionMapper[entity];

  @override
  void render(int length) {
    final cameraEntity = tagManager.getEntity(cameraTag);
    bufferElements(attributes, values, indices);

    gl
      ..uniformMatrix4fv(
          gl.getUniformLocation(program, 'uViewProjection'),
          false,
          viewProjectionMatrixManager
              .create2dViewProjectionMatrix(cameraEntity)
              .storage)
      ..drawElements(WebGL.TRIANGLES, length * 6, WebGL.UNSIGNED_SHORT, 0);
  }

  @override
  void updateLength(int length) {
    values = Float32List(length * 4 * 2 * 2);
    indices = Uint16List(length * 6);
  }

  @override
  TextAsset get vShaderAsset => vShaderSpriteRendering;

  @override
  TextAsset get fShaderAsset => fShaderSpriteRendering;

  @override
  String get libName => 'gamedev_helpers';
}
