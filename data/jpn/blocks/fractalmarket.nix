{ lib, ... }:
with lib;
{
  id = "fractalmarket";
  title = "フラクタルマーケット";
  subtitle = "暗号コントラクトアプリマーケットプレース";
  content = markdownToHtml ''
     ハイパーフローのコンポーネントとアプリケーションは、人と共有する必要があります。これはFractalmarket経由で行われます。

    フラクタルマーケットの特徴。

    * ユーザーはFRACTALのコンポーネントとアプリケーションを購入して販売することができます。
    * ユーザーはコンポーネントとアプリケーションを検索してダウンロードできます。
    * 再利用可能なコンポーネントを作成者に報酬で応えます。
  '';
}
