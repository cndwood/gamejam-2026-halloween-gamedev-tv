# Web release

Open project.godot with Godot 4.7.2 and install matching export templates through **Editor → Manage Export Templates**. The current main scene remains scenes/game.tscn.

Use **Project → Export → Web → Export Project** to export build/web/index.html, or run:

```sh
python3 tools/export_web.py --godot /path/to/Godot
```

The helper imports the project, makes a release export, adds README/credit notices, and writes build/uninvited-web.zip. It clears only its generated build/web directory before each export. It stops without packaging if export fails. Build outputs are ignored by version control.

The preset exports all project resources to include autoloads, the theme, and global-class scripts reliably, with single-threaded Web support and the Compatibility renderer. Source artwork, internal Markdown documents and source ZIPs are excluded from the game pack; the upload ZIP includes a separate README and credit notices.

Preview using `python3 -m http.server 8000 --directory build/web`, then visit http://localhost:8000. Exported games need HTTP hosting; opening index.html directly is insufficient.

On itch.io, choose **HTML** as the project kind. Upload build/uninvited-web.zip and mark it as playable in the browser. index.html must be at the ZIP root. Start with an embed size of 1152×648, enable fullscreen, and keep it listed as keyboard-and-mouse gameplay. Copy docs/ITCH_PAGE.md into the page description; it contains the complete player-facing description and credits. Preserve Godot's generated filenames.

Before publishing, play the exported browser build and check first-Start tutorial, sound after Start, resource collection, machine production, ladder travel, repairs, cannon refills, purchases/dash, pause/options, game-over fade/score and Try Again skipping the tutorial. Check resize/fullscreen and at least Chromium plus Firefox. No upload or publishing happens through the helper.

Web templates are installed and a release ZIP has been generated. Startup has been tested in Chrome over local HTTP; complete the browser gameplay checks above before publishing. The custom project icon is assigned. Add cover art and screenshots to the itch.io page when ready.

References: [Godot Web export](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html), [itch.io HTML5 uploads](https://itch.io/docs/creators/html5).
