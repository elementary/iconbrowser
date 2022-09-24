/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2017-2022 elementary, Inc. (https://elementary.io)
 */

public class IconListRow : Gtk.ListBoxRow {
    public CategoryView.Category category { get; construct; }
    public string description { get; construct; }
    public string icon_name { get; construct; }

    public IconListRow (string icon_name, string description, CategoryView.Category category) {
        Object (
            category: category,
            description: description,
            icon_name: icon_name
        );
    }

    construct {
        var icon = new Gtk.Image ();

        if (Gtk.IconTheme.get_for_display (Gdk.Display.get_default ()).has_icon (icon_name)) {
            icon.icon_name = icon_name;
            icon.pixel_size = 24;
        } else {
            icon.icon_name = icon_name + "-symbolic";
            icon.pixel_size = 16;
            icon.set_size_request (24, 24);
        }

        var label = new Gtk.Label (icon_name) {
            ellipsize = Pango.EllipsizeMode.MIDDLE
        };

        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
            margin_top = 3,
            margin_end = 6,
            margin_bottom = 3,
            margin_start = 6
        };
        box.append (icon);
        box.append (label);

        child = box;
    }
}
