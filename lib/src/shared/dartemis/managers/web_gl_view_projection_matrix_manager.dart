part of gamedev_helpers_shared;

@Generate(
  Manager,
  mapper: [
    Position,
    Camera,
  ],
  manager: [
    CameraManager,
  ],
)
class WebGlViewProjectionMatrixManager
    extends _$WebGlViewProjectionMatrixManager {
  final int maxBaseViewRange;
  WebGlViewProjectionMatrixManager(this.maxBaseViewRange);
  Matrix4 create2dViewProjectionMatrix(Entity cameraEntity) {
    final position = positionMapper[cameraEntity];
    final camera = cameraMapper[cameraEntity];
    return create2dViewProjectionMatrixForPosition(
        position.x, position.y, camera.zoom);
  }

  Matrix4 create2dViewProjectionMatrixForPosition(
      double x, double y, double zoom) {
    final twodOrthographicMatrix = Matrix4.identity();
    final width = cameraManager.width * zoom;
    final height = cameraManager.height * zoom;
    setOrthographicMatrix(twodOrthographicMatrix, x - width / 2, x + width / 2,
        y - height / 2, y + height / 2, 1, -1);
    return twodOrthographicMatrix;
  }
}
