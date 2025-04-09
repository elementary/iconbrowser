/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2017-2022 elementary, Inc. (https://elementary.io)
 */
public class IconView : Gtk.Box {
    public string icon_name { get; construct set; }
    public string description { get; construct set; }
    public IconCollection.Category category { get; construct set; }

    private GtkSource.Buffer source_buffer;
    private Gtk.Button copy_button;

    public IconView () {
        Object (
            icon_name: "address-book-new",
            description: _("Create a new address book"),
            category: IconCollection.Category.ACTIONS
        );
    }

    construct {
        var header_icon = new Gtk.Image.from_icon_name (icon_name) {
            icon_size = Gtk.IconSize.LARGE,
            valign = Gtk.Align.START
        };

        var label = new Granite.HeaderLabel (icon_name) {
            secondary_text = description,
            size = H2,
            valign = CENTER
        };

        var window_controls = new Gtk.WindowControls (Gtk.PackType.END) {
            halign = Gtk.Align.END,
            hexpand = true,
            valign = Gtk.Align.START
        };

        var header_area = new Granite.Box (HORIZONTAL, NONE);
        header_area.add_css_class ("header-area");
        header_area.append (header_icon);
        header_area.append (label);
        header_area.append (window_controls);

        var header_handle = new Gtk.WindowHandle () {
            child = header_area
        };
        header_handle.add_css_class ("titlebar");

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
            pixels_below_lines = 3,
            wrap_mode = Gtk.WrapMode.WORD
        };
        source_view.add_css_class (Granite.STYLE_CLASS_CARD);
        source_view.add_css_class (Granite.STYLE_CLASS_ROUNDED);

        copy_button = new Gtk.Button.with_label (_("Copy")) {
            valign = START,
            halign = END,
            margin_top = 6,
            margin_end = 6
        };
        copy_button.add_css_class (Granite.STYLE_CLASS_SMALL_LABEL);

        // Make copy button visible with fade animation when source view contains pointer or focus
        var copy_button_revealer = new Gtk.Revealer () {
            child = copy_button,
            valign = START,
            halign = END,
            transition_type = CROSSFADE,
            overflow = VISIBLE
        };

        var copy_controller_motion = new Gtk.EventControllerMotion ();
        copy_controller_motion.bind_property (
            "contains-pointer", copy_button_revealer, "reveal-child", DEFAULT | SYNC_CREATE
        );

        var copy_controller_focus = new Gtk.EventControllerFocus ();
        copy_controller_focus.bind_property (
            "contains-focus", copy_button_revealer, "reveal-child", DEFAULT | SYNC_CREATE
        );

        var source_overlay = new Gtk.Overlay () {
            child = source_view
        };
        source_overlay.add_overlay (copy_button_revealer);
        source_overlay.add_controller (copy_controller_motion);
        source_overlay.add_controller (copy_controller_focus);

        var content_area = new Gtk.Box (Gtk.Orientation.VERTICAL, 12) {
            vexpand = true
        };
        content_area.add_css_class ("content-area");
        content_area.append (color_title);
        content_area.append (color_row);
        content_area.append (symbolic_title);
        content_area.append (symbolic_row);
        content_area.append (snippet_title);
        content_area.append (source_overlay);

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
        bind_property ("icon-name", label, "label");
        bind_property ("description", label, "secondary-text");

        notify["icon-name"].connect (() => {
            fill_icon_row (icon_name, color_row);
            fill_icon_row (icon_name + "-symbolic", symbolic_row);

            var first_color_child = color_row.get_child_at_index (0);
            if (first_color_child != null && first_color_child is IconChild) {
                first_color_child.activate ();
            } else {
                symbolic_row.get_child_at_index (0).activate ();
            }
        });

        color_row.child_activated.connect ((child) => {
            symbolic_row.unselect_all ();
            child_activated (child);
        });

        symbolic_row.child_activated.connect ((child) => {
            color_row.unselect_all ();
            child_activated (child);
        });

        copy_button.clicked.connect (copy_button_clicked);
    }

    private void child_activated (Gtk.FlowBoxChild child) {
        if (child is IconChild) {
            var icon = (IconChild) child;

            if (icon.icon_size > 16) {
                source_buffer.text = "var icon = new Gtk.Image.from_icon_name (\"%s\") {\n    pixel_size = %i\n};".printf (
                    icon.icon_name, icon.icon_size
                );
            } else {
                source_buffer.text = "var icon = new Gtk.Image.from_icon_name (\"%s\");".printf (icon.icon_name);
            }
        }
    }

    private void copy_button_clicked () {
        unowned var clipboard = get_clipboard ();
        clipboard.set_text (source_buffer.text);

        copy_button.label = _("Copied!");
        Timeout.add_once (1000, () => {
            copy_button.label = _("Copy");
        });
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
            case IconCollection.Category.ACTIONS:
            case IconCollection.Category.EMBLEMS:
                sizes = {16, 24, 32, 48};
                break;
            case IconCollection.Category.EMOTES:
                sizes = {16};
                break;
            default:
                sizes = {16, 24, 32, 48, 64, 128};
                break;
        }

        row.can_target = true;
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
