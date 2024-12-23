import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../detail_page_vm.dart';
import 'bar_chart_of_cpu.dart';

Widget webViewSwaggerCard(
    BuildContext context, DetailPageVM viewModel, String url) {
  WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000))
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // viewModel.updateWebViewLoadingProgress(progress);
        },
        onPageStarted: (String url) {
          viewModel.setWebViewLoading(true);
        },
        onPageFinished: (String url) {
          viewModel.setWebViewLoading(false);
        },
        onHttpError: (HttpResponseError error) {},
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) {
          return NavigationDecision.navigate;
        },
      ),
    )
    ..loadRequest(Uri.parse(url));
  return Card(
    elevation: 10,
    color: Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF222832)
        : const Color(0xFFF5F5F5),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        height: 250, // Fixed height
        child: Stack(
          children: [
            WebViewWidget(controller: controller),
            if (viewModel.isWebViewLoading)
              Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    ),
  );
}
