CSD
===========

##What is it?

CSDとはCollate Server's Dataの略で複数サーバーのデータを一つのサーバーに集約するrailsアプリケーションです。  

動作確認はruby 2.0.0p481,Rails 4.2.2とruby 1.9.3p484,Rails 4.2.2でApache2+Passengerです。

##How to Use
Apache2, Passenger, virtual-hostの設定は省きます。  
ruby 2.0.0+Rails 4.2.2の場合はディレクトリごとコピーすれば使えると思います。  
ruby 1.9.3の場合対応してないgemが入っているため以下のコマンドを実行してください。  

```
rails new server  
rails g controller servers update show statues stream  
```

実行した後以下のファイルを置き換えてください。  

```
app/controllers/application_controller.rb  
app/controllers/servers_controller.rb  
app/views/servers/statues.html.erb  
app/views/servers/update.html.erb  
config/routes.rb  
```

1.9.3の場合自分の環境だけかもしれませんが、streamメソッドが使用できませんでした。  

##Supported APIs

###servers/update :POST
POSTメソッドで以下のパラメータを付与することでデータを集約できます。  
一つでもパラメータが欠けてるとエラーレスポンスを返却するので不要なパラメータにはダミーデータを入力してください。  


####パラメータ一覧

>NAME  

>>サーバー名

>CPU  

>>CPU使用率

>MEM_USED

>>USEDなメモリ
  
>MEM_FREE  

>>FREEなメモリ

>MEM_SWAP  

>>SWAPしているメモリ

>Operating_time  

>>稼働時間 

>Process_number  

>>プロセス数

>Zombie_process  

>>ゾンビプロセス数

>High_CPU_Process  

>>CPU使用率の高いプロセス(上位５位)

>High_MEM_Process 

>>メモリ使用率の高いプロセス(上位5位)
 
>TEMP  

>>温度

###servers/show

ここはapp/views/servers/show.html.erbを編集して自分の好きなレイアウトでサーバーの状況を表示するページを作ってください。  
servers/statuesだけ使う場合は必要ありません。  

###servers/statues :GET
集約したデータをjson形式で参照することができます。  
パラメータを指定することでデータを抽出できます。
デフォルトのqueryは  

```
SELECT * FROM servers ORDER BY Update_time DESC LIMIT 100
```

####パラメータ一覧

>NAME

>>指定したサーバー名で抽出

>count

>>この個数分データを抽出

>period

>>ある期間のデータを抽出する  

>>>例  

>>>ある日付より前のデータを抽出する場合  

>>>>~2015-08-25 10:14:36  

>>>ある日付より後のデータを抽出する場合

>>>>2015-08-25 10:14:36~

>>>ある期間のデータを抽出する場合

>>>>2015-08-25 09:35:50~2015-08-25 10:14:36  


>order :ASC|:DESC

>>日付を昇順で抽出するか降順で抽出するか

###servers/stream
これから送信されるデータをストリームで流す。  
環境のせいかもしれませんが、ruby1.9.3では動作しませんでした。

##Utilities
[CSDにデータを送信するやつ](http://github.com/flum1025/update_csd)  
[CSDのストリームに接続するやつ](http://github.com/flum1025/csd_stream)


質問等ありましたらTwitter:[@flum_](https://twitter.com/flum_)までお願いします。

##License

The MIT License

-------
(c) @2015 flum_