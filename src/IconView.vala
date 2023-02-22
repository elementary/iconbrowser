/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2017-2022 elementary, Inc. (https://elementary.io)
 */
public class IconView : Gtk.Box {
    public string icon_name { get; construct set; }
    public string description { get; construct set; }
    public CategoryView.Category category { get; construct set; }

    private GtkSource.Buffer source_buffer;

    public IconView () {
        Object (
            icon_name: "address-book-new",
            description: _("Create a new address book"),
            category: CategoryView.Category.ACTIONS
        );
    }

    construct {
        var header_icon = new Gtk.Image.from_icon_name (icon_name) {
            icon_size = Gtk.IconSize.LARGE,
            valign = Gtk.Align.START
        };

        var title_label = new Gtk.Label (icon_name) {
            selectable = true,
            wrap = true,
            xalign = 0,
            valign = Gtk.Align.END
        };
        title_label.add_css_class (Granite.STYLE_CLASS_H2_LABEL);

        var description_label = new Gtk.Label (description) {
            selectable = true,
            wrap = true,
            halign = Gtk.Align.START,
            xalign = 0,
            valign = Gtk.Align.START
        };

        var window_controls = new Gtk.WindowControls (Gtk.PackType.END) {
            halign = Gtk.Align.END,
            hexpand = true,
            valign = Gtk.Align.START
        };

        var header_area = new Gtk.Grid ();
        header_area.add_css_class ("header-area");
        header_area.attach (title_label, 1, 0);
        header_area.attach (header_icon, 0, 0, 1, 2);
        header_area.attach (description_label, 1, 1, 2);
        header_area.attach (window_controls, 2, 0, 1, 2);

        var header_handle = new Gtk.WindowHandle () {
            child = header_area
        };
        header_handle.add_css_class ("titlebar");
        header_handle.add_css_class (Granite.STYLE_CLASS_FLAT);

        var color_title = new Granite.HeaderLabel (_("Color Icons"));

        var color_row = new Gtk.FlowBox () {
            column_spacing = 24,
            row_spacing = 12
        };

        var symbolic_title = new Granite.HeaderLabel (_("Symbolic Icons")) {
            margin_top = 12
        };

        var symbolic_row = new Gtk.FlowBox () {
            column_spacing = 24,
            row_spacing = 12
        };

        var size_group = new Gtk.SizeGroup (Gtk.SizeGroupMode.VERTICAL);
        size_group.add_widget (color_row);
        size_group.add_widget (symbolic_row);

        var snippet_title = new Granite.HeaderLabel (_("Code Sample")) {
            margin_top = 12
        };

        source_buffer = new GtkSource.Buffer (null) {
            highlight_syntax = true,
            language = GtkSource.LanguageManager.get_default ().get_language ("vala")
        };

        var source_view = new GtkSource.View () {
            buffer = source_buffer,
            hexpand = true,
            editable = false,
            monospace = true,
            show_line_numbers = true,
            left_margin = 12,
            right_margin = 12,
            bottom_margin = 12,
            top_margin = 12,
            pixels_above_lines = 3,
            pixels_below_lines = 3
        };
        source_view.add_css_class (Granite.STYLE_CLASS_CARD);
        source_view.add_css_class (Granite.STYLE_CLASS_ROUNDED);

        var content_area = new Gtk.Box (Gtk.Orientation.VERTICAL, 12) {
            vexpand = true
        };
        content_area.add_css_class ("content-area");
        content_area.append (color_title);
        content_area.append (color_row);
        content_area.append (symbolic_title);
        content_area.append (symbolic_row);
        content_area.append (snippet_title);
        content_area.append (source_view);

        var scrolled = new Gtk.ScrolledWindow () {
            child = content_area,
            hscrollbar_policy = Gtk.PolicyType.NEVER
        };

        orientation = Gtk.Orientation.VERTICAL;
        append (header_handle);
        append (scrolled);

        var gtk_settings = Gtk.Settings.get_default ();
        if (gtk_settings.gtk_application_prefer_dark_theme) {
            source_buffer.style_scheme = new GtkSource.StyleSchemeManager ().get_scheme ("solarized-dark");
        } else {
            source_buffer.style_scheme = new GtkSource.StyleSchemeManager ().get_scheme ("solarized-light");
        }

        gtk_settings.notify["gtk-application-prefer-dark-theme"].connect (() => {
            if (gtk_settings.gtk_application_prefer_dark_theme) {
                source_buffer.style_scheme = new GtkSource.StyleSchemeManager ().get_scheme ("solarized-dark");
            } else {
                source_buffer.style_scheme = new GtkSource.StyleSchemeManager ().get_scheme ("solarized-light");
            }
        });

        bind_property ("icon-name", header_icon, "icon-name");
        bind_property ("icon-name", title_label, "label");
        bind_property ("description", description_label, "label");

        notify["icon-name"].connect (() => {
            source_buffer.text = "var icon = new Gtk.Image.from_icon_name (\"%s\") {\n    pixel_size = 24\n};".printf (icon_name);

            fill_icon_row (icon_name, color_row);
            fill_icon_row (icon_name + "-symbolic", symbolic_row);
        });

        color_row.child_activated.connect (child_activated);
        symbolic_row.child_activated.connect (child_activated);
    }

    private void child_activated (Gtk.FlowBoxChild child) {
        if (child is IconChild) {
            var icon = (IconChild) child;
            source_buffer.text = "var icon = new Gtk.Image.from_icon_name (\"%s\") {\n    pixel_size = %i\n};".printf (
                icon.icon_name, icon.icon_size
            );
        }
    }

    private void fill_icon_row (string _icon_name, Gtk.FlowBox row) {
        while (row.get_first_child () != null) {
            row.remove (row.get_first_child ());
        }

        var icon_theme = new Gtk.IconTheme () {
            theme_name = "elementary"
        };

        if (!icon_theme.has_icon (_icon_name)) {
            var not_has_label = new Gtk.Label (_("Unavailable")) {
                hexpand = true
            };
            not_has_label.add_css_class (Granite.STYLE_CLASS_DIM_LABEL);
            not_has_label.add_css_class (Granite.STYLE_CLASS_H3_LABEL);

            row.append (not_has_label);
            row.max_children_per_line = 1;
            row.can_target = false;

            return;
        }

        int[] sizes;
        switch (category) {
            case CategoryView.Category.ACTIONS:
            case CategoryView.Category.EMBLEMS:
                sizes = {16, 24, 32, 48};
                break;
            case CategoryView.Category.EMOTES:
                sizes = {16};
                break;
            default:
                sizes = {16, 24, 32, 48, 64, 128};
                break;
        }

        row.max_children_per_line = sizes.length;

        foreach (int size in sizes) {
            var icon_child = new IconChild (_icon_name, size);
            row.append (icon_child);
        }
    }

    private class IconChild : Gtk.FlowBoxChild {
        public int icon_size { get; construct; }
        public string icon_name { get; construct; }

        public IconChild (string icon_name, int icon_size) {
            Object (
                icon_name: icon_name,
                icon_size: icon_size
            );
        }

        construct {
            var icon = new Gtk.Image.from_icon_name (icon_name) {
                pixel_size = icon_size,
                use_fallback = true
            };

            var label = new Gtk.Label ("%ipx".printf (icon_size));

            var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
                margin_top = 6,
                margin_end = 6,
                margin_bottom = 6,
                margin_start = 6,
                valign = Gtk.Align.END
            };
            box.append (icon);
            box.append (label);

            child = box;
        }
    }
}
