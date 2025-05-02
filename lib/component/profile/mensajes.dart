import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Message {
  final String sender;
  final String text;
  final String time;
  final bool isMe;

  Message({
    required this.sender,
    required this.text,
    required this.time,
    this.isMe = false,
  });
}

class Conversation {
  final int id;
  final String name;
  final String lastMessage;
  final String time;
  final int unread;
  bool active;

  Conversation({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unread,
    this.active = false,
  });
}

class MensajesScreen extends StatefulWidget {
  @override
  _MensajesScreenState createState() => _MensajesScreenState();
}

class _MensajesScreenState extends State<MensajesScreen> {
  final List<Message> _messages = [
    Message(sender: 'María González', text: '¿Cuándo podría visitar la propiedad?', time: '08:23'),
    Message(sender: 'Tú', text: 'Claro, es un apartamento de 2 habitaciones en el centro', time: '08:53', isMe: true),
    Message(sender: 'María González', text: '¿Tiene estacionamiento?', time: '09:38'),
    Message(sender: 'Tú', text: 'Sí, incluye un espacio de estacionamiento', time: '09:43', isMe: true),
  ];

  final List<Conversation> _conversations = [
    Conversation(
      id: 1,
      name: 'María González',
      lastMessage: '¿Cuándo podría visitar la propiedad?',
      time: '08:23',
      unread: 1,
      active: true,
    ),
    Conversation(
      id: 2,
      name: 'Carlos Ramírez',
      lastMessage: 'Gracias por la información',
      time: 'Ayer',
      unread: 0,
    ),
    Conversation(
      id: 3,
      name: 'Laura Sánchez',
      lastMessage: '¿Hay un supermercado cerca?',
      time: 'Lun',
      unread: 2,
    ),
  ];

  final TextEditingController _controller = TextEditingController();

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      final now = DateFormat.Hm().format(DateTime.now());
      setState(() {
        _messages.add(
          Message(sender: 'Tú', text: text, time: now, isMe: true),
        );
      });
      _controller.clear();
    }
  }

  void _selectConversation(int id) {
    setState(() {
      for (var convo in _conversations) {
        convo.active = convo.id == id;
      }
    });
    // TODO: Load messages for selected conversation
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensajes'),
        backgroundColor: Colors.teal,
      ),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: screenWidth * 0.33,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
              color: Colors.white,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar conversaciones...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _conversations.length,
                    itemBuilder: (context, index) {
                      final convo = _conversations[index];
                      return InkWell(
                        onTap: () => _selectConversation(convo.id),
                        child: Container(
                          color: convo.active ? Colors.grey.shade100 : Colors.white,
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.grey.shade400,
                                    child: Text(
                                      convo.name[0],
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  if (convo.active)
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(convo.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                                        Text(convo.time, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                      ],
                                    ),
                                    const SizedBox(height: 4.0),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            convo.lastMessage,
                                            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (convo.unread > 0)
                                          Container(
                                            padding: const EdgeInsets.all(6.0),
                                            decoration: BoxDecoration(
                                              color: Colors.teal,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              '${convo.unread}',
                                              style: const TextStyle(color: Colors.white, fontSize: 12),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Chat area
          Expanded(
            child: Column(
              children: [
                // Chat header
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 2)],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey.shade400,
                            child: const Text('M', style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(width: 8.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('María González', style: TextStyle(fontWeight: FontWeight.w500)),
                              Text('En línea', style: TextStyle(fontSize: 12, color: Colors.green)),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.phone),
                            color: Colors.grey.shade600,
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(Icons.videocam),
                            color: Colors.grey.shade600,
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(Icons.info),
                            color: Colors.grey.shade600,
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Messages list
                Expanded(
                  child: Container(
                    color: Colors.grey.shade100,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        return Row(
                          mainAxisAlignment:
                              msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                          children: [
                            if (!msg.isMe)
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.grey.shade400,
                                child: const Text('M', style: TextStyle(color: Colors.white)),
                              ),
                            const SizedBox(width: 4.0),
                            Container(
                              constraints: BoxConstraints(maxWidth: screenWidth * 0.7),
                              padding: const EdgeInsets.all(12.0),
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              decoration: BoxDecoration(
                                color: msg.isMe ? Colors.teal : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(12.0),
                                  topRight: const Radius.circular(12.0),
                                  bottomLeft: Radius.circular(msg.isMe ? 12.0 : 0),
                                  bottomRight: Radius.circular(msg.isMe ? 0 : 12.0),
                                ),
                                boxShadow: msg.isMe
                                    ? null
                                    : [BoxShadow(color: Colors.grey.shade300, blurRadius: 2)],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    msg.text,
                                    style: TextStyle(
                                      color: msg.isMe ? Colors.white : Colors.grey.shade800,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        msg.time,
                                        style: TextStyle(
                                          color: msg.isMe ? Colors.teal.shade100 : Colors.grey.shade500,
                                          fontSize: 12,
                                        ),
                                      ),
                                      if (msg.isMe)
                                        const SizedBox(width: 4.0),
                                      if (msg.isMe)
                                        const Icon(
                                          Icons.done_all,
                                          size: 16,
                                          color: Colors.white70,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                // Input area
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey.shade300)),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.attach_file),
                        color: Colors.grey.shade600,
                        onPressed: () {},
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            TextField(
                              controller: _controller,
                              maxLines: null,
                              decoration: InputDecoration(
                                hintText: 'Escribe un mensaje...',
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                  horizontal: 16.0,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24.0),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                              onSubmitted: (_) => _handleSend(),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: IconButton(
                                icon: Icon(Icons.emoji_emotions),
                                color: Colors.grey.shade600,
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: _controller.text.trim().isEmpty
                            ? Colors.grey.shade300
                            : Colors.teal,
                        child: IconButton(
                          icon: Icon(Icons.send),
                          color: _controller.text.trim().isEmpty
                              ? Colors.grey.shade600
                              : Colors.white,
                          onPressed: _handleSend,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MensajesScreen(),
  ));
}
