abstract interface class RitualPermissionService {
  Future<bool> hasSchedulingPermission();
  Future<bool> requestSchedulingPermission();
}

class NoopRitualPermissionService implements RitualPermissionService {
  const NoopRitualPermissionService();

  @override
  Future<bool> hasSchedulingPermission() async {
    // TODO(rituals): report platform permission state for scheduled rituals.
    return false;
  }

  @override
  Future<bool> requestSchedulingPermission() async {
    // TODO(rituals): trigger OS permission request when UX is approved.
    return false;
  }
}
