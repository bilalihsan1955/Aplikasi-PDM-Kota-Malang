import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../widgets/back_button_app.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key, required this.url, this.title});

  final String url;
  final String? title;

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  bool _loading = true;
  String _currentTitle = '';

  @override
  void initState() {
    super.initState();
    _currentTitle = widget.title ?? '';
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) async {
            if (!mounted) return;
            if (widget.title == null || widget.title!.isEmpty) {
              final pageTitle = await _controller.getTitle();
              if (pageTitle != null && pageTitle.isNotEmpty && mounted) {
                setState(() => _currentTitle = pageTitle);
              }
            }
            if (mounted) setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<bool> _onWillPop() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return false;
    }
    return true;
  }

  /// Muat ulang halaman yang sedang terbuka (setelah navigasi di dalam WebView),
  /// bukan hanya URL awal yang dibuka dari route.
  Future<void> _refreshCurrentPage() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final href = await _controller.currentUrl();
      final uri = (href != null && href.isNotEmpty) ? Uri.tryParse(href) : null;
      if (uri != null) {
        try {
          await _controller.runJavaScript('window.location.reload();');
        } catch (_) {
          await _controller.loadRequest(uri);
        }
      } else {
        final initial = Uri.tryParse(widget.url);
        if (initial != null) {
          await _controller.loadRequest(initial);
        } else if (mounted) {
          setState(() => _loading = false);
        }
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(88),
          child: _WebViewHeader(
            title: _currentTitle,
            isDark: isDark,
            // App bar: keluar WebView ke layar app sebelumnya (bukan riwayat halaman di dalam WebView).
            onBack: () {
              if (context.mounted) context.pop();
            },
            onRefresh: () => unawaited(_refreshCurrentPage()),
          ),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            WebViewWidget(controller: _controller),
            if (_loading)
              const LinearProgressIndicator(
                color: Color(0xFF152D8D),
                backgroundColor: Colors.transparent,
                minHeight: 3,
              ),
          ],
        ),
      ),
    );
  }
}

class _WebViewHeader extends StatelessWidget implements PreferredSizeWidget {
  const _WebViewHeader({
    required this.title,
    required this.isDark,
    required this.onBack,
    required this.onRefresh,
  });

  final String title;
  final bool isDark;
  final VoidCallback onBack;
  final VoidCallback onRefresh;

  @override
  Size get preferredSize => const Size.fromHeight(88);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  BackButtonApp(onTap: onBack),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title.isNotEmpty ? title : 'Memuat...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF2D3142),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onRefresh,
                    tooltip: 'Muat ulang',
                    icon: Icon(
                      RemixIcons.refresh_line,
                      size: 22,
                      color: isDark ? Colors.white70 : const Color(0xFF2D3142),
                    ),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(44, 44),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
