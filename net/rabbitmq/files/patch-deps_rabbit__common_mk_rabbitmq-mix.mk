--- deps/rabbit_common/mk/rabbitmq-mix.mk.orig	2019-05-17 11:55:28 UTC
+++ deps/rabbit_common/mk/rabbitmq-mix.mk
@@ -5,6 +5,7 @@
 
 HEX_OFFLINE=1
 
-HOME=$(DEPS_DIR)
+override MIX_HOME=$(DEPS_DIR)/.mix
+override HOME=$(DEPS_DIR)
 
-export HEX_OFFLINE HOME
+export HEX_OFFLINE MIX_HOME HOME
