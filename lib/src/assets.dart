import 'package:aspen/aspen.dart';
import 'package:aspen_assets/aspen_assets.dart';

part 'assets.g.dart';

@Asset('asset:gamedev_helpers/lib/assets/shader/ParticleRenderingSystem.frag')
const TextAsset fShaderParticleRendering =
    TextAsset(text: _fShaderParticleRendering$content);
@Asset('asset:gamedev_helpers/lib/assets/shader/ParticleRenderingSystem.vert')
const TextAsset vShaderParticleRendering =
    TextAsset(text: _vShaderParticleRendering$content);
@Asset('asset:gamedev_helpers/lib/assets/shader/SpriteRenderingSystem.frag')
const TextAsset fShaderSpriteRendering =
    TextAsset(text: _fShaderSpriteRendering$content);
@Asset('asset:gamedev_helpers/lib/assets/shader/SpriteRenderingSystem.vert')
const TextAsset vShaderSpriteRendering =
    TextAsset(text: _vShaderSpriteRendering$content);
