import 'dart:typed_data';
import 'dart:web_gl';

import 'package:asset_data/asset_data.dart';

import '../shader.dart';

mixin WebGlRenderingMixin {
  static const int fsize = Float32List.bytesPerElement;

  late final RenderingContext gl;
  late final Program program;
  late final ShaderSource shaderSource;
  Buffer? elementBuffer;
  Buffer? indexBuffer;
  Map<String, Buffer> buffers = <String, Buffer>{};
  bool success = true;
  final Map<String, UniformLocation> _uniforms = {};
  final Set<String> _usedUniforms = {};

  void initProgram() {
    final vShader = _createShader(WebGL.VERTEX_SHADER, shaderSource.vShader);
    if (success) {
      final fShader =
          _createShader(WebGL.FRAGMENT_SHADER, shaderSource.fShader);
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
${_uniforms.keys.map((key) => '''${key}Location = getUniformLocation('$key');''').join('\n')}
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
        gl.getProgramParameter(program, WebGL.LINK_STATUS)! as bool;
    if (linkSuccess) {
      final uniformCount =
          gl.getProgramParameter(program, WebGL.ACTIVE_UNIFORMS)! as int;
      for (var i = 0; i < uniformCount; i++) {
        final uniformName = gl.getActiveUniform(program, i).name;
        _uniforms[uniformName] = gl.getUniformLocation(program, uniformName);
      }
    } else {
      success = false;
      throw Exception(
          '''$runtimeType - Error linking program: ${gl.getProgramInfoLog(program)}''');
    }
  }

  Shader _createShader(int type, TextAsset source) {
    final shader = gl.createShader(type);
    gl
      ..shaderSource(shader, source.content)
      ..compileShader(shader);
    final compileSuccess =
        gl.getShaderParameter(shader, WebGL.COMPILE_STATUS)! as bool;
    if (!compileSuccess) {
      success = false;
      throw Exception(
          '''$runtimeType - Error compiling ${source.assetId} shader for $runtimeType: ${gl.getShaderInfoLog(shader)}''');
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
          '''Attribute $attribute not found in vertex shader for ${vShaderAsset.assetId}''');
    }
    gl
      ..bindBuffer(WebGL.ARRAY_BUFFER, buffer)
      ..bufferData(WebGL.ARRAY_BUFFER, items, usage)
      ..vertexAttribPointer(attribLocation, itemSize, WebGL.FLOAT, false, 0, 0)
      ..enableVertexAttribArray(attribLocation);
  }

  void bufferElements(
      List<Attrib> attributes, Float32List items, Uint16List indices) {
    if (elementBuffer == null) {
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
            '''Attribute ${attribute.name} not found in vertex shader for ${vShaderAsset.assetId}}''');
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
  String? get libName => null;
  void initUniformLocations();
}

class Attrib {
  final String name;
  final int size;
  const Attrib(this.name, this.size);
}
