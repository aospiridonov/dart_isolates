import 'dart:async';
import 'dart:isolate';

void main() async {
  var recivePort = ReceivePort();
  await Isolate.spawn(echo, recivePort.sendPort);

  // Изолятор 'echo' отправляет его SendPort в качестве первого сообщения
  var sendPort = await recivePort.first;

  var msg = await sendRecive(sendPort, 'foo');
  print('received $msg');
  msg = await sendRecive(sendPort, 'bar');
  print('received $msg');
}

// точка входа для изолята
void echo(SendPort sendPort) async {
  // Открываем ReceivePort для входящих сообщений.
  var port = ReceivePort();

  // Сообщаем другим изоляторам, какой порт слушает этот изолятор.
  sendPort.send(port.sendPort);

  await for (var msg in port) {
    var data = msg[0];
    SendPort replyTo = msg[1];
    replyTo.send(data);
    if (data == 'bar') port.close();
  }
}

/// отправляет сообщение на порт, получает ответ,
/// и возвращает сообщение
Future sendRecive(SendPort port, String msg) {
  var responce = ReceivePort();
  port.send([msg, responce.sendPort]);
  return responce.first;
}
