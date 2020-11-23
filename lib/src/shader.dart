import 'package:aspen/aspen.dart';
import 'package:aspen_assets/aspen_assets.dart';

part 'shader.g.dart';

class ShaderSource {
  TextAsset vShader;
  TextAsset fShader;

  ShaderSource(this.vShader, this.fShader);
}

@Asset('asset:gamedev_helpers/assets/shader/')
const shaders = DirAsset<TextAsset, Shaders>(_shaders$asset);
