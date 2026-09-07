import 'repositories/record_repository.dart';

/// 当前用户（I Stage 最小实现：本地单用户，无强制登录）。
/// 首次访问确定一个持久化的 user id 供各 feature 复用。
class CurrentUser {
  CurrentUser({required RecordRepository repository}) : _repo = repository;

  final RecordRepository _repo;

  int? _id;

  Future<int> id() async {
    if (_id != null) return _id!;
    // 本地字体：仅内存缓存，避免每次查询；账号漫游（27 章）后续增强。
    _id = await _repo.currentUserId();
    return _id!;
  }
}