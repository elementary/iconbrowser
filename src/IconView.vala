/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2017-2022 elementary, Inc. (https://elementary.io)
 */
public class IconView : Gtk.Box {
    public string icon_name { get; construct set; }
    public string description { get; construct set; }
    public CategoryView.Category category { get; construct set; }
    public IconDetails selected_icon { get; construct set; }

    public IconView () {
        Object (
            icon_name: "address-book-new",
            description: _("Create a new address book"),
            category: CategoryView.Category.ACTIONS,
            selected_icon: new IconDetails (
                "address-book-new",
                24
            )
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

        var color_row = new Gtk.Grid () {
            column_spacing = 24,
            row_spacing = 12
        };

        var symbolic_title = new Granite.HeaderLabel (_("Symbolic Icons")) {
            margin_top = 12
        };

        var symbolic_row = new Gtk.Grid () {
            column_spacing = 24,
            row_spacing = 12
        };

        var size_group = new Gtk.SizeGroup (Gtk.SizeGroupMode.VERTICAL);
        size_group.add_widget (color_row);
        size_group.add_widget (symbolic_row);

        var snippet_title = new Granite.HeaderLabel (_("Code Sample")) {
            margin_top = 12
        };

        var source_buffer = new GtkSource.Buffer (null) {
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
            Gtk.ToggleButton btn_group = null;
            fill_icon_row (icon_name, color_row, ref btn_group);
            fill_icon_row (icon_name + "-symbolic", symbolic_row, ref btn_group);
            select_one_icon (color_row, symbolic_row);
        });

        notify["selected-icon"].connect (() => {
            var name = selected_icon.full_icon_name;
            var size = selected_icon.size_in_px;
            source_buffer.text = """var icon = new Gtk.Image.from_icon_name ("%s") {
    pixel_size = %d
};""".printf (name, size);
        });
    }

    private void fill_icon_row (string _icon_name, Gtk.Grid row, ref Gtk.ToggleButton? icon_btn) {
        while (row.get_first_child () != null) {
            row.remove (row.get_first_child ());
        }

        var icon_theme = new Gtk.IconTheme () {
            theme_name = "elementary"
        };

        if (!icon_theme.has_icon (_icon_name)) {
            var not_has_label = new Gtk.Label (_("Unavailable")) {
                hexpand = true,
            };
            not_has_label.add_css_class (Granite.STYLE_CLASS_DIM_LABEL);
            not_has_label.add_css_class (Granite.STYLE_CLASS_H3_LABEL);

            row.attach (not_has_label, 0, 0);

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

        int i = 0;
        foreach (int size in sizes) {
            var icon = new Gtk.Image.from_icon_name (_icon_name) {
                pixel_size = size,
                use_fallback = true,
                valign = Gtk.Align.END
            };

            var label = new Gtk.Label ("%ipx".printf (size)) {
                hexpand = true
            };

            var icon_and_label = new Gtk.Grid () {
                row_spacing = 12,
                valign = Gtk.Align.CENTER,
                margin_top = 4,
                margin_bottom = 4
            };
            icon_and_label.attach (icon, 0, 0);
            icon_and_label.attach (label, 0, 1);
            icon_btn = new Gtk.ToggleButton () {
                child = icon_and_label,
                has_frame = false,
                group = icon_btn
            };
            icon_btn.toggled.connect ((target) => {
                if (target.active) {
                    selected_icon = new IconDetails (icon.icon_name, icon.pixel_size);
                }
            });

            row.attach (icon_btn, i, 0);

            i++;
        }
    }

    private void select_one_icon (Gtk.Grid color_row, Gtk.Grid icon_row) {
        var has_color_icons = color_row.get_first_child () is Gtk.ToggleButton;
        var row = has_color_icons ? color_row : icon_row;
        var btn = row.get_child_at (1, 0) ?? row.get_first_child ();
        ((Gtk.ToggleButton) btn).active = true;
    }
}

public class IconDetails : Object {
    public string full_icon_name { get; construct; }
    public int size_in_px { get; construct; }

    public IconDetails (string name, int size) {
        Object (
            full_icon_name: name,
            size_in_px: size
        );
    }
}
