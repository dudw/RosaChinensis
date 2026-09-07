import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/di/injection.dart';
import 'current_user.dart';
import 'data_transfer_service.dart';

/// 一次备份的结果。
/// - [path]：成功时的备份文件展示路径（SAF 目录/文件系统路径）。
/// - [sharePath]：可用于系统分享的真实文件路径（SAF 写入时为临时副本）。
/// - [error]：失败时的错误信息。
class BackupResult {
  const BackupResult({this.path, this.sharePath, this.error});

  final String? path;
  final String? sharePath;
  final String? error;

  bool get ok => path != null && error == null;
}

/// 自动备份控制器：开关 + 用户指定备份目录 + 退出时静默 JSON 导出。
///
/// Android 使用存储访问框架（SAF）：
/// - 用户通过系统目录选择器指定目录，系统弹出"允许访问？"授权对话框；
/// - 授权通过 takePersistableUriPermission 持久化，重启 / 升级 App 后依然有效；
/// - 文件通过 ContentResolver 写入，分区存储下无需申请存储权限。
///
/// 其他平台（桌面 / iOS）使用 file_selector 选择的真实文件系统路径直接写入。
///
/// 文件按日期命名 `period_backup_YYYY-MM-DD.json`，同一天覆盖只保留最新一份。
class AutoBackupController {
  AutoBackupController._();
  static final AutoBackupController instance = AutoBackupController._();

  static const _channel = MethodChannel('com.period.period_tracker/backup');

  static const _pEnabled = 'backup_enabled';
  static const _pDirUri = 'backup_dir_uri'; // Android: content:// URI；其他: 文件系统路径
  static const _pDirPath = 'backup_dir_path'; // 仅用于界面展示

  bool _enabled = false;
  bool _loaded = false;
  String? _dirUri;
  String? _dirPath;

  bool get enabled => _enabled;

  /// 是否已选择备份目录（且 Android 上授权仍有效）。
  bool get hasDir => _dirUri != null && _dirUri!.isNotEmpty;

  /// 备份目录的展示路径。
  String? get dirDisplay => _dirPath ?? _dirUri;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _enabled = prefs.getBool(_pEnabled) ?? false;
      _dirUri = prefs.getString(_pDirUri);
      _dirPath = prefs.getString(_pDirPath);
      // Android：持久化授权可能被系统/用户撤销，启动时校验一次。
      if (Platform.isAndroid && hasDir && _dirUri!.startsWith('content://')) {
        final granted = await _channel.invokeMethod<bool>(
          'hasPermission',
          {'uri': _dirUri},
        );
        if (granted != true) {
          _dirUri = null;
          _dirPath = null;
          await prefs.remove(_pDirUri);
          await prefs.remove(_pDirPath);
        }
      }
      _loaded = true;
    } catch (_) {
      _loaded = true;
    }
  }

  Future<void> setEnabled(bool v) async {
    _enabled = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pEnabled, v);
  }

  /// 打开系统目录选择器并持久化授权。
  /// 返回 true 表示选择成功；用户取消返回 false。
  Future<bool> pickDirectory() async {
    String? uri;
    String? display;
    if (Platform.isAndroid) {
      final res = await _channel.invokeMapMethod<String, String>('pickDirectory');
      if (res == null) return false; // 用户取消
      uri = res['uri'];
      display = res['path'];
    } else {
      final dir = await getDirectoryPath();
      if (dir == null) return false;
      uri = dir;
      display = dir;
    }
    if (uri == null || uri.isEmpty) return false;
    _dirUri = uri;
    _dirPath = display;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pDirUri, uri);
    if (display != null) await prefs.setString(_pDirPath, display);
    return true;
  }

  Future<void> clear() async {
    _enabled = false;
    _dirUri = null;
    _dirPath = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pEnabled);
    await prefs.remove(_pDirUri);
    await prefs.remove(_pDirPath);
  }

  /// 自动备份入口（退出 App 时静默调用）：必须开启且已选目录。
  Future<bool> backupNow() async {
    if (!_loaded) await load();
    if (!_enabled || !hasDir) return false;
    final r = await _doBackup();
    return r.ok;
  }

  /// 手动立即备份：只需已选目录，不依赖开关。
  Future<BackupResult> backupManual() async {
    if (!_loaded) await load();
    if (!hasDir) {
      return const BackupResult(error: '请先选择备份目录');
    }
    return _doBackup();
  }

  Future<BackupResult> _doBackup() async {
    try {
      final userId = await getIt<CurrentUser>().id();
      final svc = getIt<DataTransferService>();
      final json = const JsonEncoder.withIndent('  ')
          .convert(await svc.exportJson(userId));
      final name =
          'period_backup_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.json';

      String displayPath;
      String sharePath;
      if (Platform.isAndroid && _dirUri!.startsWith('content://')) {
        // SAF：通过原生 ContentResolver 写入用户授权的目录。
        final written = await _channel.invokeMethod<String>(
          'writeFile',
          {'treeUri': _dirUri, 'fileName': name, 'content': json},
        );
        displayPath = written ?? '$_dirPath/$name';
        // 分享需要真实文件路径：写一份临时副本供系统分享使用。
        final tmp = File(p.join((await getTemporaryDirectory()).path, name));
        await tmp.writeAsString(json, flush: true);
        sharePath = tmp.path;
      } else {
        // 桌面 / iOS：直接写文件系统路径。
        final dir = Directory(_dirUri!);
        if (!await dir.exists()) await dir.create(recursive: true);
        final file = File(p.join(dir.path, name));
        await file.writeAsString(json, flush: true);
        displayPath = file.path;
        sharePath = file.path;
      }
      // ignore: avoid_print
      print('[AutoBackup] backup written: $displayPath');
      return BackupResult(path: displayPath, sharePath: sharePath);
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print('[AutoBackup] ERROR: ${e.code} ${e.message}');
      return BackupResult(error: e.message ?? e.code);
    } catch (e, st) {
      // ignore: avoid_print
      print('[AutoBackup] ERROR: $e\n$st');
      return BackupResult(error: '$e');
    }
  }
}
