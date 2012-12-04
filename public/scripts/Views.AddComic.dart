library views_add_comic;

import 'HipsterView.dart';
import 'Views.AddComicForm.dart';

class AddComic extends HipsterView {
  var form_view;

  AddComic({collection, model, el}):
    super(collection:collection, model:model, el:el);

  void post_initialize() {
    print("sub initialize");
    el.on.click.add(_toggle_form);
  }

  _toggle_form(event) {
    if (form_view == null) {
      form_view = new AddComicForm(collection: collection);
      form_view.render();
    }
    else {
      form_view.remove();
      form_view = null;
    }
  }
}
