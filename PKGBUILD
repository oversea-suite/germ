# Maintainer: oversea-suite
pkgname=germ-git
pkgver=r0.0000000
pkgrel=1
pkgdesc="GEneral Resource Manager"
arch=('any')
url="https://github.com/oversea-suite/germ"
license=('LGPLv2.1')
depends=('bash' 'python' 'probed')
provides=('germ')
conflicts=('germ')
source=("git+https://github.com/oversea-suite/germ.git")
sha256sums=('SKIP')

pkgver() {
    cd germ
    printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
}

package() {
    cd germ
    install -Dm755 germ          "$pkgdir/usr/bin/germ"
}
