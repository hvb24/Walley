import 'dart:async';

import 'package:chat_gpt/threedots.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import 'chatmessage.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {


final List<ChatMessage> _messages=[];
final TextEditingController _controller = TextEditingController();


ChatGPT? chatGPT;
StreamSubscription? _subscription;

bool _isTyping =false;


@override
  void initState() {

    super.initState();
    chatGPT =ChatGPT.instance;
  }
@override
  void dispose() {
   _subscription?.cancel();
    super.dispose();
  }


 void _sendMessage(){
   ChatMessage message = ChatMessage(text: _controller.text, sender: "user");
   
   setState(() {
     _messages.insert(0, message);
     _isTyping=true;
   });
   _controller.clear();
   final request = CompleteReq(prompt: message.text, model: kTranslateModelV3, max_tokens: 200);

   _subscription =chatGPT!.builder("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", orgId: " ")
   .onCompleteStream(request: request).listen((response) {
     Vx.log(response!.choices[0].text);
   ChatMessage botMessage = ChatMessage(text: response!.choices[0].text, sender: "Walley");

       setState(() {
           _isTyping=false;
         _messages.insert(0, botMessage);
       });
   });

 }


  //TEXT CONTROLLERS
  Widget _buildTextComposer(){

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            onSubmitted: (value) => _sendMessage(),
            decoration: const InputDecoration.collapsed(
                hintText: "Question/description"),
          ),
        ),
        ButtonBar(
          children: [
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () =>_sendMessage()
                // _isImageSearch = false;
                // _sendMessage();

            ),
            // TextButton(
            //     onPressed: () {
            //       // _isImageSearch = true;
            //       // _sendMessage();
            //     },
            //     child: const Text("Generate Image"))
          ],
        ),
      ],
    ).px(16);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ChatGPT Walley"),),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(child: ListView.builder(
              reverse: true,
                padding: Vx.m8,

                itemCount: _messages.length,
                itemBuilder: (context,index){
            return  _messages[index];
            })),
             Divider(
               height: 1.0,
             ),/**/
             if(_isTyping) ThreeDots(),

            Container(
              decoration: BoxDecoration(
                color: context.cardColor,
              ),
              child: _buildTextComposer(),
            )
          ],
        ),
      ),
    );
  }
}
