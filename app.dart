import 'dart:io';
import 'dart:json';

import 'package:dart_dirty/dirty.dart';

main() {
  Dirty db = new Dirty('dart_comics.db');

  HttpServer app = new HttpServer();

  app.addRequestHandler(
    (req) {
      if (req.method != 'GET') return false;

      String path = publicPath(req.path);
      if (path == null) return false;

      req.session().data = {'path': path};
      return true;
    },
    (req, res) {
      var file = new File(req.session().data['path']);
      var stream = file.openInputStream();
      stream.pipe(res.outputStream);
    }
  );

  app.addRequestHandler(
    (req) => req.method == 'GET' && req.path == '/comics',
    (req, res) {
      res.headers.contentType = 'application/json';
      res.outputStream.writeString(JSON.stringify(db.values));
      res.outputStream.close();
    }
  );

  app.addRequestHandler(
    (req) => req.method == 'POST' && req.path == '/comics',
    (req, res) {
      var input = new StringInputStream(req.inputStream);
      var post_data = '';

      input.onLine = () {
        var line = input.readLine();
        post_data = post_data.concat(line);
      };

      input.onClosed = () {
        var graphic_novel = JSON.parse(post_data);
        graphic_novel['id'] = db.length + 1;

        db[graphic_novel['id']] = graphic_novel;

        res.statusCode = 201;
        res.headers.contentType = 'application/json';

        res.outputStream.writeString(JSON.stringify(graphic_novel));
        res.outputStream.close();
      };

    }
  );


  app.listen('127.0.0.1', 8000);
}

String publicPath(String path) {
  if (pathExists("public$path")) return "public$path";
  if (pathExists("public$path/index.html")) return "public$path/index.html";
}

boolean pathExists(String path) => new File(path).existsSync();