# Created by: TAKATSU Tomonari <tota@FreeBSD.org>
# $FreeBSD$

PORTNAME=	rngtools
PORTVERSION=	1.3.1.1
CATEGORIES=	devel
DISTNAME=	${PORTNAME}_${PORTVERSION}

MAINTAINER=	tota@FreeBSD.org
COMMENT=	Utility functions for working with Random Number Generators

LICENSE=	GPLv3

CRAN_DEPENDS=	R-cran-pkgmaker>=0.20:devel/R-cran-pkgmaker
BUILD_DEPENDS=	${CRAN_DEPENDS}
RUN_DEPENDS=	${CRAN_DEPENDS}

USES=	cran:auto-plist

.include <bsd.port.mk>
