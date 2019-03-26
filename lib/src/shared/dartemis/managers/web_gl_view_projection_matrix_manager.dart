part of gamedev_helpers_shared;

@Generate(Manager,
    mapper: [Position, Orientation], manager: [CameraManager, TagManager])
class WebGlViewProjectionMatrixManager
    extends _$WebGlViewProjectionMatrixManager {
  final int maxBaseViewRange;
  WebGlViewProjectionMatrixManager(this.maxBaseViewRange);
  Matrix4 create2dViewProjectionMatrix() {
    final cameraEntity = tagManager.getEntity(cameraTag);
    final p = positionMapper[cameraEntity];
    return create2dViewProjectionMatrixForPosition(p.x, p.y);
  }

  Matrix4 create2dViewProjectionMatrixForPosition(double px, double py) {
    final cameraEntity = tagManager.getEntity(cameraTag);
    final orientation = orientationMapper[cameraEntity];
    final twodOrthographicMatrix = Matrix4.identity();
    final width = cameraManager.width * cameraManager.gameZoom;
    final height = cameraManager.height * cameraManager.gameZoom;
    setOrthographicMatrix(twodOrthographicMatrix, px - width / 2,
        px + width / 2, py - height / 2, py + height / 2, 1, -1);
    if (cameraManager.lockCamera) {
      twodOrthographicMatrix
        ..translate(px, py)
        ..rotate(Vector3(0, 0, 1), (pi / 2 - orientation.angle) % (2 * pi))
        ..translate(-px, -py);
    }
    return twodOrthographicMatrix; // * rotationMatrix;
  }
}
