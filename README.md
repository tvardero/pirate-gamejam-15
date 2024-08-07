# Sunfall

Originally made for [Pirate GameJam 15](https://itch.io/jam/pirate).

## Required toolset:

- [.Net 8.0](https://dotnet.microsoft.com/en-us/download) (or newer)
- [Godot 4.2.2](https://godotengine.org/download) (or newer) with C# support
- IDE to work with C# code: **VS Code + C# extension** or **Visual Studio 2022** or **Jetbrains Rider**.

## File layout

- `.vscode` - VS Code IDE team-shared configuration.
- `code` - Code that is global / not specific to a scene.
- `resources` - assets (textures, audio) wrapped into `tres` files, ready to directly use in scenes.
- `scenes` - Game scenes:
    - `ui` - UI scenes (menu / HUD);
    - `props` - placeable objects in the world (movable / static);
    - `world` - `world levels`;
    - `characters` - playable and non-playable characters.
- `assets` - Raw resource files (png, jpeg, mp3, ...).

## Configure VS Code to be default script editor

Go to `Editor` menu and open `Editor settings...`.

Find section `Text editor`, open subsection `External`.

1. Select `Use external editor`;
2. Provide a path to VS Code executable (for me, it is `D:/Program Files/vscode/Code.exe`, depends on where you have
   installed it);
3. Provide execution flags for VS Code: `{project} --goto {file}:{line}:{col}`.

_(For other IDEs execution flags
see [this page](https://docs.godotengine.org/en/stable/tutorials/editor/external_editor.html))_

Done. Now when you open text files in Godot, it will automatically launch VS Code and open the file.

## Configure VS Code to show context help for `.gdscript` and other files

Install VS Code extension [godot-tools](https://marketplace.visualstudio.com/items?itemName=geequlim.godot-tools).

Also, I recommend installing every recommended extension as well, see `Recommended` tab in `Extensions` menu in your VS
Code. There are some that were recommended by me, see file `.vscode/extensions.json`. They also should be highlighted
as "recommended" to you.
