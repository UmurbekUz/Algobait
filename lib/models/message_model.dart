enum Sender { user, ai }

class Message {
  final Sender sender;
  final String text;

  Message({required this.sender, required this.text});
}
