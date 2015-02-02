part of gamedev_helpers;

class WebGlCanvasCleaningSystem extends VoidEntitySystem {
  RenderingContext gl;

  WebGlCanvasCleaningSystem(this.gl);

  @override
  void initialize() {
    gl.clearColor(0, 0, 0, 1);
  }

  @override
  void processSystem() {
    gl.clear(RenderingContext.COLOR_BUFFER_BIT);
  }
}

abstract class WebGlRenderingSystem extends EntitySystem {
  RenderingContext gl;
  Program program;
  bool success = true;
  Map<String, Buffer> buffers = <String, Buffer>{};
  int maxLength = 0;
  ShaderSource shaderSource;

  WebGlRenderingSystem(this.gl, Aspect aspect) : super(aspect);

  @override
  void initialize() {
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

  void buffer(String attribute, Float32List items, int itemSize) {
    var buffer = buffers[attribute];
    if (null == buffer) {
      buffer = gl.createBuffer();
      buffers[attribute] = buffer;
    }
    var attribLocation = gl.getAttribLocation(program, attribute);
    gl.bindBuffer(RenderingContext.ARRAY_BUFFER, buffer);
    gl.bufferData(RenderingContext.ARRAY_BUFFER, items, RenderingContext.DYNAMIC_DRAW);
    gl.vertexAttribPointer(attribLocation, itemSize, RenderingContext.FLOAT, false, 0, 0);
    gl.enableVertexAttribArray(attribLocation);
  }

  @override
  bool checkProcessing() => success;

  void updateLength(int length);
  void processEntity(int index, Entity entity);
  void render(int length);
  String get vShaderFile => this.runtimeType.toString();
  String get fShaderFile => this.runtimeType.toString();
}
