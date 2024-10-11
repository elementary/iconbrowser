/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2017-2022 elementary, Inc. (https://elementary.io)
 */

public class Widgets.SidebarRow : Gtk.ListBoxRow {
    public Services.Collection.Category category { get; construct; }

    public SidebarRow (Services.Collection.Category category) {
        Object (category: category);
    }

    construct {
        var label = new Gtk.Label (category.to_string ()) {
            xalign = 0
        };

        child = label;
    }
}
