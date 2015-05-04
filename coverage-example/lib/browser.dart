import 'dart:html';


Element container;


void setUp() {
  container = document.createElement('div');
  container.id = 'container';
  document.body.append(container);
}

void sayHello(String name) {
  if (name == "") {
    container.text = 'invalid name: $name';
  } else {
    container.text = 'hello $name';
  }
}

void sayGoodbye(String name) {
  if (name == "") {
    container.text = '';
  } else {
    container.text = 'goodbye $name';
  }
}