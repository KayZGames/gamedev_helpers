import 'package:asset_data/asset_data.dart';

part 'shader.g.dart';

class ShaderSource {
  TextAsset vShader;
  TextAsset fShader;

  ShaderSource(this.vShader, this.fShader);
}

@Asset('asset:gamedev_helpers/assets/shader/')
const ghShaders = DirAsset<TextAsset, GhShaders>(_ghShaders$asset);
