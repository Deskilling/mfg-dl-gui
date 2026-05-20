project(
    'mfg-dl-gui',
    ['vala', 'c'],
    version: '0.1.0',
)

dependencies = [
    dependency('gtk4'),
    dependency('libsoup-3.0'),
    dependency('json-glib-1.0'),
    dependency('libadwaita-1'),
]

sources = files(
    'src/api/api.vala',
    'src/application.vala',
    'src/main.vala',
    'src/views/search.vala',
    'src/window.vala',
)

executable(
    'mfg-dl-gui',
    sources,
    dependencies: dependencies,
    install: true,
)
