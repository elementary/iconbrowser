/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2017-2022 elementary, Inc. (https://elementary.io)
 */

public class IconBrowser.MainWindow : Gtk.ApplicationWindow {
    private CategoryView category_view;
    private Gtk.ListBox categories_sidebar;

    public MainWindow (Gtk.Application application) {
        Object (application: application);
    }

    construct {
        icon_name = "io.elementary.iconbrowser";
        title = _("Icon Browser");

        var dont_button = new Gtk.ToggleButton () {
            action_name = "win.color-scheme",
            action_target = new Variant.uint32 (Granite.Settings.ColorScheme.NO_PREFERENCE),
            icon_name = "preferences-system-symbolic",
            tooltip_text = "Follow system setting"
        };

        var force_light = new Gtk.ToggleButton () {
            action_name = "win.color-scheme",
            action_target = new Variant.uint32 (Granite.Settings.ColorScheme.LIGHT),
            group = dont_button,
            icon_name = "display-brightness-symbolic",
            tooltip_text = "Light"
        };

        var force_dark = new Gtk.ToggleButton () {
            action_name = "win.color-scheme",
            action_target = new Variant.uint32 (Granite.Settings.ColorScheme.DARK),
            group = force_light,
            icon_name = "weather-clear-night-symbolic",
            tooltip_text = "Dark"
        };

        var style_box = new Granite.Box (HORIZONTAL, LINKED) {
            homogeneous = true,
            margin_start = 6,
            margin_bottom = 6,
            margin_end = 6,
            margin_top = 6
        };
        style_box.append (force_light);
        style_box.append (dont_button);
        style_box.append (force_dark);

        category_view = new CategoryView ();

        categories_sidebar = new Gtk.ListBox () {
            vexpand = true
        };

        foreach (var category in IconCollection.Category.all ()) {
            var sidebar_row = new SidebarRow (category);
            categories_sidebar.append (sidebar_row);
        }

        var scrolled_category = new Gtk.ScrolledWindow () {
            child = categories_sidebar,
            hscrollbar_policy = Gtk.PolicyType.NEVER
        };

        var start_window_controls = new Gtk.WindowControls (Gtk.PackType.START) {
            hexpand = true
        };

        var sidebar_header = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        sidebar_header.add_css_class ("titlebar");
        sidebar_header.append (start_window_controls);

        var sidebar_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        sidebar_box.append (sidebar_header);
        sidebar_box.append (scrolled_category);
        sidebar_box.append (style_box);
        sidebar_box.add_css_class ("sidebar");

        var sidebar_handle = new Gtk.WindowHandle () {
            child = sidebar_box
        };

        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL) {
            position = 128,
            start_child = sidebar_handle,
            end_child = category_view,
            resize_start_child = false,
            shrink_end_child = false,
            shrink_start_child = false
        };

        // We need to hide the title area for the split headerbar
        var null_title = new Gtk.Grid () {
            visible = false
        };
        set_titlebar (null_title);

        child = paned;
        category_view.search_entry.set_key_capture_widget (this);

        var gtk_settings = Gtk.Settings.get_default ();

        gtk_settings.gtk_icon_theme_name = "elementary";
        if (!(gtk_settings.gtk_theme_name.has_prefix ("io.elementary.stylesheet"))) {
            gtk_settings.gtk_theme_name = "io.elementary.stylesheet.blueberry";
        }

        var style_manager = Granite.StyleManager.get_default ();

        var style_action = new SimpleAction.stateful ("color-scheme", VariantType.UINT32, new Variant.uint32 (style_manager.color_scheme));
        style_action.activate.connect ((parameter) => {
            style_manager.color_scheme = (Granite.Settings.ColorScheme) parameter.get_uint32 ();
        });

        style_manager.notify ["color-scheme"].connect (() => {
            style_action.set_state (new Variant.uint32 (style_manager.color_scheme));
        });

        add_action (style_action);

        category_view.listbox.set_filter_func (filter_function);

        category_view.search_entry.search_changed.connect (() => {
            category_view.listbox.invalidate_filter ();

            bool searching = (category_view.search_entry.text != "");
            categories_sidebar.sensitive = !searching;

            if (searching) {
                categories_sidebar.selection_mode = Gtk.SelectionMode.NONE;
            } else {
                categories_sidebar.selection_mode = Gtk.SelectionMode.SINGLE;
            }
        });

        categories_sidebar.row_selected.connect (() => {
            category_view.listbox.invalidate_filter ();
        });
    }

    [CCode (instance_pos = -1)]
    private bool filter_function (Gtk.ListBoxRow row) {
        if (category_view.search_entry.text == "") {
            var sidebar_row = categories_sidebar.get_selected_row ();
            if (sidebar_row != null) {
                return ((IconListRow) row).category == ((SidebarRow) sidebar_row).category;
            } else {
                return true;
            }
        }

        var search_term = category_view.search_entry.text.down ();

        if (search_term in ((IconListRow) row).icon_name || search_term in ((IconListRow) row).description.down ()) {
            return true;
        }
        return false;
    }
}
