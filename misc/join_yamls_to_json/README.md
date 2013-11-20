複数のyamlからPowerMateApp.appで使うjsonにまとめる
==================================================


## 必要なものをインストール

    % gem install bundler
    % bundle install


## まとめる

標準出力する

    % bundle exec ruby join_yamls_to_json.rb /path/to/photos.yml /path/to/recipe.yml /path/to/news.yml


jsonに出力する

    % bundle exec ruby join_yamls_to_json.rb /path/to/photos.yml /path/to/recipe.yml /path/to/news.yml > hierarchy.json