# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="3D Pinball Space Cadet with voice announcements (Creatiel fork)"
HOMEPAGE="https://creatiel.info/logiciels/3d-pinball-space-cadet-talking/"

# Upstream only ships a prebuilt Ubuntu 24.04 amd64 .deb. Nothing is
# downloaded: the archive is stored in this package's files/ directory
# and is repackaged below.
DEB_FILE="SpaceCadetPinball-Talking-${PV}-2-Ubuntu24.04-amd64.deb"
SRC_URI=""
S="${WORKDIR}/data"

LICENSE="MIT OFL-1.1"
SLOT="0"
KEYWORDS="-* ~amd64"

RESTRICT="fetch strip"
QA_PREBUILT="usr/lib/spacecadetpinball-talking/SpaceCadetPinball"

RDEPEND="
	media-libs/libsdl2
	media-libs/sdl2-mixer
	media-sound/fluid-soundfont
	media-sound/timidity++
"

src_unpack() {
	local deb="${FILESDIR}/${DEB_FILE}"

	[[ -f ${deb} ]] || die "${DEB_FILE} not found in ${FILESDIR}"

	mkdir -p "${WORKDIR}/deb" "${S}" || die
	pushd "${WORKDIR}/deb" >/dev/null || die
	ar x "${deb}" || die "failed to extract ${DEB_FILE}"

	local data_archive
	data_archive=$(ls data.tar.* 2>/dev/null | head -n 1)
	[[ -n ${data_archive} ]] || die "no data.tar.* member found in ${DEB_FILE}"

	tar -xf "${data_archive}" -C "${S}" || die "failed to unpack ${data_archive}"
	popd >/dev/null || die
}

src_install() {
	exeinto /usr/lib/spacecadetpinball-talking
	doexe "${S}"/usr/lib/spacecadetpinball-talking/SpaceCadetPinball

	dobin "${S}"/usr/bin/spacecadetpinball-talking

	# The game looks for these fonts next to its own binary.
	dosym ../../share/spacecadetpinball-talking/unifont-17.0.03.otf \
		/usr/lib/spacecadetpinball-talking/unifont-17.0.03.otf
	dosym ../../share/spacecadetpinball-talking/unifont_jp-17.0.03.otf \
		/usr/lib/spacecadetpinball-talking/unifont_jp-17.0.03.otf

	insinto /usr/share
	doins -r "${S}"/usr/share/spacecadetpinball-talking

	insinto /usr/share/applications
	doins "${S}"/usr/share/applications/spacecadetpinball-talking.desktop

	insinto /usr/share/icons/hicolor/128x128/apps
	doins "${S}"/usr/share/icons/hicolor/128x128/apps/spacecadetpinball-talking.png

	dodoc "${S}"/usr/share/spacecadetpinball-talking/CHANGELOG.TXT
	dodoc "${S}"/usr/share/spacecadetpinball-talking/LIRE-MOI.txt
	dodoc "${S}"/usr/share/spacecadetpinball-talking/UNIFONT-NOTICE.TXT
}
