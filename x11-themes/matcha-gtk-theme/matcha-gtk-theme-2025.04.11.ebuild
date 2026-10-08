EAPI=8

DESCRIPTION="A flat design GTK theme based on Arc"
HOMEPAGE="https://github.com/vinceliuice/Matcha-gtk-theme"

SRC_URI="https://github.com/vinceliuice/Matcha-gtk-theme/archive/refs/tags/2025-04-11.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/Matcha-gtk-theme-2025-04-11"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	x11-themes/gtk-engines-murrine
"

src_install() {
	./install.sh --dest "${D}/usr/share/themes"
}
