# Created by: James Hunt <james.hunt@ubuntu.com>
# $FreeBSD$

PORTNAME=	procenv
PORTVERSION=	0.50
CATEGORIES=	sysutils

MAINTAINER=	ports@FreeBSD.org
COMMENT=	Utility to show process environment

LICENSE=	GPLv3+
LICENSE_FILE=	${WRKSRC}/COPYING

BUILD_DEPENDS=	xmlwf:textproc/expat2

USES=		autoreconf gmake perl5
USE_PERL5=	build

USE_GITHUB=	yes
GH_ACCOUNT=	jamesodhunt
GH_TAGNAME=	d89b0ac

GNU_CONFIGURE=	yes
TEST_TARGET=	check

PORTDOCS=	AUTHORS ChangeLog NEWS README TODO
PLIST_FILES=	bin/procenv \
		man/man1/procenv.1.gz

OPTIONS_DEFINE=	DOCS

post-install-DOCS-on:
	${MKDIR} ${STAGEDIR}${DOCSDIR}
.for f in ${PORTDOCS}
	${INSTALL_DATA} ${WRKSRC}/${f} ${STAGEDIR}${DOCSDIR}
.endfor

.include <bsd.port.mk>
