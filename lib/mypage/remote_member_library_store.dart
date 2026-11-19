/// 마이페이지 자료를 기기에 남기고, 로그인이면 MariaDB에도 올린다.
import '../auth/petbefore_api.dart';
import 'member_library_store.dart';

class RemoteMemberLibraryStore implements MemberLibraryStore {
  RemoteMemberLibraryStore(this._local, {PetbeforeApi? api})
    : _api = api ?? PetbeforeApi.instance;

  final MemberLibraryStore _local;
  final PetbeforeApi _api;

  @override
  Future<MemberLibrary> load(String userId) async {
    if (_api.isConfigured && _api.accessToken != null) {
      try {
        final remote = await _api.loadLibrary();
        await _local.save(userId, remote);
        return remote;
      } catch (_) {}
    }
    return _local.load(userId);
  }

  @override
  Future<void> save(String userId, MemberLibrary library) async {
    await _local.save(userId, library);
    if (_api.isConfigured && _api.accessToken != null) {
      try {
        await _api.saveLibrary(library);
      } catch (_) {}
    }
  }
}

MemberLibraryStore defaultMemberLibraryStore() {
  return RemoteMemberLibraryStore(LocalMemberLibraryStore());
}
