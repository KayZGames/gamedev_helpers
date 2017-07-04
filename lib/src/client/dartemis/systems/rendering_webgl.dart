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
    gl.clear(
        RenderingContext.COLOR_BUFFER_BIT | RenderingContext.DEPTH_BUFFER_BIT);
  }
}

abstract class WebGlRenderingMixin {
  static const int fsize = Float32List.BYTES_PER_ELEMENT;

  RenderingContext gl;
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
        gl.getProgramParameter(program, RenderingContext.LINK_STATUS);
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
        gl.getShaderParameter(shader, RenderingContext.COMPILE_STATUS);
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
          attribLocation, itemSize, RenderingContext.FLOAT, false, 0, 0)
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
          RenderingContext.ARRAY_BUFFER, items, RenderingContext.DYNAMIC_DRAW);
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
            RenderingContext.FLOAT,
            false,
            fsize * elementsPerItem,
            fsize * offset)
        ..enableVertexAttribArray(attribLocation);
      offset += attribute.size;
    }
    gl
      ..bindBuffer(RenderingContext.ELEMENT_ARRAY_BUFFER, indexBuffer)
      ..bufferData(RenderingContext.ELEMENT_ARRAY_BUFFER, indices,
          RenderingContext.DYNAMIC_DRAW);
  }

  String get vShaderFile;
  String get fShaderFile;
}

class Attrib {
  final String name;
  final int size;
  const Attrib(this.name, this.size);
}

abstract class WebGlRenderingSystem extends EntitySystem
    with WebGlRenderingMixin {
  int maxLength = 0;

  WebGlRenderingSystem(RenderingContext gl, Aspect aspect) : super(aspect) {
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
