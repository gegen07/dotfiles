clang-install:
  pkg.installed:
    - pkgs:
      - clang
      - clang-format
      - clang-tidy

clang-tools-install:
  pkg.installed:
    - pkgs:
      - cmake
      - gdb
      - make
      - valgrind
