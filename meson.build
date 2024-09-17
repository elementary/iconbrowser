project(
    'io.elementary.iconbrowser',
    'vala', 'c',
    meson_version: '>= 0.57'
)

gnome = import('gnome')
i18n = import('i18n')

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

config_data = configuration_data()
config_data.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))
config_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
config_file = configure_file(
    input: 'src/Config.vala.in',
    output: '@BASENAME@',
    configuration: config_data
)

gresource = gnome.compile_resources(
    'as-resources',
    'data' / 'iconbrowser.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

executable(
    meson.project_name(),
    config_file,
    gresource,
    'src/Application.vala',
    'src/CategoryView.vala',
    'src/MainWindow.vala',
    'src/Services/Collection.vala',
    'src/Widgets/IconListChild.vala',
    'src/Widgets/SidebarRow.vala',
    'src/Dialogs/IconView.vala',
    dependencies: [
        dependency('glib-2.0', version: '>= 2.78'),
        dependency('gobject-2.0'),
        dependency('granite-7'),
        dependency('gtk4'),
        dependency('gtksourceview-5'),
        dependency('libadwaita-1')
    ],
    install : true
)

subdir('data')
subdir('po')

gnome.post_install(
    glib_compile_schemas: true,
    gtk_update_icon_cache: true
)
