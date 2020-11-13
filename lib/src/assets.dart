import 'package:aspen/aspen.dart';
import 'package:aspen_assets/aspen_assets.dart';

part 'assets.g.dart';

@Asset('asset:gamedev_helpers/lib/assets/shader/')
const shaders = DirAsset<TextAsset, Shaders>(_shaders$asset);
