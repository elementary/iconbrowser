/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2017-2022 elementary, Inc. (https://elementary.io)
 */

public class Widgets.IconListChild : Gtk.FlowBoxChild {
    public Services.Collection.Category category { get; construct; }
    public string description { get; construct; }
    public string icon_name { get; construct; }

    private static Gtk.IconTheme icon_theme;

    public IconListChild (string icon_name, string description, Services.Collection.Category category) {
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
        var icon = new Gtk.Image () {
            icon_name = icon_theme.has_icon (icon_name) ? icon_name : icon_name + "-symbolic",
            pixel_size = 32
        };

        var label = new Gtk.Label (icon_name) {
            ellipsize = Pango.EllipsizeMode.MIDDLE,
            css_classes = { "dim-label", "small-label" }
        };

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
            margin_top = 12,
            margin_bottom = 12,
            margin_end = 12,
            margin_start = 12
        };
        box.append (icon);
        box.append (label);

        child = box;
    }
}
