/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2017-2022 elementary, Inc. (https://elementary.io)
 */
public class IconDetails : Object {
    public string full_icon_name { get; construct; }
    public int size_in_px { get; construct; }

    public IconDetails (string name, int size) {
        Object (
            full_icon_name: name,
            size_in_px: size
        );
    }

    public string code_snippet () {
        return """var icon = new Gtk.Image.from_icon_name ("%s") {
    pixel_size = %d
};""".printf (full_icon_name, size_in_px);
    }
}
