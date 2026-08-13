class AiChatMessage {
  final String text;
  final bool isUser;
  final bool isError;

  const AiChatMessage({
    required this.text,
    required this.isUser,
    this.isError = false,
  });
}
