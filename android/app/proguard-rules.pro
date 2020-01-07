# Keep all Stripe push provisioning related classes
-keep class com.stripe.android.pushProvisioning.** { *; }

# Optional: Suppress warnings about missing Stripe push provisioning classes
-dontwarn com.stripe.android.pushProvisioning.**

# Suppress warnings about missing classes
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.PaymentsClient
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.Wallet
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.WalletUtils
-dontwarn proguard.annotation.Keep
-dontwarn proguard.annotation.KeepClassMembers

# Keep ProGuard annotations to avoid removal
-keep class proguard.annotation.Keep { *; }
-keep class proguard.annotation.KeepClassMembers { *; }

# Keep Razorpay classes and any other relevant classes
-keep class com.razorpay.** { *; }
