import 'dart:async';
import 'package:bepop_ngu/utils/labelKeys.dart';
import 'package:bepop_ngu/utils/utils.dart';
import 'package:bepop_ngu/ui/widgets/customAppbar.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

/// Payment WebView for handling payment gateway integrations
///
/// IMPORTANT: This webview only handles the payment UI flow.
/// Actual payment verification MUST be done on the backend via:
/// - Payment gateway webhooks/callbacks
/// - Backend API verification
///
/// This webview will:
/// 1. Load the payment URL from payment gateway
/// 2. Allow user to complete payment
/// 3. Detect redirect URLs (success/failure) and close the webview
/// 4. Backend handles actual payment verification via webhooks
/// 5. App should poll/listen for payment status from backend
class PaymentWebView extends StatefulWidget {
  const PaymentWebView({Key? key}) : super(key: key);

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  WebViewController? _controller;
  late final Map<String, dynamic> arguments;
  bool isLoading = true;
  bool isInitializing = true;
  bool canPop = false;
  Timer? _sessionTimer;

  // Payment session timeout (10 minutes)
  static const int _sessionTimeoutMinutes = 10;

  // Expected redirect URL patterns from backend
  late final String? _successRedirectUrl;
  late final String? _failureRedirectUrl;
  late final String? _cancelRedirectUrl;

  @override
  void initState() {
    super.initState();

    // Get arguments passed from previous screen
    arguments = Get.arguments as Map<String, dynamic>;

    // Get redirect URLs from backend (these should be provided by backend)
    _successRedirectUrl = arguments['successRedirectUrl'] as String?;
    _failureRedirectUrl = arguments['failureRedirectUrl'] as String?;
    _cancelRedirectUrl = arguments['cancelRedirectUrl'] as String?;

    // Initialize webview
    _initializeWebView();

    // Start session timeout
    _startSessionTimeout();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  /// Start a timeout timer for the payment session
  void _startSessionTimeout() {
    _sessionTimer = Timer(
      Duration(minutes: _sessionTimeoutMinutes),
      () {
        if (mounted) {
          _handlePaymentTimeout();
        }
      },
    );
  }

  /// Handle payment session timeout
  void _handlePaymentTimeout() {
    if (kDebugMode) {
      print("Payment session timeout after $_sessionTimeoutMinutes minutes");
    }

    Utils.showCustomSnackBar(
      context: context,
      errorMessage: Utils.getTranslatedLabel('paymentSessionExpired'),
      backgroundColor: Theme.of(context).colorScheme.error,
    );

    // Return null to indicate timeout (not success or explicit failure)
    Get.back(result: null);
  }

  /// Initialize the WebView controller with proper configuration
  void _initializeWebView() {
    // Fallback timeout to ensure we don't stay in initializing state forever
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && isInitializing) {
        setState(() {
          isInitializing = false;
        });
      }
    });

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..enableZoom(true)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (!mounted) return;

            if (kDebugMode) {
              print("Page started loading: $url");
            }

            setState(() {
              isLoading = true;
            });

            // Check if we've reached a redirect URL
            _handleRedirectUrl(url);
          },
          onWebResourceError: (WebResourceError error) {
            if (kDebugMode) {
              print("WebView Error: ${error.description} (${error.errorCode})");
            }

            // Only show error for main frame errors
            if (error.errorType == WebResourceErrorType.hostLookup ||
                error.errorType == WebResourceErrorType.timeout ||
                error.errorType == WebResourceErrorType.connect) {
              if (mounted) {
                Utils.showCustomSnackBar(
                  context: context,
                  errorMessage:
                      'Failed to load payment page. Please check your connection.',
                  backgroundColor: Theme.of(context).colorScheme.error,
                );
              }
            }
          },
          onPageFinished: (String url) {
            if (!mounted) return;

            if (kDebugMode) {
              print("Page finished loading: $url");
            }

            setState(() {
              isLoading = false;
              isInitializing = false;
            });

            // Check again when page finishes loading
            _handleRedirectUrl(url);

            // Apply UI fixes for payment pages
            _applyPaymentPageFixes(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            if (kDebugMode) {
              print("Navigation request: ${request.url}");
            }

            // Check if this is a redirect URL
            if (_handleRedirectUrl(request.url)) {
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(
        Uri.parse(arguments['paymentLink'] as String),
        headers: {
          'Accept': 'text/html,application/xhtml+xml,application/xml',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

    // Update state to trigger rebuild
    if (mounted) {
      setState(() {});
    }
  }

  /// Handle redirect URLs from payment gateway
  /// Returns true if the URL matches a redirect pattern and the webview should close
  ///
  /// IMPORTANT: This method only detects redirects and closes the webview.
  /// The actual payment verification happens on the backend via webhooks.
  /// The app should verify payment status from backend after webview closes.
  bool _handleRedirectUrl(String url) {
    final lowercaseUrl = url.toLowerCase();

    // Priority 1: Check custom redirect URLs from backend
    if (_successRedirectUrl != null && _isUrlMatch(url, _successRedirectUrl!)) {
      if (kDebugMode) {
        print("Success redirect URL detected: $url");
      }
      _closeWebViewWithResult('pending'); // Backend will verify actual status
      return true;
    }

    if (_failureRedirectUrl != null && _isUrlMatch(url, _failureRedirectUrl!)) {
      if (kDebugMode) {
        print("Failure redirect URL detected: $url");
      }
      _closeWebViewWithResult('failed');
      return true;
    }

    if (_cancelRedirectUrl != null && _isUrlMatch(url, _cancelRedirectUrl!)) {
      if (kDebugMode) {
        print("Cancel redirect URL detected: $url");
      }
      _closeWebViewWithResult('cancelled');
      return true;
    }

    // Priority 2: Common payment gateway redirect patterns
    // Note: These are fallback patterns. Backend should provide explicit redirect URLs.

    // Success indicators - close webview, backend will verify
    if (_containsSuccessPattern(lowercaseUrl)) {
      if (kDebugMode) {
        print("Success pattern detected in URL: $url");
      }
      _closeWebViewWithResult('pending');
      return true;
    }

    // Failure/cancellation indicators
    if (_containsFailurePattern(lowercaseUrl)) {
      if (kDebugMode) {
        print("Failure pattern detected in URL: $url");
      }
      _closeWebViewWithResult('failed');
      return true;
    }

    return false;
  }

  /// Check if URL matches the redirect pattern
  bool _isUrlMatch(String url, String redirectUrl) {
    try {
      final uri = Uri.parse(url);
      final redirectUri = Uri.parse(redirectUrl);

      // Match host and path
      return uri.host == redirectUri.host &&
          uri.path.startsWith(redirectUri.path);
    } catch (e) {
      // If parsing fails, do simple string comparison
      return url.toLowerCase().contains(redirectUrl.toLowerCase());
    }
  }

  /// Check if URL contains success patterns
  bool _containsSuccessPattern(String lowercaseUrl) {
    final successPatterns = [
      'status=successful',
      'status=success',
      'status=completed',
      'payment=success',
      'payment_status=success',
      '/payment/success',
      '/payment-success',
      '/success?',
      'success=true',
    ];

    return successPatterns.any((pattern) => lowercaseUrl.contains(pattern));
  }

  /// Check if URL contains failure/cancellation patterns
  bool _containsFailurePattern(String lowercaseUrl) {
    final failurePatterns = [
      'status=cancelled',
      'status=canceled',
      'status=failed',
      'status=failure',
      'payment=failed',
      'payment_status=failed',
      '/payment/failed',
      '/payment-failed',
      '/payment/cancel',
      '/payment-cancel',
      '/failed?',
      '/cancel?',
      'cancelled=true',
      'canceled=true',
      'success=false',
    ];

    return failurePatterns.any((pattern) => lowercaseUrl.contains(pattern));
  }

  /// Close the webview and return result to calling screen
  /// Status: 'pending', 'failed', 'cancelled', or 'timeout'
  void _closeWebViewWithResult(String status) {
    _sessionTimer?.cancel();

    // Return status to calling screen
    // Calling screen should verify actual payment status from backend
    Get.back(result: {
      'status': status,
      'message': _getStatusMessage(status),
    });
  }

  /// Get user-friendly message for status
  String _getStatusMessage(String status) {
    switch (status) {
      case 'pending':
        return 'Payment initiated. Verifying payment status...';
      case 'failed':
        return 'Payment failed. Please try again.';
      case 'cancelled':
        return 'Payment cancelled by user.';
      case 'timeout':
        return 'Payment session expired.';
      default:
        return 'Payment completed. Please wait for confirmation.';
    }
  }

  /// Apply UI fixes for payment pages (CSS injection)
  /// This helps improve the display of payment forms in webview
  void _applyPaymentPageFixes(String url) {
    if (_controller == null) return;

    // Apply general mobile-friendly CSS fixes
    _controller!.runJavaScript('''
      (function() {
        try {
          // Add viewport meta tag if not present
          if (!document.querySelector('meta[name="viewport"]')) {
            var meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
            document.head.appendChild(meta);
          }

          // Apply mobile-friendly styles
          var style = document.createElement('style');
          style.innerHTML = `
            body {
              max-width: 100vw !important;
              overflow-x: hidden !important;
            }
            input, select, textarea, button {
              max-width: 100% !important;
              box-sizing: border-box !important;
            }
            form {
              max-width: 100% !important;
              overflow-x: hidden !important;
            }
          `;
          document.head.appendChild(style);
        } catch (e) {
          console.log('Error applying payment page fixes:', e);
        }
      })();
    ''');
  }

  /// Handle back button press
  /// Shows confirmation dialog before closing payment screen
  void _onWillPop() {
    if (!mounted) return;

    if (canPop) {
      // User pressed back twice, close the payment screen
      _closeWebViewWithResult('cancelled');
      return;
    }

    // First back press - show warning
    setState(() {
      canPop = true;
    });

    Utils.showCustomSnackBar(
      context: context,
      errorMessage: Utils.getTranslatedLabel(pressbackagaintoexitKey),
      backgroundColor: Theme.of(context).colorScheme.error,
    );

    // Reset canPop after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          canPop = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    const appBarHeight = 56.0;

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _onWillPop();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Main content with padding to avoid overlap with app bar
            Padding(
              padding: EdgeInsets.only(top: topPadding + appBarHeight),
              child: _buildWebViewContent(),
            ),

            // Custom App Bar at the top
            Container(
              color: const Color(0xFFF4F4F4),
              height: topPadding + appBarHeight,
              width: double.infinity,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: CustomAppBar(
                  title: paymentKey,
                  onPressBackButton: _onWillPop,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the webview content with loading states
  Widget _buildWebViewContent() {
    // Show initial loading state
    if (isInitializing || _controller == null) {
      return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                Utils.getTranslatedLabel('loadingPayment'),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show webview with loading overlay
    return Stack(
      children: [
        // WebView content
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: WebViewWidget(controller: _controller!),
        ),

        // Loading indicator (shows on top of WebView when loading pages)
        if (isLoading && !isInitializing)
          Container(
            color: Colors.white.withValues(alpha: 0.7),
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}
