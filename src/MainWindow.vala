/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2017-2022 elementary, Inc. (https://elementary.io)
 */

public class IconBrowser.MainWindow : Gtk.ApplicationWindow {
    private Gtk.ListBox categories_sidebar;
    private Gtk.SearchEntry search_entry;

    public MainWindow (Gtk.Application application) {
        Object (application: application);
    }

    construct {
        icon_name = "io.elementary.iconbrowser";
        title = _("Icon Browser");

        search_entry = new Gtk.SearchEntry () {
            hexpand = true,
            placeholder_text = _("Search Icon Names or Descriptions"),
            valign = Gtk.Align.CENTER
        };

        var mode_switch = new Granite.ModeSwitch.from_icon_name ("display-brightness-symbolic", "weather-clear-night-symbolic") {
            primary_icon_tooltip_text = _("Light background"),
            secondary_icon_tooltip_text = _("Dark background"),
            valign = Gtk.Align.CENTER
        };

        var category_view = new CategoryView ();

        categories_sidebar = new Gtk.ListBox ();

        foreach (var category in CategoryView.Category.all ()) {
            var sidebar_row = new SidebarRow (category);
            categories_sidebar.append (sidebar_row);
        }

        var scrolled_category = new Gtk.ScrolledWindow () {
            child = categories_sidebar,
            hscrollbar_policy = Gtk.PolicyType.NEVER
        };
        scrolled_category.add_css_class (Granite.STYLE_CLASS_SIDEBAR);

        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL) {
            position = 128,
            start_child = scrolled_category,
            end_child = category_view,
            resize_start_child = false,
            shrink_end_child = false,
            shrink_start_child = false
        };

        var headerbar = new Gtk.HeaderBar () {
            show_title_buttons = true,
            title_widget = search_entry
        };
        headerbar.pack_end (mode_switch);
        headerbar.pack_end (new Gtk.Separator (Gtk.Orientation.VERTICAL));

        set_titlebar (headerbar);
        child = paned;

        ((Gtk.ListBox)category_view.listbox).set_filter_func (filter_function);

        var gtk_settings = Gtk.Settings.get_default ();
        mode_switch.bind_property ("active", gtk_settings, "gtk_application_prefer_dark_theme");
        App.settings.bind ("prefer-dark-style", mode_switch, "active", GLib.SettingsBindFlags.DEFAULT);

        search_entry.search_changed.connect (() => {
            ((Gtk.ListBox)category_view.listbox).invalidate_filter ();

            bool searching = (search_entry.text != "");
            categories_sidebar.sensitive = !searching;

            if (searching) {
                categories_sidebar.selection_mode = Gtk.SelectionMode.NONE;
            } else {
                categories_sidebar.selection_mode = Gtk.SelectionMode.SINGLE;
            }
        });

        categories_sidebar.row_selected.connect (() => {
            ((Gtk.ListBox)category_view.listbox).invalidate_filter ();
        });

        search_entry.grab_focus ();
    }

    [CCode (instance_pos = -1)]
    private bool filter_function (Gtk.ListBoxRow row) {
        if (search_entry.text == "") {
            var sidebar_row = categories_sidebar.get_selected_row ();
            if (sidebar_row != null) {
                return ((IconListRow) row).category == ((SidebarRow) sidebar_row).category;
            } else {
                return true;
            }
        }

        var search_term = search_entry.text.down ();

        if (search_term in ((IconListRow) row).icon_name || search_term in ((IconListRow) row).description.down ()) {
            return true;
        }
        return false;
    }
}
