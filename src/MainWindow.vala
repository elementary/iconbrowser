/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2017-2022 elementary, Inc. (https://elementary.io)
 */

public class MainWindow : Gtk.ApplicationWindow {
	private CategoryView category_view;
	private Gtk.ListBox categories_sidebar;

	public MainWindow (Gtk.Application application) {
		Object (
			application: application,
			icon_name: "io.elementary.iconbrowser",
			title: _("Icon Browser")
		);
	}

	construct {
		var mode_switch = new Granite.ModeSwitch.from_icon_name ("display-brightness-symbolic", "weather-clear-night-symbolic") {
			primary_icon_tooltip_text = _("Light background"),
			secondary_icon_tooltip_text = _("Dark background"),
			hexpand = true,
			halign = CENTER,
			margin_bottom = 12
		};

		category_view = new CategoryView ();

		categories_sidebar = new Gtk.ListBox () {
			vexpand = true
		};

		foreach (var category in Services.Collection.Category.all ()) {
			var sidebar_row = new Widgets.SidebarRow (category);
			categories_sidebar.append (sidebar_row);
		}

		var scrolled_category = new Gtk.ScrolledWindow () {
			child = categories_sidebar,
			hscrollbar_policy = Gtk.PolicyType.NEVER
		};

		var sidebar_header = new Adw.HeaderBar () {
			title_widget = new Gtk.Label (null),
			hexpand = true,
			css_classes = { "flat" }
		};

		var sidebar_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		sidebar_box.append (sidebar_header);
		sidebar_box.append (scrolled_category);
		sidebar_box.append (mode_switch);
		sidebar_box.add_css_class ("sidebar");

		var sidebar_view = new Adw.ToolbarView ();
		sidebar_view.add_top_bar (sidebar_header);
		sidebar_view.content = sidebar_box;

		var overlay_split_view = new Adw.OverlaySplitView () {
			min_sidebar_width = 250
		};
		overlay_split_view.content = category_view;
		overlay_split_view.sidebar = sidebar_view;
		
		// We need to hide the title area for the split headerbar
        var null_title = new Gtk.Grid () {
            visible = false
        };
        set_titlebar (null_title);

		child = overlay_split_view;

		var gtk_settings = Gtk.Settings.get_default ();
		gtk_settings.bind_property ("gtk-application-prefer-dark-theme", mode_switch, "active", BindingFlags.BIDIRECTIONAL);

		gtk_settings.gtk_icon_theme_name = "elementary";
		if (!(gtk_settings.gtk_theme_name.has_prefix ("io.elementary.stylesheet"))) {
			gtk_settings.gtk_theme_name = "io.elementary.stylesheet.blueberry";
		}

		var granite_settings = Granite.Settings.get_default ();
		gtk_settings.gtk_application_prefer_dark_theme = (
			granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK
			);

		granite_settings.notify["prefers-color-scheme"].connect (() => {
			gtk_settings.gtk_application_prefer_dark_theme = (
				granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK
				);
		});

		category_view.flowbox.set_filter_func (filter_function);

		category_view.search_entry.search_changed.connect (() => {
			category_view.flowbox.invalidate_filter ();

			bool searching = (category_view.search_entry.text != "");
			categories_sidebar.sensitive = !searching;

			if (searching) {
				categories_sidebar.selection_mode = Gtk.SelectionMode.NONE;
			} else {
				categories_sidebar.selection_mode = Gtk.SelectionMode.SINGLE;
			}
		});

		categories_sidebar.row_selected.connect (() => {
			category_view.flowbox.invalidate_filter ();
		});
	}

	[CCode (instance_pos = -1)]
	private bool filter_function (Gtk.FlowBoxChild row) {
		if (category_view.search_entry.text == "") {
			var sidebar_row = categories_sidebar.get_selected_row ();
			if (sidebar_row != null) {
				return ((Widgets.IconListChild) row).category == ((Widgets.IconListChild) sidebar_row).category;
			} else {
				return true;
			}
		}

		var search_term = category_view.search_entry.text.down ();

		if (search_term in ((Widgets.IconListChild) row).icon_name || search_term in ((Widgets.IconListChild) row).description.down ()) {
			return true;
		}
		return false;
	}
}
