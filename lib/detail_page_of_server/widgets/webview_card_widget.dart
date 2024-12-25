import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../detail_page_vm.dart';

class WebViewCardWidget extends StatefulWidget {
  final DetailPageVM viewModel;
  final String url;

  const WebViewCardWidget({
    Key? key,
    required this.viewModel,
    required this.url,
  }) : super(key: key);

  @override
  State<WebViewCardWidget> createState() => _WebViewCardWidgetState();
}

class _WebViewCardWidgetState extends State<WebViewCardWidget> {
  late final WebViewController controller;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    initializeWebView();
  }

  void initializeWebView() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..enableZoom(false) // Add this if you want to disable zooming
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                // You can use this progress value to show a progress indicator
                // widget.viewModel.updateWebViewLoadingProgress(progress);
              });
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                isLoading = true;
                errorMessage = null;
                // widget.viewModel.setWebViewLoading(true);
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                isLoading = false;
                // widget.viewModel.setWebViewLoading(false);
              });
            }
          },
          onHttpError: (HttpResponseError error) {
            if (mounted) {
              setState(() {
                errorMessage = 'HTTP Error: ${error}';
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              setState(() {
                errorMessage = error.description;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            // You can add URL validation here if needed
            return NavigationDecision.navigate;
          },
        ),
      );

    // Load the URL after controller is initialized
    controller.loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF222832)
          : const Color(0xFFF5F5F5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 250,
          child: Stack(
            children: [
              WebViewWidget(controller: controller),
              // if (isLoading &&
              //     errorMessage ==
              //         null) // Display only when loading and no error
              //   const Center(
              //     child: CircularProgressIndicator(),
              //   ),
              if (errorMessage != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}





// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import '../detail_page_vm.dart';
// import 'bar_chart_of_cpu.dart';

// Widget webViewCard(BuildContext context, DetailPageVM viewModel, String url) {
//   WebViewController controller = WebViewController()
//     ..setJavaScriptMode(JavaScriptMode.unrestricted)
//     ..setBackgroundColor(const Color(0x00000000))
//     ..setNavigationDelegate(
//       NavigationDelegate(
//         onProgress: (int progress) {
//           // viewModel.updateWebViewLoadingProgress(progress);
//         },
//         onPageStarted: (String url) {
//           // viewModel.setWebViewLoading(true);
//         },
//         onPageFinished: (String url) {
//           // viewModel.setWebViewLoading(false);
//         },
//         onHttpError: (HttpResponseError error) {},
//         onWebResourceError: (WebResourceError error) {},
//         onNavigationRequest: (NavigationRequest request) {
//           return NavigationDecision.navigate;
//         },
//       ),
//     )
//     ..loadRequest(Uri.parse(url));
//   return Card(
//     elevation: 10,
//     color: Theme.of(context).brightness == Brightness.dark
//         ? const Color(0xFF222832)
//         : const Color(0xFFF5F5F5),
//     child: ClipRRect(
//       borderRadius: BorderRadius.circular(10),
//       child: SizedBox(
//         height: 250, // Fixed height
//         child: Stack(
//           children: [
//             WebViewWidget(controller: controller),
//             // if (viewModel.isWebViewLoading)
//             // Center(child: CircularProgressIndicator()),
//           ],
//         ),
//       ),
//     ),
//   );
// }
