import 'package:dash_chat_2/dash_chat_2.dart';

String profileImage =
    'https://cdn.fastly.picmonkey.com/contentful/h6goo9gw1hh6/2sNZtFAWOdP1lmQ33VwRN3/24e953b920a9cd0ff2e1d587742a2472/1-intro-photo-final.jpg?w=800&q=70';

// We have all the possibilities for users
ChatUser user = ChatUser(id: '0');
ChatUser user1 = ChatUser(id: '1');
ChatUser user2 = ChatUser(id: '2', firstName: 'Toto Clark');
ChatUser user3 = ChatUser(id: '3', lastName: 'Clark');
ChatUser user4 = ChatUser(id: '4', profileImage: profileImage);
ChatUser user5 = ChatUser(id: '5', firstName: 'Charles', lastName: 'Leclerc');
ChatUser user6 =
    ChatUser(id: '6', firstName: 'Max', profileImage: profileImage);
ChatUser user7 =
    ChatUser(id: '7', lastName: 'Toto', profileImage: profileImage);
ChatUser user8 = ChatUser(
    id: '8', firstName: 'Toto', lastName: 'Clark', profileImage: profileImage);

List<ChatMessage> allUsersSample = <ChatMessage>[
  ChatMessage(
    text: 'Test',
    user: user1,
    createdAt: DateTime(2021, 01, 30, 16, 45),
  ),
  ChatMessage(
    text: 'Test',
    user: user2,
    createdAt: DateTime(2021, 01, 30, 16, 45),
  ),
  ChatMessage(
    text: 'Test',
    user: user3,
    createdAt: DateTime(2021, 01, 30, 16, 45),
  ),
  ChatMessage(
    text: 'Test',
    user: user4,
    createdAt: DateTime(2021, 01, 30, 16, 45),
  ),
  ChatMessage(
    text: 'Test',
    user: user5,
    createdAt: DateTime(2021, 01, 30, 16, 45),
  ),
  ChatMessage(
    text: 'Test',
    user: user6,
    createdAt: DateTime(2021, 01, 30, 16, 45),
  ),
  ChatMessage(
    text: 'Test',
    user: user7,
    createdAt: DateTime(2021, 01, 30, 16, 45),
  ),
  ChatMessage(
    text: 'Test',
    user: user8,
    createdAt: DateTime(2021, 01, 30, 16, 45),
  ),
];

List<ChatMessage> basicSample = <ChatMessage>[
  ChatMessage(
    id: '12',
    text: '',
    medias: [
      ChatMedia(
        url: 'http://staging.medexpert.chat/media/chats/3/audio/3f1b1a89aece4cd091f1e7c8590f037c.mp4',
        type: MediaType.audio,
        fileName: 'image.png',
      ),
    ],
    user: user2,
    createdAt: DateTime(2021, 01, 30, 16, 45),
    status: MessageStatus.read,
  ),
  // ChatMessage(
  //   id: '11',
  //   text: 'google.com',
  //   user: user2,
  //   createdAt: DateTime(2021, 01, 30, 16, 45),
  //   status: MessageStatus.read,
  // ),
  // ChatMessage(
  //   id: '10',
  //   text: "Oh what's up guys?",
  //   user: user2,
  //   createdAt: DateTime(2021, 01, 30, 16, 45),
  //   status: MessageStatus.received,
  // ),
  // ChatMessage(
  //   id: '9',
  //   text: 'How you doin?',
  //   user: user8,
  //   createdAt: DateTime(2021, 01, 30, 16, 34),
  //   status: MessageStatus.read,
  // ),
  // ChatMessage(
  //   id: '8',
  //   text: '',
  //   medias: [
  //     ChatMedia(
  //       url: 'http://staging.medexpert.chat/media/chats/3/audio/25730f325d5e4da0b717228d70d089de.mp4',
  //       type: MediaType.audio,
  //       fileName: 'image.png',
  //     ),
  //   ],
  //   user: user2,
  //   createdAt: DateTime(2021, 01, 30, 16, 45),
  //   status: MessageStatus.read,
  // ),
  // ChatMessage(
  //   id: '7',
  //   text: 'google.com',
  //   user: user2,
  //   createdAt: DateTime(2021, 01, 30, 16, 45),
  //   status: MessageStatus.read,
  // ),
  // ChatMessage(
  //   id: '6',
  //   text: "Oh what's up guys?",
  //   user: user2,
  //   createdAt: DateTime(2021, 01, 30, 16, 45),
  //   status: MessageStatus.received,
  // ),
  // ChatMessage(
  //   id: '5',
  //   text: 'How you doin?',
  //   user: user8,
  //   createdAt: DateTime(2021, 01, 30, 16, 34),
  //   status: MessageStatus.read,
  // ),
  // ChatMessage(
  //   id: '1',
  //   text: '',
  //   medias: [
  //     ChatMedia(
  //       url: 'http://staging.medexpert.chat/media/chats/3/audio/e2146539b6274a938fb85c56a59290b5.mp4',
  //       type: MediaType.audio,
  //       fileName: 'image.png',
  //     ),
  //   ],
  //   user: user2,
  //   createdAt: DateTime(2021, 01, 30, 16, 45),
  //   status: MessageStatus.read,
  // ),
  // ChatMessage(
  //   id: '2',
  //   text: 'google.com',
  //   user: user2,
  //   createdAt: DateTime(2021, 01, 30, 16, 45),
  //   status: MessageStatus.read,
  // ),
  // ChatMessage(
  //   id: '3',
  //   text: "Oh what's up guys?",
  //   user: user2,
  //   createdAt: DateTime(2021, 01, 30, 16, 45),
  //   status: MessageStatus.received,
  // ),
  // ChatMessage(
  //   id: '4',
  //   text: 'How you doin?',
  //   user: user8,
  //   createdAt: DateTime(2021, 01, 30, 16, 34),
  //   status: MessageStatus.read,
  // ),
];

List<ChatMessage> headerMessage = <ChatMessage>[
  ChatMessage(
    text:
        'We recommend that you refrain from remote examination of the Client during the consultation on the Platform, establish diagnoses and prescribe treatment without physical examination or telemedicine services and tools.',
    user: user3,
    createdAt: DateTime(2021, 01, 30, 16, 34),
    messageType: ChatMessageType.info,
  ),
  ChatMessage(
    text:
        'As part of a paid request, the client can send you only one text message and attach up to two files. You can reply with an unlimited number of messages, attach images and files.',
    user: user3,
    createdAt: DateTime(2021, 01, 30, 16, 34),
    messageType: ChatMessageType.system,
  ),
];

List<ChatMessage> media = <ChatMessage>[
  ChatMessage(
    status: MessageStatus.read,
    medias: <ChatMedia>[
      ChatMedia(
        url: 'https://hsto.org/webt/5d/ad/ef/5dadef7d0eeaf290713181.jpeg',
        type: MediaType.image,
        fileName: 'image.png',
      ),
    ],
    user: user3,
    createdAt: DateTime(2021, 01, 30, 16, 34),
  ),
];

List<ChatMessage> quickReplies = <ChatMessage>[
  ChatMessage(
    text: 'How you doin?',
    user: user3,
    createdAt: DateTime.now(),
    quickReplies: <QuickReply>[
      QuickReply(title: 'Great!'),
      QuickReply(title: 'Awesome'),
    ],
  ),
];

List<ChatMessage> d = <ChatMessage>[];
