package com.expenseincome.app

import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayInputStream
import java.security.MessageDigest
import java.security.cert.CertificateFactory
import java.security.cert.X509Certificate

class MainActivity : FlutterActivity() {
    private val channelName = "com.expenseincome.app/signing"

    override fun onCreate(savedInstanceState: Bundle?) {
        WindowCompat.setDecorFitsSystemWindows(window, false)
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getSigningSha1" -> result.success(getSigningSha1())
                    "getSigningSha256" -> result.success(getSigningSha256())
                    else -> result.notImplemented()
                }
            }
    }

    @Suppress("DEPRECATION")
    private fun firstSignature(): android.content.pm.Signature? {
        val packageInfo =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                packageManager.getPackageInfo(
                    packageName,
                    PackageManager.GET_SIGNING_CERTIFICATES,
                )
            } else {
                packageManager.getPackageInfo(packageName, PackageManager.GET_SIGNATURES)
            }

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            packageInfo.signingInfo?.apkContentsSigners?.firstOrNull()
        } else {
            packageInfo.signatures?.firstOrNull()
        }
    }

    /** Certificate fingerprint (colon-separated), matching Firebase / Play Console format. */
    private fun certificateFingerprint(algorithm: String): String? {
        val signature = firstSignature() ?: return null
        val certFactory = CertificateFactory.getInstance("X.509")
        val cert =
            certFactory.generateCertificate(ByteArrayInputStream(signature.toByteArray()))
                as X509Certificate
        val digest = MessageDigest.getInstance(algorithm)
        digest.update(cert.encoded)
        return digest.digest().joinToString(":") { "%02X".format(it) }
    }

    private fun getSigningSha1(): String? = certificateFingerprint("SHA-1")

    private fun getSigningSha256(): String? = certificateFingerprint("SHA-256")
}
