# Created by: Tom Judge <tj@FreeBSD.org>
# $FreeBSD$

PORTNAME=	sigar
PORTVERSION=	1.7.3
PORTREVISION=	9
CATEGORIES=	java devel
PKGNAMEPREFIX=	java-

MAINTAINER=	ports@FreeBSD.org
COMMENT=	Java bindings for the Sigar system information API

LICENSE=	APACHE20
LICENSE_FILE=	${WRKSRC}/NOTICE

BROKEN_armv6=		fails to compile: jni-build.xml: gcc failed with return code 1
BROKEN_armv7=		fails to compile: jni-build.xml: gcc failed with return code 1
BROKEN_powerpc64=	fails to install: bindings/java/sigar-bin/lib/libsigar-powerpc64-freebsd-1.so: No such file or directory

BUILD_DEPENDS=	${ANT_CMD}:devel/apache-ant
LIB_DEPENDS=	libsigar.so:devel/sigar

USE_GITHUB=	yes
GH_ACCOUNT=	amishHammer
GH_TAGNAME=	b5af695

USES=		perl5
USE_PERL5=	build
USE_JAVA=	yes
JAVA_RUN=	yes
USE_GCC=	any
NO_CCACHE=	yes

ANT_CMD?=	${LOCALBASE}/bin/ant
ANT=		${SETENV} JAVA_HOME=${JAVA_HOME} ${ANT_CMD}

.include <bsd.port.pre.mk>

.if ${OPSYS} == FreeBSD
PLATFORM_VER=	1
.else
IGNORE=		${OPSYS} platform is not supported
.endif

LIBNAME=	libsigar-${ARCH:S,i386,x86,}-${OPSYS:tl}-${PLATFORM_VER}.so

PLIST_FILES=	%%JAVAJARDIR%%/${PORTNAME}.jar \
		%%JAVAJARDIR%%/${LIBNAME}

#post-patch:
#	@${REINPLACE_CMD} s/gcc/${CC}/ \
#                ${WRKSRC}/bindings/java/hyperic_jni/jni-build.xml

do-build:
	${MKDIR} ${WRKSRC}/bin
.if ${CC} != "gcc"
	${LN} -s ${LOCALBASE}/bin/${CC} ${WRKSRC}/bin/gcc
.endif
	cd ${WRKSRC}/bindings/java && PATH=${PATH}:${WRKSRC}/bin ${ANT}

do-install:
	${INSTALL_DATA} ${WRKSRC}/bindings/java/sigar-bin/lib/sigar.jar \
		${STAGEDIR}${JAVAJARDIR}/${PORTNAME}.jar
	${INSTALL_LIB} ${WRKSRC}/bindings/java/sigar-bin/lib/libsigar-${ARCH:S,i386,x86,}-freebsd-${PLATFORM_VER}.so \
		${STAGEDIR}${JAVAJARDIR}/${LIBNAME}

.include <bsd.port.post.mk>
