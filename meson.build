project(
    'mfg-dl-gui',
    ['vala', 'c'],
    version: '0.1.0',
)

dependencies = [
    dependency('gtk4'),
    dependency('libsoup-3.0'),
    dependency('json-glib-1.0'),
]

sources = files(
    'src/application.vala',
    'src/main.vala',
    'src/window.vala',
)

executable(
    'mfg-dl-gui',
    sources,
    dependencies: dependencies,
    install: true,
)
