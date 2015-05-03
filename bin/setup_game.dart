import 'dart:io';

import 'package:path/path.dart' as Path;
import 'package:git/git.dart';

main() async {
  await new DartemisApp().create();
}

class DartemisApp {
  String _name;
  Map<String, String> _project = <String, String>{};
  String _dir = Path.current;

  DartemisApp() {
    _name = Path.basename(_dir);
    _project = {
      "pubspec.yaml": _pubspec(),
      "README.md": _readme(),
      "web/index.html": _html(),
      "web/${_name}.dart": _main(),
      "web/${_name}.css": _css(),
      "lib/shared.dart": _shared(),
      "lib/src/shared/components.dart": _partOf('shared'),
      "lib/src/shared/systems/logic.dart": _partOf('shared'),
      "lib/client.dart": _client(),
      "lib/src/client/systems/events.dart": _partOf('client'),
      "lib/src/client/systems/rendering.dart": _partOf('client'),
      "lib/assets/img": null,
      "lib/assets/sfx": null,
      "lib/assets/shader": null,
      "assetOrigs/img/assets.tps": _texturePacker(),
      "assetOrigs/sfx": null
    };
  }

  create() async {
    _project.forEach((file, content) {
      if (content == null) {
        new Directory("${_dir}/$file").createSync(recursive: true);
      } else {
        var f = new File("${_dir}/$file");
        var dir = f.parent;
        if (!dir.existsSync()) dir.createSync(recursive: true);
        f.writeAsStringSync(content);
      }
    });
    var gitDir = await GitDir.fromExisting(Path.current);
    var result = await gitDir.runCommand(['add', '.']);
    assert(result.exitCode == 0);
    result = await gitDir.runCommand(['commit', '-am', 'autogenerated boilerplate code']);
    if (result.exitCode == 0) {
      print('Branch master initialized.');
    } else {
      print('An error occured: $result');
    }
  }

  String _pubspec() {
    return """
name: ${_name}
description: A ${_name} game
dependencies:
  browser: any
  dartemis: any
  dartemis_transformer: any
  gamedev_helpers:
#    git: https://github.com/denniskaselow/gamedev_helpers
    path: ../gamedev_helpers
  dart_to_js_script_rewriter: any
transformers:
- dart_to_js_script_rewriter
- dartemis_transformer:
    additionalLibraries:
    - gamedev_helpers/gamedev_helpers.dart
""";
  }

  String _readme() {
    return """
${_name}
===========
[Play on kaygames.github.io](http://kayzgames.github.io/${_name})
""";
  }

  String _main() {
    return """
import 'package:${_name}/client.dart';
void main() {
  new Game().start();
}
""";
  }

  String _html() {
    return """
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>${_name}</title>
    <link type="text/css" rel="stylesheet" href="${_name}.css">
  </head>
  <body>
    <div id="gamecontainer">
      <canvas id="game" width="800px" height="600px"></canvas>
      <canvas id="hud" width="800px" height="600px"></canvas>
    </div>
    <script type="application/dart" src="${_name}.dart"></script>
    <script src="packages/browser/dart.js"></script>
  </body>
</html>
""";
  }

  String _css() {
    return """
body {
  text-align: center;
}

#gamecontainer {
  position: relative;
  display: inline-block;
  width: 800px;
  height: 600px;
  margin: auto;
}

canvas {
  position: absolute;
  left: 0px;
  top: 0px;
  width: 800px;
  height: 600px;
}
""";
  }

  String _shared() {
    return """
library shared;
import 'package:gamedev_helpers/gamedev_helpers_shared.dart';
part 'src/shared/components.dart';
//part 'src/shared/systems/name.dart';
part 'src/shared/systems/logic.dart';
""";
  }

  String _client() {
    return """
library client;

import 'dart:html' hide Player, Timeline;
export 'dart:html' hide Player, Timeline;
import 'package:${_name}/shared.dart';
import 'package:gamedev_helpers/gamedev_helpers.dart';
export 'package:gamedev_helpers/gamedev_helpers.dart';
//part 'src/client/systems/name.dart';
part 'src/client/systems/events.dart';
part 'src/client/systems/rendering.dart';

class Game extends GameBase {
  CanvasElement hudCanvas;
  CanvasRenderingContext2D hudCtx;

  Game() : super.noAssets('${_name}', '#game', 800, 600, webgl: true) {
    hudCanvas = querySelector('#hud');
    hudCtx = hudCanvas.context2D;
    hudCtx
      ..textBaseline = 'top'
      ..font = '16px Verdana';
  }
  void createEntities() {
    // addEntity([Component1, Component2]);
  }
  Map<int, List<EntitySystem>> getSystems() {
    return {
      GameBase.rendering: [
        new WebGlCanvasCleaningSystem(ctx),
        new CanvasCleaningSystem(hudCanvas),
        new FpsRenderingSystem(hudCtx, fillStyle: 'white'),
      ],
      GameBase.physics: [
        // add at least one
      ]
    };
  }
}

""";
  }

  String _partOf(String lib) {
    return """
part of $lib;
""";
  }

  String _texturePacker() {
    return """
<?xml version="1.0" encoding="UTF-8"?>
<data version="1.0">
    <struct type="Settings">
        <key>fileFormatVersion</key>
        <int>3</int>
        <key>texturePackerVersion</key>
        <string>3.3.3</string>
        <key>allowRotation</key>
        <false/>
        <key>dataFormat</key>
        <string>json</string>
        <key>textureFileName</key>
        <filename>../../lib/assets/img/assets.png</filename>
        <key>dataFileNames</key>
        <map type="GFileNameMap">
            <key>data</key>
            <struct type="DataFile">
                <key>name</key>
                <filename>../../lib/assets/img/assets.json</filename>
            </struct>
        </map>
        <key>trimSpriteNames</key>
        <true/>
    </struct>
</data>
""";
  }
}
