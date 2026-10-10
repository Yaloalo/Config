#!/usr/bin/env python3
"""Run the installed display arranger with process-local space styling.

Keep upstream's drag, mirror, apply/revert and Lua persistence behavior intact.
No system GTK theme or installed package files are changed.
"""
from pathlib import Path

import gi

gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
from gi.repository import Gdk, Gtk
from nwg_displays import main


def run():
    css = Gtk.CssProvider()
    css.load_from_path(str(Path(__file__).resolve().parent.parent / "nwg-displays" / "space.css"))
    Gtk.StyleContext.add_provider_for_screen(
        Gdk.Screen.get_default(), css, Gtk.STYLE_PROVIDER_PRIORITY_USER
    )
    main.main()


if __name__ == "__main__":
    run()
