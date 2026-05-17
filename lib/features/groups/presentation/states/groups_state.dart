/// Marker for a completed group mutation (create / join).
/// The actual list is driven by Hive + [groupsListProvider].
final class GroupMutationSuccess {
  const GroupMutationSuccess(this.message);
  final String message;
}
