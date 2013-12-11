library change_detection;

/**
 * Factory method for creating dirty checkers. This method would return a polyfill or
 * native VM implemention depending on the browser.
 *
 */
ChangeDetector createChangeDetector() => null;

/**
 * An interface for ChangeDetector. An application can have multiple instance of the
 * [ChangeDetector] to be used for checking different application domains.
 *
 * ChangeDetector works by comparing the identity of the objects not by calling the [.equals()]
 * method. This is becouse ChangeDetector needs to have predictable performance, and the
 * developer can implement [.equals()] on top of identity checks.
 *
 * - [ID] Each watch needs to have an ID which is used to order the resulting [ChangeRecord]s.
 *   The [ID] is also used as [Comparable] which keeps the watches sorted. While the order of
 *   dirty checking does not matter, the order in which the [ChangeRecord]s are presented does.
 *   The [ID] servers the purpose of ordering.
 *
 * - [H] A watch has associated handler object. The handler object is opeque to the [ChangeDetector]
 *   but it is meaningfull to the cod which registered the watcher. It can be data structure,
 *   object, or function. It is upto the developer to attach meaning to it.
 */
abstract class ChangeDetector<ID extends Comparable, H> {
  /**
   * Watch a specific [field] on an [object].
   *
   * - [object] to watch.
   * - [field] to watch.
   * - [id] comparable id to be used when sorting the [ChangeRecord]s (see [collectChanges] method.)
   * - [handler] an opaque object passed on to [ChangeRecord].
   *
   * Returns a [UnWatch] closure useful for stoping the watching process.
   */
  UnWatch watch(Object object, Symbol field, ID id, H handler);

  /**
   * Watch [List] for changes.
   *
   * - [list] to watch.
   * - [id] comparable id to be used when sorting the [ChangeRecord]s (see [collectChanges] method.)
   * - [handler] an opaque object passed on to [ChangeRecord].
   *
   * Returns a [UnWatch] closure useful for stoping the watching process.
   */
  UnWatch watchList(List list, ID id, H handler);

  /**
   * Watch a [Map] for changes.
   *
   * - [map] to watch.
   * - [id] comparable id to be used when sorting the [ChangeRecord]s (see [collectChanges] method.)
   * - [handler] an opaque object passed on to [ChangeRecord].
   *
   * Returns a [UnWatch] closure useful for stoping the watching process.
   */
  UnWatch watchMap(Map map, ID id, H handler);

  /**
   * This method does the work of collecting the changes and returns them as a List of
   * [ChangeRecord]s. The [ChangeRecord]s are to be sorted by the [ID].
   */
  ChangeRecords<ID, H> collectChanges();


  /**
   * Use to  remove large blocks of watches efficiently.
   *
   * - [inclusiveFrom] An [ID] from which the removal will start (inclusive).
   * - [exclusiveTo] An [ID] where the removal will stop (exclusize).
   */
  void unWatch(ID inclusiveFrom, ID exclusiveTo);
}

class ChangeRecords<ID extends Comparable, H> {
  final ObjectChangeRecord<ID, H> objectHead;
  final ListChangeRecord<ID, H> listHead;
  final MapChangeRecord<ID, H> mapHead;

  ChangeRecords(this.objectHead, this.listHead, this.mapHead);
}

/**
 * Calling this function will remove the watch from the [ChangeDetector].
 */
typedef UnWatch();

/**
 * A change record provides information about the changes which were detected in objects.
 */
abstract class ChangeRecord<ID extends Comparable, H> {
  /**
   * The object where the change occured.
   */
  Object get object;

  /**
   * The id of the watch.
   */
  ID get id;

  /**
   *  The handler is an application provided object which contains the specific logic
   *  which needs to be applied when the change is detected. The handler is opeque to the
   *  ChangeDector and as such can be anything the application desires.
   */
  H get handler;
}

/**
 * Represents a change in the object field.
 */
abstract class ObjectChangeRecord<ID extends Comparable, H> extends ChangeRecord<ID, H> {
  Symbol get field;
  dynamic get previousValue;
}


/**
 * Represents a change in the List.
 */
abstract class ListChangeRecord<ID extends Comparable, H> extends ChangeRecord<ID, H> {
  /**
   * A list of additions to the list.
   */
  List<ListChangeItem> get additions;
  List<ListChangeItem> get removals;
  List<ListChangeItem> get exiting;
}

/**
 * Represents a change in the Map.
 */
abstract class MapChangeRecord<ID extends Comparable, H> extends ChangeRecord<ID, H> {
  List<MapChangeItem> get additions;
  List<MapChangeItem> get removals;
}

abstract class ListChangeItem {
  /**
   * Previous item location in the list or [null] if addition.
   */
  int get previousIndex;
  /**
   * Current item location in the list or [null] if removal.
   */
  int get currentIndex;
  /**
   * The item.
   */
  dynamic get item;
}

abstract class MapChangeItem {
  dynamic get key;
  dynamic get value;
}