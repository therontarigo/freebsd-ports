--- chrome/browser/media/webrtc/webrtc_log_uploader.cc.orig	2019-04-30 22:22:34 UTC
+++ chrome/browser/media/webrtc/webrtc_log_uploader.cc
@@ -393,6 +393,8 @@ void WebRtcLogUploader::SetupMultipart(
   const char product[] = "Chrome_Android";
 #elif defined(OS_CHROMEOS)
   const char product[] = "Chrome_ChromeOS";
+#elif defined(OS_FREEBSD)
+  const char product[] = "Chrome_FreeBSD";
 #else
 #error Platform not supported.
 #endif
