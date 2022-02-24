import 'dart:math';
import 'dart:typed_data';
import 'dart:web_gl';

import 'package:asset_data/asset_data.dart';
import 'package:dartemis/dartemis.dart';
import 'package:gamedev_helpers_core/gamedev_helpers_core.dart';

import '../../internal/webgl_rendering_mixin.dart';
import '../../shader.dart';
import '../../sprite_sheet.dart';
import '../components.dart';

export '../../internal/webgl_rendering_mixin.dart' show Attrib;

part 'rendering_webgl.g.dart';

class WebGlCanvasCleaningSystem extends VoidEntitySystem {
  RenderingContext2 gl;

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
  late Float32List positions;
  late Float32List colors;
  late Float32List radius;

  late UniformLocation uViewProjectionLocation;

  ParticleRenderingSystem(RenderingContext2 gl) : super(gl);

  @override
  bool processEntity(int index, int entity) {
    final position = positionMapper[entity];
    final color = colorMapper[entity];

    final pOffset = index * 2;
    final cOffset = index * 4;

    positions[pOffset] = position.x;
    positions[pOffset + 1] = position.y;
    radius[index] = 1.0 / cameraManager.scalingFactor;

    colors[cOffset] = color.r;
    colors[cOffset + 1] = color.g;
    colors[cOffset + 2] = color.b;
    colors[cOffset + 3] = color.a;

    return true;
  }

  @override
  void render(int length) {
    final cameraEntity = tagManager.getEntity(cameraTag)!;
    gl.uniformMatrix4fv(
      uViewProjectionLocation,
      false,
      viewProjectionMatrixManager
          .create2dViewProjectionMatrix(cameraEntity)
          .storage,
    );

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
  TextAsset get vShaderAsset =>
      ghShaders[GhShaders.particleRenderingSystem$vert];

  @override
  TextAsset get fShaderAsset =>
      ghShaders[GhShaders.particleRenderingSystem$vert];

  @override
  String get libName => 'gamedev_helpers';

  @override
  void initUniformLocations() {
    uViewProjectionLocation = getUniformLocation('uViewProjection');
  }
}

@Generate(
  WebGlRenderingSystem,
  allOf: [
    Orientation,
    Renderable,
  ],
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
  late Float32List values;
  late Uint16List indices;

  WebGlSpriteRenderingSystem(RenderingContext2 gl, this.sheet, Aspect aspect)
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
        WebGL.TEXTURE_2D,
        WebGL.TEXTURE_WRAP_S,
        WebGL.CLAMP_TO_EDGE,
      )
      ..texImage2D(
        WebGL.TEXTURE_2D,
        0,
        WebGL.RGBA,
        WebGL.RGBA,
        WebGL.UNSIGNED_BYTE,
        sheet.image,
      )
      ..uniform1i(uTexture, 0)
      ..uniform2f(
        gl.getUniformLocation(program, 'uSize'),
        sheet.image.width!,
        sheet.image.height!,
      );
  }

  @override
  bool processEntity(int index, int entity) {
    final position = getPosition(entity);
    final orientation = orientationMapper[entity];
    final renderable = renderableMapper[entity];
    final sprite = renderable.sprite;
    final dst = sprite.dst;
    final src = sprite.src;
    double right;
    double left;
    int dstLeft;
    int dstRight;
    if (renderable.facesRight) {
      left = src.left.toDouble() + 1.0;
      right = src.right.toDouble() - 1.0;
      dstLeft = (dst.left * renderable.scale).toInt();
      dstRight = (dst.right * renderable.scale).toInt();
    } else {
      right = src.left.toDouble() + 1.0;
      left = src.right.toDouble() - 1.0;
      dstLeft = (-dst.right * renderable.scale).toInt();
      dstRight = (-dst.left * renderable.scale).toInt();
    }
    final dstTop = (dst.top * renderable.scale).toInt();
    final dstBottom = (dst.bottom * renderable.scale).toInt();

    final bottom = src.bottom.toDouble();
    final top = src.top.toDouble();

    final bottomLeftAngle = atan2(dstBottom, dstLeft);
    values[index * 16] = position.x +
        dstLeft *
            cos(orientation.angle + bottomLeftAngle) /
            cos(bottomLeftAngle);
    values[index * 16 + 1] = position.y +
        dstBottom *
            sin(orientation.angle + bottomLeftAngle) /
            sin(bottomLeftAngle);
    values[index * 16 + 2] = left;
    values[index * 16 + 3] = bottom;

    final bottomRightAngle = atan2(dstBottom, dstRight);
    values[index * 16 + 4] = position.x +
        dstRight *
            cos(orientation.angle + bottomRightAngle) /
            cos(bottomRightAngle);
    values[index * 16 + 5] = position.y +
        dstBottom *
            sin(orientation.angle + bottomRightAngle) /
            sin(bottomRightAngle);
    values[index * 16 + 6] = right;
    values[index * 16 + 7] = bottom;

    final topLeftAngle = atan2(dstTop, dstLeft);
    values[index * 16 + 8] = position.x +
        dstLeft * cos(orientation.angle + topLeftAngle) / cos(topLeftAngle);
    values[index * 16 + 9] = position.y +
        dstTop * sin(orientation.angle + topLeftAngle) / sin(topLeftAngle);
    values[index * 16 + 10] = left;
    values[index * 16 + 11] = top;

    final topRightAngle = atan2(dstTop, dstRight);
    values[index * 16 + 12] = position.x +
        dstRight * cos(orientation.angle + topRightAngle) / cos(topRightAngle);
    values[index * 16 + 13] = position.y +
        dstTop * sin(orientation.angle + topRightAngle) / sin(topRightAngle);
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
    final cameraEntity = tagManager.getEntity(cameraTag)!;
    bufferElements(attributes, values, indices);

    gl
      ..uniformMatrix4fv(
        gl.getUniformLocation(program, 'uViewProjection'),
        false,
        viewProjectionMatrixManager
            .create2dViewProjectionMatrix(cameraEntity)
            .storage,
      )
      ..drawElements(WebGL.TRIANGLES, length * 6, WebGL.UNSIGNED_SHORT, 0);
  }

  @override
  void updateLength(int length) {
    values = Float32List(length * 4 * 2 * 2);
    indices = Uint16List(length * 6);
  }

  @override
  TextAsset get vShaderAsset => ghShaders[GhShaders.spriteRenderingSystem$vert];

  @override
  TextAsset get fShaderAsset => ghShaders[GhShaders.spriteRenderingSystem$frag];

  @override
  String get libName => 'gamedev_helpers';
}
