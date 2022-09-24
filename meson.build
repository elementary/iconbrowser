project('io.elementary.iconbrowser', 'vala', 'c')

gnome = import('gnome')
i18n = import('i18n')

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

gresource = gnome.compile_resources(
    'as-resources',
    'data' / 'iconbrowser.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

executable(
    meson.project_name(),
    gresource,
    'src/Application.vala',
    'src/CategoryView.vala',
    'src/IconView.vala',
    'src/MainWindow.vala',
    'src/Widgets/IconListRow.vala',
    'src/Widgets/SidebarRow.vala',
    dependencies: [
        dependency('glib-2.0'),
        dependency('gobject-2.0'),
        dependency('granite-7'),
        dependency('gtk4'),
        dependency('gtksourceview-5')
    ],
    install : true
)

subdir('data')
subdir('po')

meson.add_install_script('meson/post_install.py')

