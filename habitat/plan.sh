#!/usr/bin/env bash

pkg_name="verify-habitat-pkg-files-on-disk"
pkg_origin="ryanwoodsmall"
pkg_maintainer="ryanwoodsmall"
pkg_version="0.0.0"
pkg_deps=(core/bash core/coreutils core/which)
pkg_interpreters=(bin/bash)
pkg_bin_dirs=(bin)
pkg_license=('bsd')

do_build() {
	fix_interpreter "bin/*.sh" core/bash bin/bash
}

do_install() {
	app_path="${pkg_prefix}/bin"
	mkdir -p "${app_path}"
	install -m 0755 "bin/${pkg_name}.sh" "${app_path}/"
}
