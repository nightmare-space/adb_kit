void main() {
  List list = ['abc', 'def', 'JQK'];
  for (var item in list) {
    if (item == 'abc') {
      list.remove(item);
    }
  }
}
