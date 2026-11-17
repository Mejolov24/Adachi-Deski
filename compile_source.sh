echo "Run this at the root directory of the godot 4.7.2-stable release, proyect file a directory up"
echo "I Recommend Symlinking this"
echo "I skip arm64 recompilations for windows because it takes to freaking long, and linux because its alredy light enough"

scons platform=windows target=template_release profile=../Adachi-Deski/scons_settings.py build_profile=../Adachi-Deski/build_config.gdbuild winrt=no lto=none arch=x86_64 -j$(nproc)
scons platform=windows target=template_release profile=../Adachi-Deski/scons_settings.py build_profile=../Adachi-Deski/build_config.gdbuild winrt=no lto=none arch=x86_32 -j$(nproc)
scons platform=linux target=template_release profile=../Adachi-Deski/scons_settings.py build_profile=../Adachi-Deski/build_config.gdbuild arch=x86_64 -j$(nproc)
scons platform=linux target=template_release profile=../Adachi-Deski/scons_settings.py build_profile=../Adachi-Deski/build_config.gdbuild arch=x86_32 -j$(nproc)