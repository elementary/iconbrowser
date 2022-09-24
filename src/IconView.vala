/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2017-2022 elementary, Inc. (https://elementary.io)
 */
public class IconView : Granite.SimpleSettingsPage {
    private Gtk.Grid color_row;
    private Gtk.Grid symbolic_row;

    public IconView () {
        Object (
            icon_name: "address-book-new",
            description: _("Create a new address book")
        );
    }

    construct {
        var color_title = new Gtk.Label (_("Color Icons")) {
            margin_top = 12,
            xalign = 0
        };
        color_title.add_css_class (Granite.STYLE_CLASS_H4_LABEL);

        color_row = new Gtk.Grid () {
            column_spacing = 24,
            row_spacing = 12
        };

        var symbolic_title = new Gtk.Label (_("Symbolic Icons")) {
            margin_top = 12,
            xalign = 0
        };
        symbolic_title.add_css_class (Granite.STYLE_CLASS_H4_LABEL);

        symbolic_row = new Gtk.Grid () {
            column_spacing = 24,
            row_spacing = 12
        };

        var snippet_title = new Gtk.Label (_("Code Sample")) {
            margin_top = 12,
            xalign = 0
        };
        snippet_title.add_css_class (Granite.STYLE_CLASS_H4_LABEL);

        var source_buffer = new GtkSource.Buffer (null) {
            highlight_syntax = true,
            language = GtkSource.LanguageManager.get_default ().get_language ("vala"),
            style_scheme = new GtkSource.StyleSchemeManager ().get_scheme ("solarized-light")
        };

        var source_view = new GtkSource.View () {
            buffer = source_buffer,
            hexpand = true,
            editable = false,
            monospace = true,
            show_line_numbers = true
        };

        source_view.left_margin = source_view.right_margin = 6;
        source_view.pixels_above_lines = source_view.pixels_below_lines = 3;

        var snippet = new Gtk.Grid ();
        snippet.add_css_class ("code");
        snippet.attach (source_view, 0, 0);

        content_area.column_spacing = 12;
        content_area.row_spacing = 12;
        content_area.attach (color_title, 0, 0);
        content_area.attach (color_row, 0, 1);
        content_area.attach (symbolic_title, 0, 2);
        content_area.attach (symbolic_row, 0, 3);
        content_area.attach (snippet_title, 0, 4);
        content_area.attach (snippet, 0, 5);

        var icon_theme = Gtk.IconTheme.get_for_display (Gdk.Display.get_default ());
        int[] pixels = {16, 24, 32, 48, 64, 128};

        notify["icon-name"].connect (() => {
            var is_symbolic = icon_name.has_suffix ("-symbolic");
            string color_icon_name;

            if (is_symbolic) {
                color_icon_name = icon_name.replace ("-symbolic", "");
            } else {
                color_icon_name = icon_name;
            }

            var symbolic_icon_name = color_icon_name + "-symbolic";
            var has_color = icon_theme.has_icon (color_icon_name);

            if (!is_symbolic && !has_color) {
                icon_name = symbolic_icon_name;
            }

            title = color_icon_name;
            source_buffer.text = "var icon = new Gtk.Image () {\n    gicon = new ThemedIcon (\"%s\"),\n    pixel_size = 24\n};".printf (icon_name);

            int i = 0;


            var has_symbolic = icon_theme.has_icon (symbolic_icon_name);

            while (color_row.get_first_child () != null) {
                color_row.remove (color_row.get_first_child ());
            }

            while (symbolic_row.get_first_child () != null) {
                symbolic_row.remove (symbolic_row.get_first_child ());
            }

            foreach (int pixel_size in pixels) {
                if (has_color) {
                    var color_icon = new Gtk.Image () {
                        pixel_size = pixel_size,
                        use_fallback = true,
                        valign = Gtk.Align.END
                    };
                    color_icon.gicon = new ThemedIcon (color_icon_name);
                    color_icon.icon_name = icon_name;

                    var color_label = new Gtk.Label ("%ipx".printf (pixels[i])) {
                        hexpand = true
                    };

                    color_row.attach (color_icon, i, 0);
                    color_row.attach (color_label, i, 1);
                }

                if (has_symbolic) {
                    var symbolic_icon = new Gtk.Image.from_icon_name (symbolic_icon_name) {
                        pixel_size = pixel_size,
                        valign = Gtk.Align.END
                    };

                    var symbolic_label = new Gtk.Label ("%ipx".printf (pixels[i])) {
                        hexpand = true
                    };

                    symbolic_row.attach (symbolic_icon, i, 0);
                    symbolic_row.attach (symbolic_label, i, 1);
                }

                i++;
            }

            var not_has_label = new Gtk.Label (_("Unavailable")) {
                hexpand = true,
                height_request = 157
            };
            not_has_label.add_css_class (Granite.STYLE_CLASS_DIM_LABEL);
            not_has_label.add_css_class (Granite.STYLE_CLASS_H3_LABEL);

            if (!has_color) {
                color_row.attach (not_has_label, 0, 0);
            } else if (!has_symbolic) {
                symbolic_row.attach (not_has_label, 0, 0);
            }
        });
    }
}
