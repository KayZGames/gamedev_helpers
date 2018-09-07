import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:git/git.dart';

Future<Null> main(List<String> args) async {
  if (args.isEmpty) {
    print('use webgl to create a project supporting WebGL');
  }
  final useWebGl = args.length == 1 && args[0] == 'webgl';
  await DartemisApp(useWebGl: useWebGl).create();
}

class DartemisApp {
  String _name;
  Map<String, String> _project = <String, String>{};
  final String _dir = path.current;

  DartemisApp({bool useWebGl = false}) {
    _name = path.basename(_dir);
    print(
        'Project $_name ${useWebGl ? 'with' : 'without'} WebGL support is being created...');
    _project = {
      "pubspec.yaml": _pubspec(),
      "build.yaml": _buildYaml(),
      "build.dev.yaml": _buildDevYaml(),
      "analysis_options.yaml": _analysisOptions(),
      ".gitignore": _gitignore(),
      "README.md": _readme(),
      "web/index.html": useWebGl ? _htmlWebGl() : _html(),
      "web/main.dart": _main(),
      "web/styles.css": useWebGl ? _cssWebGl() : _css(),
      "lib/shared.dart": _shared(),
      "lib/src/shared/components.dart": _components(),
      "lib/src/shared/systems/logic.dart": _logic(),
      "lib/client.dart": useWebGl ? _clientWebGl() : _client(),
      "lib/src/client/systems/events.dart": _events(),
      "lib/src/client/systems/rendering.dart":
          useWebGl ? _renderingWebGl() : _rendering(),
      "lib/assets/img": null,
      "lib/assets/sfx": null,
      "lib/assets/shader": null,
      "assetOrigs/img/assets.tps": _texturePacker(),
      "assetOrigs/sfx": null
    };
    if (useWebGl) {
      _project['lib/assets/shader/PositionRenderingSystem.vert'] =
          _positionRenderingSystemVert();
      _project['lib/assets/shader/PositionRenderingSystem.frag'] =
          _positionRenderingSystemFrag();
    }
  }

  Future<Null> create() async {
    _project.forEach((file, content) {
      if (content == null) {
        Directory("$_dir/$file").createSync(recursive: true);
      } else {
        final f = File("$_dir/$file");
        final dir = f.parent;
        if (!dir.existsSync()) {
          dir.createSync(recursive: true);
        }
        f.writeAsStringSync(content);
      }
    });
    await execute('pub.bat', ['get']);
    await execute('pub.bat', ['run', 'build_runner', 'build']);
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
.dart_tool/
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

.idea/
""";

  String _buildYaml() => r"""
targets:
  $default:
    builders:
      build_web_compilers|entrypoint:
        generate_for:
          - web/main.dart
        options:
          compiler: dart2js
          dart2js_args:
            - --fast-startup
            - --omit-implicit-checks
            - --trust-primitives
            - --minify
            - --no-source-maps
""";

  String _buildDevYaml() => r"""
targets:
  $default:
    builders:
      build_web_compilers|entrypoint:
        generate_for:
          - web/main.dart
        options:
          compiler: dartdevc
""";

  String _pubspec() => """
name: $_name
description: A $_name game
publish_to: none
environment:
  sdk: '>=2.0.0-dev.69 <3.0.0'
dependencies:
  dartemis:
    git:
      url: git://github.com/denniskaselow/dartemis.git
  gamedev_helpers:
    git:
      url: git://github.com/kayzgames/gamedev_helpers.git
dev_dependencies:
  build_runner: ^0.9.0
  build_web_compilers: any  
  dartemis_builder:
    git: git://github.com/denniskaselow/dartemis_builder.git
""";

  String _readme() => """
$_name
===========
[Play on kayzgames.github.io](http://kayzgames.github.io/$_name/)
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
    <script defer src="main.dart.js" type="application/javascript"></script>
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
    <script defer src="main.dart.js" type="application/javascript"></script>
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
  width: 100vw;
  height: 100vh;
  min-width: 800px;
  min-height: 450px;
  background-color: black;
  display: flex;
  justify-content: center;
  align-items: center;
}

canvas {
  display: block;
  width: 100vw;
  height: 100vh;
}
""";

  String _cssWebGl() => """
body {
  margin: 0;
  padding: 0;
  width: 100vw;
  height: 100vh;
  min-width: 800px;
  min-height: 450px;
  background-color: black;
  display: flex;
  justify-content: center;
  align-items: center;
}

#gamecontainer {
  position: relative;
  display: block;
  width: 100vw;
  height: 100vh;
}

canvas {
  position: absolute;
  left: 0;
  top: 0;
  width: 100vw;
  height: 100vh;
}
""";

  String _shared() => """
library shared;

export 'package:gamedev_helpers/gamedev_helpers_shared.dart';

export 'src/shared/components.dart';
export 'src/shared/systems/logic.dart';
""";

  String _client() => """
library client;

import 'package:$_name/shared.dart';
import 'package:gamedev_helpers/gamedev_helpers.dart';

import 'src/client/systems/events.dart';
import 'src/client/systems/rendering.dart';

class Game extends GameBase {

  Game() : super.noAssets('$_name', '#game');

  @override
  void createEntities() {
    addEntity([
      Controller(),
      Position(0.5, 0.0),
      Acceleration(0.0, 0.0),
      Velocity(0.0, 0.0),
      Mass(),
    ]);
  }

  @override
  Map<int, List<EntitySystem>> getSystems() {
    return {
      GameBase.rendering: [
        ControllerSystem(),
        ResetAccelerationSystem(),
        ControllerToActionSystem(),
        SimpleGravitySystem(),
        SimpleAccelerationSystem(),
        SimpleMovementSystem(),
        CanvasCleaningSystem(canvas),
        PositionRenderingSystem(ctx),
        FpsRenderingSystem(ctx, fillStyle: 'white'),
      ],
      GameBase.physics: [
        // add at least one
      ]
    };
  }

  @override
  void handleResize(int width, int height) {
    width = max(800, width);
    height = max(450, height);
    if (width / height > 16 / 9) {
      width = (16 * height) ~/ 9;
    } else if (width / height < 16 / 9) {
      height = (9 * width) ~/ 16;
    }
    super.handleResize(width, height);
  }
}
""";

  String _clientWebGl() => """
library client;

import 'dart:html';
import 'package:$_name/shared.dart';
import 'package:gamedev_helpers/gamedev_helpers.dart';

import 'src/client/systems/events.dart';
import 'src/client/systems/rendering.dart';

class Game extends GameBase {
  CanvasElement hudCanvas;
  CanvasRenderingContext2D hudCtx;
  DivElement container;

  Game() : super.noAssets('$_name', '#game', webgl: true) {
    container = querySelector('#gamecontainer');
    hudCanvas = querySelector('#hud');
    hudCtx = hudCanvas.context2D;
    _configureHud();
  }

  @override
  void createEntities() {
    final tagManager = TagManager();
    world.addManager(tagManager);
    world.addManager(WebGlViewProjectionMatrixManager());
    addEntity([
      Controller(),
      Position(0.0, 0.0),
      Acceleration(0.0, 0.0),
      Velocity(0.0, 0.0),
      Mass(),
    ]);

    final player = addEntity([Position(0.0, 0.0)]);
    tagManager.register(player, playerTag);
  }

  @override
  Map<int, List<EntitySystem>> getSystems() {
    return {
      GameBase.rendering: [
        ControllerSystem(),
        ResetAccelerationSystem(),
        ControllerToActionSystem(),
        SimpleGravitySystem(),
        SimpleAccelerationSystem(),
        SimpleMovementSystem(),
        WebGlCanvasCleaningSystem(gl),
        PositionRenderingSystem(gl),
        CanvasCleaningSystem(hudCanvas),
        FpsRenderingSystem(hudCtx, fillStyle: 'white'),
      ],
      GameBase.physics: [
        // add at least one
      ]
    };
  }

  @override
  void handleResize(int width, int height) {
    width = max(800, width);
    height = max(450, height);
    if (width / height > 16 / 9) {
      width = (16 * height) ~/ 9;
    } else if (width / height < 16 / 9) {
      height = (9 * width) ~/ 16;
    }
    container.style
      ..width = '\${width}px'
      ..height = '\${height}px';
    resizeCanvas(hudCanvas, width, height);
    _configureHud();
    super.handleResize(width, height);
  }

  void _configureHud() {
    hudCtx
      ..textBaseline = 'top'
      ..font = '16px Verdana';
  }
}
""";

  String _events() => """
import 'package:gamedev_helpers/gamedev_helpers.dart';
import 'package:$_name/src/shared/components.dart';

part 'events.g.dart';

@Generate(GenericInputHandlingSystem, allOf: [Controller])
class ControllerSystem extends _\$ControllerSystem {
  @override
  void processEntity(Entity entity) {
    final c = controllerMapper[entity]..reset();
    if (up) {
      if (left) {
        c.upleft = true;
      } else if (right) {
        c.upright = true;
      } else {
        c.up = true;
      }
    } else if (down) {
      if (left) {
        c.downleft = true;
      } else if (right) {
        c.downright = true;
      } else {
        c.down = true;
      }
    } else if (left) {
      c.left = true;
    } else if (right) {
      c.right = true;
    }
  }
}
""";

  String _rendering() => """
import 'dart:html';

import 'package:gamedev_helpers/gamedev_helpers.dart';

part 'rendering.g.dart';

@Generate(EntityProcessingSystem,
    allOf: const [Position], manager: const [CameraManager])
class PositionRenderingSystem extends _\$PositionRenderingSystem {

  CanvasRenderingContext2D ctx;
  PositionRenderingSystem(this.ctx);

  @override
  void processEntity(Entity entity) {
    final position = positionMapper[entity];

    ctx
      ..fillStyle = 'white'
      ..fillRect(
          position.x * cameraManager.width,
          position.y * cameraManager.height,
          0.01 * cameraManager.width,
          0.01 * cameraManager.height);
  }
}

""";
  String _renderingWebGl() => """
import 'dart:typed_data';
import 'dart:web_gl';

import 'package:gamedev_helpers/gamedev_helpers.dart';

part 'rendering.g.dart';

@Generate(
  WebGlRenderingSystem,
  allOf: [
    Position,
  ],
  manager: [
    CameraManager,
    WebGlViewProjectionMatrixManager,
  ],
)
class PositionRenderingSystem extends _\$PositionRenderingSystem {
  List<Attrib> attributes;

  Float32List items;
  Uint16List indices;

  PositionRenderingSystem(RenderingContext gl) : super(gl) {
    attributes = [Attrib('pos', 2)];
  }

  @override
  void processEntity(int index, Entity entity) {
    final position = positionMapper[entity];
    final itemOffset = index * 2 * 4;
    final indexOffset = index * 3 * 2;
    final vertexOffset = index * 4;

    items[itemOffset] = position.x * cameraManager.width;
    items[itemOffset + 1] = position.y * cameraManager.height;
    items[itemOffset + 2] = (position.x + 0.01) * cameraManager.width;
    items[itemOffset + 3] = position.y * cameraManager.height;
    items[itemOffset + 4] = position.x * cameraManager.width;
    items[itemOffset + 5] = (position.y + 0.01) * cameraManager.height;
    items[itemOffset + 6] = (position.x + 0.01) * cameraManager.width;
    items[itemOffset + 7] = (position.y + 0.01) * cameraManager.height;

    indices[indexOffset] = vertexOffset;
    indices[indexOffset + 1] = vertexOffset + 1;
    indices[indexOffset + 2] = vertexOffset + 2;
    indices[indexOffset + 3] = vertexOffset + 1;
    indices[indexOffset + 4] = vertexOffset + 3;
    indices[indexOffset + 5] = vertexOffset + 2;
  }

  @override
  void render(int length) {
    gl.uniformMatrix4fv(
        gl.getUniformLocation(program, 'viewProjectionMatrix'),
        false,
        webGlViewProjectionMatrixManager
            .create2dViewProjectionMatrix()
            .storage);

    drawTriangles(attributes, items, indices);
  }

  @override
  void updateLength(int length) {
    items = Float32List(length * 2 * 4);
    indices = Uint16List(length * 3 * 2);
  }

  @override
  String get vShaderFile => 'PositionRenderingSystem';
  @override
  String get fShaderFile => 'PositionRenderingSystem';
}
""";

  String _logic() => """
import 'package:dartemis/dartemis.dart';
import 'package:gamedev_helpers/gamedev_helpers_shared.dart';
import 'package:$_name/src/shared/components.dart';

part 'logic.g.dart';

@Generate(EntityProcessingSystem, allOf: const [Controller, Acceleration])
class ControllerToActionSystem extends _\$ControllerToActionSystem {
  final _acc = 50.0;
  final _sqrttwo = 1.4142;

  @override
  void processEntity(Entity entity) {
    final controller = controllerMapper[entity];
    final acceleration = accelerationMapper[entity];
    if (controller.up) {
      acceleration.y += _acc * world.delta;
    } else if (controller.down) {
      acceleration.y -= _acc * world.delta;
    } else if (controller.left) {
      acceleration.x -= _acc * world.delta;
    } else if (controller.right) {
      acceleration.x += _acc * world.delta;
    } else if (controller.upleft) {
      acceleration.y += _acc * world.delta / _sqrttwo;
      acceleration.x -= _acc * world.delta / _sqrttwo;
    } else if (controller.upright) {
      acceleration.y += _acc * world.delta / _sqrttwo;
      acceleration.x += _acc * world.delta / _sqrttwo;
    } else if (controller.downleft) {
      acceleration.y -= _acc * world.delta / _sqrttwo;
      acceleration.x -= _acc * world.delta / _sqrttwo;
    } else if (controller.downright) {
      acceleration.y -= _acc * world.delta / _sqrttwo;
      acceleration.x += _acc * world.delta / _sqrttwo;
    }
  }
}
""";

  String _components() => """
import 'package:dartemis/dartemis.dart';

class Controller extends Component {
  bool up, down, left, right;
  bool upleft, upright, downleft, downright;

  Controller(
      {this.up = false,
      this.down = false,
      this.left = false,
      this.right = false,
      this.upleft = false,
      this.upright = false,
      this.downleft = false,
      this.downright = false});

  void reset() {
    up = false;
    down = false;
    left = false;
    right = false;
    upleft = false;
    upright = false;
    downleft = false;
    downright = false;
  }
}
""";

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

  String _positionRenderingSystemVert() => '''
#version 300 es

uniform mat4 viewProjectionMatrix;
in vec2 pos;

void main() {
	gl_Position = viewProjectionMatrix * vec4(pos, 0.0, 1.0);
}''';

  String _positionRenderingSystemFrag() => '''
#version 300 es

precision mediump float;

out vec4 color;

void main() {
	color = vec4(1.0, 1.0, 1.0, 1.0);
}''';
}

Future<Null> execute(String exec, List<String> args) async {
  final Process process = await Process.start(exec, args);

  process.stdout
      .transform(systemEncoding.decoder)
      .transform(const LineSplitter())
      .listen((line) {
    stdout.writeln(line);
  });

  process.stderr
      .transform(systemEncoding.decoder)
      .transform(const LineSplitter())
      .listen((line) {
    stderr.writeln(line);
  });

  final exitCode = await process.exitCode;

  if (exitCode != 0) {
    throw 'Error running $exec ${args.join(' ')}';
  }
}
