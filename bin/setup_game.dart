import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:git/git.dart';

Future<Null> main(List<String> args) async {
  final useWebGl = args.length == 1 && args[0] == 'webgl';
  await new DartemisApp(useWebGl: useWebGl).create();
}

class DartemisApp {
  String _name;
  Map<String, String> _project = <String, String>{};
  final String _dir = path.current;

  DartemisApp({bool useWebGl: false}) {
    _name = path.basename(_dir);
    _project = {
      "pubspec.yaml": _pubspec(),
      "analysis_options.yaml": _analysisOptions(),
      ".gitignore": _gitignore(),
      "README.md": _readme(),
      "web/index.html": useWebGl ? _htmlWebGl() : _html(),
      "web/main.dart": _main(),
      "web/styles.css": useWebGl ? _cssWebGl() : _css(),
      "lib/shared.dart": _shared(),
      "lib/src/shared/components.dart": _components(),
      "lib/src/shared/systems/logic.dart": _emptyString(),
      "lib/client.dart": useWebGl ? _clientWebGl() : _client(),
      "lib/src/client/systems/events.dart": _events(),
      "lib/src/client/systems/rendering.dart": _emptyString(),
      "lib/assets/img": null,
      "lib/assets/sfx": null,
      "lib/assets/shader": null,
      "assetOrigs/img/assets.tps": _texturePacker(),
      "assetOrigs/sfx": null
    };
  }

  Future<Null> create() async {
    _project.forEach((file, content) {
      if (content == null) {
        new Directory("$_dir/$file").createSync(recursive: true);
      } else {
        final f = new File("$_dir/$file");
        final dir = f.parent;
        if (!dir.existsSync()) {
          dir.createSync(recursive: true);
        }
        f.writeAsStringSync(content);
      }
    });
    final gitDir = await GitDir.fromExisting(path.current);
    var result = await gitDir.runCommand(['add', '.']);
    assert(result.exitCode == 0);
    result = await gitDir
        .runCommand(['commit', '-am', 'autogenerated boilerplate code']);
    if (result.exitCode == 0) {
      print('Branch master initialized.');
    } else {
      print('An error occured: $result');
    }
  }

  String _analysisOptions() => """
analyzer:
  strong-mode: true
  errors:
    unused_element: error
    unused_import: error
    unused_local_variable: error
    dead_code: error
linter:
  rules:
    # http://dart-lang.github.io/linter/lints/options/options.html
    - always_declare_return_types
    - annotate_overrides
    - avoid_empty_else
    - avoid_init_to_null
    - avoid_return_types_on_setters
    - camel_case_types
    - constant_identifier_names
    - empty_constructor_bodies
    - hash_and_equals
    - implementation_imports
    - library_names
    - library_prefixes
    - non_constant_identifier_names
    - one_member_abstracts
    - package_api_docs
    - package_names
    - package_prefixed_library_names
    - prefer_is_not_empty
    - slash_for_doc_comments
    - sort_constructors_first
    - sort_unnamed_constructors_first
    - super_goes_last
    - type_annotate_public_apis
    - type_init_formals
    - unnecessary_brace_in_string_interps
    - unnecessary_getters_setters
""";

  String _gitignore() => """
# See https://www.dartlang.org/tools/private-files.html

# Files and directories created by pub
.buildlog
.packages
.project
.pub/
build/
**/packages/

# Files created by dart2js
# (Most Dart developers will use pub build to compile Dart, use/modify these 
#  rules if you intend to use dart2js directly
#  Convention is to use extension '.dart.js' for Dart compiled to Javascript to
#  differentiate from explicit Javascript files)
*.dart.js
*.part.js
*.js.deps
*.js.map
*.info.json

# Directory created by dartdoc
doc/api/

# (Library packages only! Remove pattern if developing an application package)
.idea/
""";

  String _pubspec() => """
name: $_name
description: A $_name game
publish_to: none
dependencies:
  browser: ^0.10.0+2
  dartemis:
    git:
      url: git://github.com/denniskaselow/dartemis.git
      ref: feature/ddc
  dartemis_transformer:
    git:
      url: git://github.com/denniskaselow/dartemis_transformer.git
      ref: feature/ddc
  gamedev_helpers:
    git:
      url: git://github.com/kayzgames/gamedev_helpers.git
      ref: feature/ddc
  dart_to_js_script_rewriter: ^1.0.3
transformers:
- dart_to_js_script_rewriter
- dartemis_transformer:
    additionalLibraries:
    - gamedev_helpers/gamedev_helpers.dart
""";

  String _readme() => """
$_name
===========
[Play on kayzgames.github.io](http://kayzgames.github.io/$_name)
""";

  String _main() => """
import 'package:$_name/client.dart';

void main() {
  new Game().start();
}
""";

  String _html() => """
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$_name</title>
    <link rel="stylesheet" href="styles.css">
    <script defer src="main.dart" type="application/dart"></script>
    <script defer src="packages/browser/dart.js"></script>
  </head>
  <body>
    <canvas id="game"></canvas>
  </body>
</html>
""";

  String _htmlWebGl() => """
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$_name</title>
    <link rel="stylesheet" href="styles.css">
    <script defer src="main.dart" type="application/dart"></script>
    <script defer src="packages/browser/dart.js"></script>
  </head>
  <body>
    <div id="gamecontainer">
      <canvas id="game" width="800px" height="600px"></canvas>
      <canvas id="hud" width="800px" height="600px"></canvas>
    </div>
  </body>
</html>
""";

  String _css() => """
body {
  margin: 0;
  padding: 0;
}

canvas {
  display: block;
  min-width: 800px;
  width: 100vw;
  min-height: 600px;
  height: 100vh;
}
""";

  String _cssWebGl() => """
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

  String _shared() => """
library shared;

import 'package:gamedev_helpers/gamedev_helpers_shared.dart';

import 'src/shared/components.dart';
import 'src/shared/systems/logic.dart';
""";

  String _client() => """
library client;

import 'package:$_name/shared.dart';
import 'package:gamedev_helpers/gamedev_helpers.dart';
import 'package:templatetest/src/shared/components.dart';

import 'src/client/systems/events.dart';
import 'src/client/systems/rendering.dart';

class Game extends GameBase {

  Game() : super.noAssets('$_name', '#game');

  @override
  void createEntities() {
    addEntity([new Controller()]);
  }

  @override
  Map<int, List<EntitySystem>> getSystems() {
    return {
      GameBase.rendering: [
        new ControllerSystem(),
        new CanvasCleaningSystem(canvas),
        new FpsRenderingSystem(ctx, fillStyle: 'black'),
      ],
      GameBase.physics: [
        // add at least one
      ]
    };
  }

  @override
  void handleResize(int width, int height) {
    width = max(800, width);
    height = max(600, height);
    super.handleResize(width, height);
  }
}
""";

  String _clientWebGl() => """
library client;

import 'dart:html';
import 'package:$_name/shared.dart';
import 'package:gamedev_helpers/gamedev_helpers.dart';
import 'package:templatetest/src/shared/components.dart';

import 'src/client/systems/events.dart';
import 'src/client/systems/rendering.dart';

class Game extends GameBase {
  CanvasElement hudCanvas;
  CanvasRenderingContext2D hudCtx;

  Game() : super.noAssets('$_name', '#game', webgl: true) {
    hudCanvas = querySelector('#hud');
    hudCtx = hudCanvas.context2D;
    hudCtx
      ..textBaseline = 'top'
      ..font = '16px Verdana';
  }

  @override
  void createEntities() {
    addEntity([new Controller()]);
  }

  @override
  Map<int, List<EntitySystem>> getSystems() {
    return {
      GameBase.rendering: [
        new ControllerSystem(),
        new WebGlCanvasCleaningSystem(gl),
        new CanvasCleaningSystem(hudCanvas),
        new FpsRenderingSystem(hudCtx, fillStyle: 'white'),
      ],
      GameBase.physics: [
        // add at least one
      ]
    };
  }

  @override
  void handleResize(int width, int height) {
    width = max(800, width);
    height = max(600, height);
    super.handleResize(width, height);
  }
}
""";

  String _events() => """
import 'package:gamedev_helpers/gamedev_helpers.dart';
import 'package:templatetest/src/shared/components.dart';

class ControllerSystem extends GenericInputHandlingSystem {
  Mapper<Controller> cm;

  ControllerSystem() : super(new Aspect.forAllOf([Controller]));

  @override
  void processEntity(Entity entity) {
    final c = cm[entity];
    if (up) {
      c.up = true;
    } else if (down) {
      c.down = true;
    }

    if (left) {
      c.left = true;
    } else if (right) {
      c.right = true;
    }
  }
}
""";

  String _components() => """
import 'package:dartemis/dartemis.dart';

class Controller extends Component {
  bool up, down, left, right;
  
  Controller(
      {this.up: false, this.down: false, this.left: false, this.right: false});
}
""";

  String _emptyString() => '';

  String _texturePacker() => """
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
