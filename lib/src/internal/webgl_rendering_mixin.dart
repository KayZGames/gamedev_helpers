import 'dart:js_interop';
import 'dart:typed_data';

import 'package:asset_data/asset_data.dart';
import 'package:web/web.dart' hide Float32List;

import '../shader.dart';

mixin WebGlRenderingMixin {
  static const int fsize = Float32List.bytesPerElement;

  late final WebGL2RenderingContext gl;
  late final WebGLProgram program;
  late final ShaderSource shaderSource;
  WebGLBuffer? elementBuffer;
  WebGLBuffer? indexBuffer;
  Map<String, WebGLBuffer> buffers = <String, WebGLBuffer>{};
  bool success = true;
  final Map<String, WebGLUniformLocation> _uniforms = {};
  final Set<String> _usedUniforms = {};

  void initProgram() {
    final vShader = _createShader(
      WebGLRenderingContext.VERTEX_SHADER,
      shaderSource.vShader,
    );
    if (success) {
      final fShader = _createShader(
        WebGLRenderingContext.FRAGMENT_SHADER,
        shaderSource.fShader,
      );
      if (success) {
        _createProgram(vShader, fShader);
      }
    }
    _initUniformLocations();
  }

  void _initUniformLocations() {
    initUniformLocations();
    if (_uniforms.isNotEmpty) {
      throw Exception(
        '''
unused uniforms: ${_uniforms.keys} in $runtimeType
use this:
${_uniforms.keys.map((key) => '''${key}Location = getUniformLocation('$key');''').join('\n')}
''',
      );
    }
  }

  WebGLUniformLocation getUniformLocation(String name) {
    if (_usedUniforms.contains(name)) {
      throw Exception('uniform $name already initialized in $runtimeType');
    }
    final result = _uniforms.remove(name);
    if (result == null) {
      throw Exception(
        '''tried to get uniform location of unknown name $name from ${_uniforms.keys} in $runtimeType''',
      );
    }
    _usedUniforms.add(name);
    return result;
  }

  void _createProgram(WebGLShader vShader, WebGLShader fShader) {
    program = gl.createProgram()!;
    gl
      ..attachShader(program, vShader)
      ..attachShader(program, fShader)
      ..linkProgram(program);
    final linkSuccess = gl
        .getProgramParameter(
          program,
          WebGLRenderingContext.LINK_STATUS,
        )
        .dartify()! as bool;
    if (linkSuccess) {
      final uniformCount = gl
          .getProgramParameter(
            program,
            WebGLRenderingContext.ACTIVE_UNIFORMS,
          )
          .dartify()! as double;
      for (var i = 0; i < uniformCount; i++) {
        final uniformName = gl.getActiveUniform(program, i)!.name;
        _uniforms[uniformName] = gl.getUniformLocation(program, uniformName)!;
      }
    } else {
      success = false;
      throw Exception(
        '''$runtimeType - Error linking program: ${gl.getProgramInfoLog(program)}''',
      );
    }
  }

  WebGLShader _createShader(int type, TextAsset source) {
    final shader = gl.createShader(type)!;
    gl
      ..shaderSource(shader, source.content)
      ..compileShader(shader);
    final compileSuccess = gl
        .getShaderParameter(
          shader,
          WebGLRenderingContext.COMPILE_STATUS,
        )
        .dartify()! as bool;
    if (!compileSuccess) {
      success = false;
      throw Exception(
        '''$runtimeType - Error compiling ${source.assetId} shader for $runtimeType: ${gl.getShaderInfoLog(shader)}''',
      );
    }
    return shader;
  }

  void buffer(
    String attribute,
    Float32List items,
    int itemSize, {
    int usage = WebGLRenderingContext.DYNAMIC_DRAW,
  }) {
    var buffer = buffers[attribute];
    if (null == buffer) {
      buffer = gl.createBuffer();
      buffers[attribute] = buffer!;
    }
    final attribLocation = gl.getAttribLocation(program, attribute);
    if (attribLocation == -1) {
      throw ArgumentError(
        '''Attribute $attribute not found in vertex shader for ${vShaderAsset.assetId}''',
      );
    }
    gl
      ..bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, buffer)
      ..bufferData(WebGLRenderingContext.ARRAY_BUFFER, items.toJS, usage)
      ..enableVertexAttribArray(attribLocation)
      ..vertexAttribPointer(
        attribLocation,
        itemSize,
        WebGLRenderingContext.FLOAT,
        false,
        0,
        0,
      );
  }

  void bufferElements(
    List<Attrib> attributes,
    Float32List items,
    Uint16List indices,
  ) {
    if (elementBuffer == null) {
      elementBuffer = gl.createBuffer();
      indexBuffer = gl.createBuffer();
      gl
        ..bindBuffer(WebGLRenderingContext.ARRAY_BUFFER, elementBuffer)
        ..bindBuffer(WebGLRenderingContext.ELEMENT_ARRAY_BUFFER, indexBuffer);
    }
    var offset = 0;
    var elementsPerItem = 0;
    for (final attribute in attributes) {
      elementsPerItem += attribute.size;
    }
    for (final attribute in attributes) {
      final attribLocation = attribute._location ??
          (attribute._location = gl.getAttribLocation(program, attribute.name));
      if (attribLocation == -1) {
        throw ArgumentError(
          '''Attribute ${attribute.name} not found in vertex shader for ${vShaderAsset.assetId}} (may be unused)''',
        );
      }
      gl
        ..enableVertexAttribArray(attribLocation)
        ..vertexAttribPointer(
          attribLocation,
          attribute.size,
          WebGLRenderingContext.FLOAT,
          false,
          fsize * elementsPerItem,
          fsize * offset,
        );
      offset += attribute.size;
    }
    gl
      ..bufferData(
        WebGLRenderingContext.ARRAY_BUFFER,
        items.toJS,
        WebGLRenderingContext.DYNAMIC_DRAW,
      )
      ..bufferData(
        WebGLRenderingContext.ELEMENT_ARRAY_BUFFER,
        indices.toJS,
        WebGLRenderingContext.DYNAMIC_DRAW,
      );
  }

  void drawTriangles(
    List<Attrib> attributes,
    Float32List items,
    Uint16List indices,
    int length,
  ) {
    bufferElements(attributes, items, indices);
    gl.drawElements(
      WebGLRenderingContext.TRIANGLES,
      length,
      WebGLRenderingContext.UNSIGNED_SHORT,
      0,
    );
  }

  void drawPoints(
    List<Attrib> attributes,
    Float32List items,
    Uint16List indices,
    int length,
  ) {
    bufferElements(attributes, items, indices);
    gl.drawElements(
      WebGLRenderingContext.POINTS,
      length,
      WebGLRenderingContext.UNSIGNED_SHORT,
      0,
    );
  }

  TextAsset get vShaderAsset;
  TextAsset get fShaderAsset;
  String? get libName => null;
  void initUniformLocations();
}

class Attrib {
  final String name;
  final int size;
  int? _location;
  Attrib(this.name, this.size);
}
