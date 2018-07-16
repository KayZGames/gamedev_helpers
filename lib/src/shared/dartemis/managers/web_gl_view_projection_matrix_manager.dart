part of gamedev_helpers_shared;

@Generate(Manager,
    mapper: [Position, Orientation], manager: [CameraManager, TagManager])
class WebGlViewProjectionMatrixManager
    extends _$WebGlViewProjectionMatrixManager {
  Matrix4 create2dViewProjectionMatrix() {
    final playerEntity = tagManager.getEntity(playerTag);
    final p = positionMapper[playerEntity];
    return create2dViewProjectionMatrixForPosition(p.x, p.y);
  }

  Matrix4 create2dViewProjectionMatrixForPosition(double px, double py) {
    final playerEntity = tagManager.getEntity(playerTag);
    final orientation = orientationMapper[playerEntity];
    final angle = 0.0;
    final viewMatrix = Matrix4.identity();
    final projMatrix = Matrix4.identity();
    setViewMatrix(viewMatrix, Vector3(400.0 + 100 * sin(angle), 550.0, -150.0),
        Vector3(400.0, 200.0, 150.0), Vector3(0.0, 1.0, 0.0));
    setPerspectiveMatrix(projMatrix, pi / 2, 4 / 3, 1.0, 1000.0);
//    final threedViewProjextionMatrix = projMatrix * viewMatrix;
    final twodOrthographicMatrix = Matrix4.identity();
    final factor = cameraManager.width / cameraManager.height;
    var width = 800;
    var height = 600;
    if (factor > 4 / 3) {
      width = (height * factor).toInt();
    } else {
      height = width ~/ factor;
    }
    setOrthographicMatrix(twodOrthographicMatrix, px - width / 2,
        px + width / 2, py - height / 2, py + height / 2, 250.0, -250.0);
    if (cameraManager.lockCamera) {
      twodOrthographicMatrix
        ..translate(px, py)
        ..rotate(
            Vector3(0.0, 0.0, 1.0), (pi / 2 - orientation.angle) % (2 * pi))
        ..translate(-px, -py);
    }

//  return threedViewProjextionMatrix * camera.three + twodOrthographicMatrix * camera.two;
    return twodOrthographicMatrix; // * rotationMatrix;
  }
}
