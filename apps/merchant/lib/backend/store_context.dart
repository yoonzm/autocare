/// Local identity of the server-selected store. Epochs discard requests made
/// before a switch, even if their HTTP responses arrive after the new page.
class StoreContext {
  static String? id;
  static int epoch = 0;
  static void bind(String? next) {
    if (id == next) return;
    id = next;
    epoch++;
  }
}
