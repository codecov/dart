String sayHello(String name) {
  if (name == "") {
    return 'invalid name: $name';
  } else {
    var msg = 'hello $name';
    return msg;
  }
}

String sayGoodbye(String name) {
  if (name == "") {
    return '';
  } else {
    var msg = 'goodbye $name';
    return msg;
  }
}