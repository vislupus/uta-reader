# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file LICENSE.rst or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION ${CMAKE_VERSION}) # this file comes with cmake

# If CMAKE_DISABLE_SOURCE_CHANGES is set to true and the source directory is an
# existing directory in our source tree, calling file(MAKE_DIRECTORY) on it
# would cause a fatal error, even though it would be a no-op.
if(NOT EXISTS "C:/Users/n.bojinov/Downloads/Flutter/uta_reader_app/build/windows/x64/_deps/objectbox-download-src")
  file(MAKE_DIRECTORY "C:/Users/n.bojinov/Downloads/Flutter/uta_reader_app/build/windows/x64/_deps/objectbox-download-src")
endif()
file(MAKE_DIRECTORY
  "C:/Users/n.bojinov/Downloads/Flutter/uta_reader_app/build/windows/x64/_deps/objectbox-download-build"
  "C:/Users/n.bojinov/Downloads/Flutter/uta_reader_app/build/windows/x64/_deps/objectbox-download-subbuild/objectbox-download-populate-prefix"
  "C:/Users/n.bojinov/Downloads/Flutter/uta_reader_app/build/windows/x64/_deps/objectbox-download-subbuild/objectbox-download-populate-prefix/tmp"
  "C:/Users/n.bojinov/Downloads/Flutter/uta_reader_app/build/windows/x64/_deps/objectbox-download-subbuild/objectbox-download-populate-prefix/src/objectbox-download-populate-stamp"
  "C:/Users/n.bojinov/Downloads/Flutter/uta_reader_app/build/windows/x64/_deps/objectbox-download-subbuild/objectbox-download-populate-prefix/src"
  "C:/Users/n.bojinov/Downloads/Flutter/uta_reader_app/build/windows/x64/_deps/objectbox-download-subbuild/objectbox-download-populate-prefix/src/objectbox-download-populate-stamp"
)

set(configSubDirs Debug)
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "C:/Users/n.bojinov/Downloads/Flutter/uta_reader_app/build/windows/x64/_deps/objectbox-download-subbuild/objectbox-download-populate-prefix/src/objectbox-download-populate-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "C:/Users/n.bojinov/Downloads/Flutter/uta_reader_app/build/windows/x64/_deps/objectbox-download-subbuild/objectbox-download-populate-prefix/src/objectbox-download-populate-stamp${cfgdir}") # cfgdir has leading slash
endif()
