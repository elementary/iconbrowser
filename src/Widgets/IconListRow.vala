/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2017-2022 elementary, Inc. (https://elementary.io)
 */

public class IconListRow : Gtk.ListBoxRow {
    public IconCollection.Category category { get; construct; }
    public string description { get; construct; }
    public string icon_name { get; construct; }

    private static Gtk.IconTheme icon_theme;

    public IconListRow (string icon_name, string description, IconCollection.Category category) {
        Object (
            category: category,
            description: description,
            icon_name: icon_name
        );
    }

    static construct {
        icon_theme = new Gtk.IconTheme () {
            theme_name = "elementary"
        };
    }

    construct {
        var icon = new Gtk.Image ();

        if (icon_theme.has_icon (icon_name)) {
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

        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        box.append (icon);
        box.append (label);

        child = box;
    }
}
