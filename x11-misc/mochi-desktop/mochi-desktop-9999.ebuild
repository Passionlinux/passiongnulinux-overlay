# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=setuptools

inherit desktop distutils-r1 git-r3 gnome2-utils

DESCRIPTION="A tiny, local-first desktop companion for Linux"
HOMEPAGE="https://github.com/miflow13/mochi-desktop"

# Live ebuild: tracks the branch that carries the cross-desktop work.
# To build straight from a local checkout instead, set MOCHI_GIT_REPO, e.g.:
#   MOCHI_GIT_REPO="file:///home/sebastien/Projets/IA/mochi" \
#       ebuild mochi-desktop-9999.ebuild clean install
# Setting EGIT_REPO_URI in the environment does not work: this assignment wins.
EGIT_REPO_URI="${MOCHI_GIT_REPO:-https://github.com/Passionlinux/mochi-desktop.git}"
EGIT_BRANCH="main"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE="gnome self-update"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

# Upstream's suite exercises the in-app self-updater that the ${FILESDIR}
# patch removes, so it is not run when the patch is applied.
RESTRICT="test"

RDEPEND="
	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/pycairo[${PYTHON_USEDEP}]
		dev-python/pygobject:3[${PYTHON_USEDEP},cairo]
	')
	app-accessibility/at-spi2-core:2[introspection]
	dev-libs/glib:2
	gui-libs/gtk:4[X]
	gui-libs/gtk4-layer-shell:0[introspection]
	media-libs/gst-plugins-base:1.0[ogg,vorbis]
	media-libs/gst-plugins-good:1.0
	media-libs/gstreamer:1.0
	x11-base/xwayland
	x11-libs/libX11
	x11-libs/libXScrnSaver
	gnome? ( gnome-base/gnome-shell:0 )
"
DEPEND="${RDEPEND}"

src_prepare() {
	default

	# Portage owns updates on a system-wide install, so the bundled GitHub
	# self-updater is compiled out unless the user explicitly asks for it.
	use self-update || eapply "${FILESDIR}"/mochi-desktop-disable-self-update.patch
}

python_install_all() {
	distutils-r1_python_install_all

	if ! use self-update; then
		# The updater CLI targets install.sh's private virtualenv and cannot
		# replace files owned by Portage.
		rm "${ED}"/usr/bin/mochi-update || die
	fi

	# Desktop entry; Exec points at the console script installed above.
	sed -e 's|@MOCHI_EXEC@|mochi|' \
		"${S}"/packaging/io.github.mochi_desktop.Mochi.desktop.in \
		> "${T}"/io.github.mochi_desktop.Mochi.desktop || die
	newmenu "${T}"/io.github.mochi_desktop.Mochi.desktop \
		io.github.mochi_desktop.Mochi.desktop

	# Application icon, hicolor theme.
	newicon -s 256 "${S}"/assets/mochi/master/mochi_default.png \
		io.github.mochi_desktop.Mochi.png

	if use gnome; then
		local extension_dir=/usr/share/gnome-shell/extensions/mochi-typing@miflow13

		insinto "${extension_dir}"
		doins "${S}"/gnome-extension/mochi-typing@miflow13/metadata.json
		doins "${S}"/gnome-extension/mochi-typing@miflow13/extension.js
		doins "${S}"/gnome-extension/mochi-typing@miflow13/README.md

		insinto /usr/share/glib-2.0/schemas
		newins "${S}"/gnome-extension/mochi-typing@miflow13/schemas/org.gnome.shell.extensions.mochi-activity.gschema.xml \
			org.gnome.shell.extensions.mochi-activity.gschema.xml
	fi
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update
	gnome2_schemas_update

	if use gnome; then
		elog "The GNOME Shell helper is installed but is enabled per user:"
		elog "  gnome-extensions enable mochi-typing@miflow13"
		elog "It requires GNOME Shell 50."
	fi
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
	gnome2_schemas_update
}
