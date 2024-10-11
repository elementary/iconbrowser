/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2017-2022 elementary, Inc. (https://elementary.io)
 */

public class CategoryView : Gtk.Box {
    public string category_name { get; construct; }

    public Gtk.ListBox listbox { get; private set; }
    public Gtk.SearchEntry search_entry { get; private set; }

    construct {
        var icon_view = new IconView ();

        search_entry = new Gtk.SearchEntry () {
            hexpand = true,
            placeholder_text = _("Search Names or Descriptions"),
            valign = Gtk.Align.CENTER,
        };

        var list_header = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        list_header.add_css_class ("titlebar");
        list_header.append (search_entry);

        listbox = new Gtk.ListBox () {
            activate_on_single_click = true,
            selection_mode = Gtk.SelectionMode.SINGLE
        };
        listbox.add_css_class ("rich-list");
        listbox.set_sort_func (sort_function);

        var scrolled_window = new Gtk.ScrolledWindow () {
            child = listbox,
            hscrollbar_policy = Gtk.PolicyType.NEVER,
            vexpand = true
        };

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        box.append (list_header);
        box.append (scrolled_window);
        box.add_css_class (Granite.STYLE_CLASS_VIEW);

        var list_handle = new Gtk.WindowHandle () {
            child = box
        };

        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL) {
            start_child = list_handle,
            resize_start_child = false,
            shrink_start_child = false,
            end_child = icon_view,
            shrink_end_child = false,
            position = 256
        };

        append (paned);

        var icon_theme = new Gtk.IconTheme () {
            theme_name = "elementary"
        };

        foreach (var icon in IconCollection.icons ()) {
            if (icon_theme.has_icon (icon.name) || icon_theme.has_icon (icon.name + "-symbolic")) {
                var row = new IconListRow (icon.name, icon.description, icon.category);
                listbox.append (row);
            }
        }

        listbox.row_selected.connect ((row) => {
            icon_view.category = ((IconListRow) row).category;
            icon_view.icon_name = ((IconListRow) row).icon_name;
            icon_view.description = ((IconListRow) row).description;
        });
    }

    [CCode (instance_pos = -1)]
    private int sort_function (Gtk.ListBoxRow row1, Gtk.ListBoxRow row2) {
        var name1 = ((IconListRow) row1).icon_name;
        var name2 = ((IconListRow) row2).icon_name;
        return name1.collate (name2);
    }
}
