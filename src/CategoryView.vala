/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2017-2022 elementary, Inc. (https://elementary.io)
 */

public class CategoryView : Gtk.Box {
    public string category_name { get; construct; }

    public Gtk.FlowBox flowbox { get; private set; }
    public Gtk.SearchEntry search_entry { get; private set; }

    construct {
        search_entry = new Gtk.SearchEntry () {
            hexpand = true,
            placeholder_text = _("Search Names or Descriptions"),
            valign = Gtk.Align.CENTER,
        };

        var symbolic_switch = new Granite.SwitchModelButton (_("Symbolic"));

        var menu_popover_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
            width_request = 250,
            margin_bottom = 3,
            margin_top = 3
        };

        menu_popover_box.append (symbolic_switch);

        var popover = new Gtk.Popover () {
            child = menu_popover_box
        };

        var menu_button = new Gtk.MenuButton () {
            icon_name = "open-menu-symbolic",
            popover = popover,
            tooltip_text = _("Settings"),
            valign = Gtk.Align.CENTER
        };

        var headerbar = new Adw.HeaderBar () {
            title_widget = search_entry,
            hexpand = true,
            css_classes = { "flat" }
        };

        headerbar.pack_end (menu_button);

        flowbox = new Gtk.FlowBox () {
            activate_on_single_click = true,
            selection_mode = Gtk.SelectionMode.SINGLE,
            homogeneous = true,
            valign = START,
            margin_start = 12,
            margin_end = 12,
            margin_top = 12,
            margin_bottom = 12,
            min_children_per_line = 3
        };
        flowbox.add_css_class ("rich-list");
        flowbox.set_sort_func (sort_function);

        var scrolled_window = new Gtk.ScrolledWindow () {
            child = flowbox,
            hscrollbar_policy = Gtk.PolicyType.NEVER,
            vexpand = true
        };

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        box.append (scrolled_window);
        box.add_css_class (Granite.STYLE_CLASS_VIEW);

        var list_handle = new Gtk.WindowHandle () {
            child = box
        };

        var toolbar_view = new Adw.ToolbarView () {
            hexpand = true,
            vexpand = true
        };
        toolbar_view.add_top_bar (headerbar);
        toolbar_view.content = list_handle;

        append (toolbar_view);
        fill_icons ();

        flowbox.child_activated.connect ((child) => {
            var icon = ((Widgets.IconListChild) child);
            var dialog = new Dialogs.IconView (icon.icon_name, icon.description, icon.category);
            dialog.show ();
        });

        symbolic_switch.toggled.connect (() => {
            fill_icons (symbolic_switch.active);
        });
    }

    private void fill_icons (bool use_symbolic = false) {
        var icon_theme = new Gtk.IconTheme () {
            theme_name = "elementary"
        };

        flowbox.remove_all ();
        foreach (var icon in Services.Collection.icons ()) {
            string icon_name = use_symbolic ? icon.name + "-symbolic" : icon.name;
            if (icon_theme.has_icon (icon_name)) {
                var row = new Widgets.IconListChild (icon_name, icon.description, icon.category);
                flowbox.append (row);
            }
        }
    }

    [CCode (instance_pos = -1)]
    private int sort_function (Gtk.FlowBoxChild row1, Gtk.FlowBoxChild row2) {
        var name1 = ((Widgets.IconListChild) row1).icon_name;
        var name2 = ((Widgets.IconListChild) row2).icon_name;
        return name1.collate (name2);
    }
}
