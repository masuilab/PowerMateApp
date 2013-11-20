# 写真データから階層構造を作る

- yamlで出力する

## 必要な物をインストールする

    % brew install exiftool

    % gem install bundler
    % bundle install


## 使い方

出力はyamlです

    % bundle exec ruby make_hierarcy_photo.rb /path/to/photodir

ファイルに書き出す

    % bundle exec ruby make_hierarcy_photo.rb /path/to/photodir > photos.yml


