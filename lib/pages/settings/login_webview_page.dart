import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';

class LoginWebviewPage extends StatefulWidget {
  const LoginWebviewPage({super.key, this.initialUrl});

  final String? initialUrl;

  @override
  State<LoginWebviewPage> createState() => _LoginWebviewPageState();
}

class _LoginWebviewPageState extends State<LoginWebviewPage> {
  final WebviewController _controller = WebviewController();
  final TextEditingController _urlController = TextEditingController();

  bool _ready = false;

  @override
  void initState() {
    super.initState();
    final initialUrl = widget.initialUrl ?? 'https://www.cycani.org/login';
    _urlController.text = initialUrl;
    _init(initialUrl);
  }

  Future<void> _init(String url) async {
    try {
      await _controller.initialize();
      await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.allow);
      await _controller.loadUrl(url);
    } catch (e) {
      // 登录页初始化失败时也不至于卡死；用户仍可看到空页面并返回。
    }
    if (mounted) {
      setState(() => _ready = true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _loadUrl(String value) {
    String url = value.trim();
    if (url.isEmpty) return;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    _controller.loadUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('站点登录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '刷新',
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  tooltip: '后退',
                  onPressed: () => _controller.goBack(),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  tooltip: '前进',
                  onPressed: () => _controller.goForward(),
                ),
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      hintText: '输入网址',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: _loadUrl,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_right),
                  tooltip: '打开',
                  onPressed: () => _loadUrl(_urlController.text),
                ),
              ],
            ),
          ),
          Expanded(
            child: _ready
                ? Webview(_controller)
                : const Center(child: CircularProgressIndicator()),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              '在此登录目标站点，登录状态会自动保存；登录成功后直接返回即可。',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
