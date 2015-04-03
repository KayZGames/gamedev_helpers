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
    gl.clear(RenderingContext.COLOR_BUFFER_BIT | RenderingContext.DEPTH_BUFFER_BIT);
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
    var vShader = _createShader(RenderingContext.VERTEX_SHADER, shaderSource.vShader);
    var fShader = _createShader(RenderingContext.FRAGMENT_SHADER, shaderSource.fShader);

    _createProgram(vShader, fShader);
  }

  void _createProgram(Shader vShader, Shader fShader) {
    program = gl.createProgram();
    gl.attachShader(program, vShader);
    gl.attachShader(program, fShader);
    gl.linkProgram(program);
    var linkSuccess = gl.getProgramParameter(program, RenderingContext.LINK_STATUS);
    if (!linkSuccess) {
      print('${this.runtimeType} - Error linking program: ${gl.getProgramInfoLog(program)}');
      success = false;
    }
  }

  Shader _createShader(int type, String source) {
    var shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    var compileSuccess = gl.getShaderParameter(shader, RenderingContext.COMPILE_STATUS);
    if (!compileSuccess) {
      print('${this.runtimeType} - Error compiling shader: ${gl.getShaderInfoLog(shader)}');
      success = false;
    }
    return shader;
  }

  void buffer(String attribute, Float32List items, int itemSize, {int usage: DYNAMIC_DRAW }) {
    var buffer = buffers[attribute];
    if (null == buffer) {
      buffer = gl.createBuffer();
      buffers[attribute] = buffer;
    }
    var attribLocation = gl.getAttribLocation(program, attribute);
    gl.bindBuffer(RenderingContext.ARRAY_BUFFER, buffer);
    gl.bufferData(RenderingContext.ARRAY_BUFFER, items, usage);
    gl.vertexAttribPointer(attribLocation, itemSize, RenderingContext.FLOAT, false, 0, 0);
    gl.enableVertexAttribArray(attribLocation);
  }

  void bufferElements(List<Attrib> attributes, Float32List items, List<int> indices) {
    if (null == elementBuffer) {
      elementBuffer = gl.createBuffer();
      indexBuffer = gl.createBuffer();
    }
    gl.bindBuffer(RenderingContext.ARRAY_BUFFER, elementBuffer);
    gl.bufferData(RenderingContext.ARRAY_BUFFER, items, RenderingContext.DYNAMIC_DRAW);
    int offset = 0;
    int elementsPerItem = 0;
    for (Attrib attribute in attributes) {
      elementsPerItem += attribute.size;
    }
    for (Attrib attribute in attributes) {
      var attribLocation = gl.getAttribLocation(program, attribute.name);
      gl.vertexAttribPointer(attribLocation, attribute.size, RenderingContext.FLOAT, false, fsize * elementsPerItem, fsize * offset);
      gl.enableVertexAttribArray(attribLocation);
      offset += attribute.size;
    }
    gl.bindBuffer(RenderingContext.ELEMENT_ARRAY_BUFFER, indexBuffer);
    gl.bufferData(RenderingContext.ELEMENT_ARRAY_BUFFER, indices, RenderingContext.DYNAMIC_DRAW);
  }

  String get vShaderFile;
  String get fShaderFile;
}

class Attrib {
  final String name;
  final int size;
  const Attrib(this.name, this.size);
}

abstract class WebGlRenderingSystem extends EntitySystem with WebGlRenderingMixin {
  RenderingContext gl;
  int maxLength = 0;

  WebGlRenderingSystem(this.gl, Aspect aspect) : super(aspect);

  @override
  void initialize() {
    initProgram();
  }

  @override
  void processEntities(Iterable<Entity> entities) {
    var length = entities.length;
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

abstract class VoidWebGlRenderingSystem extends VoidEntitySystem with WebGlRenderingMixin {
  RenderingContext gl;

  VoidWebGlRenderingSystem(this.gl);

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
