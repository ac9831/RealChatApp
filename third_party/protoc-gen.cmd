@echo Compling proto file

@protoc empty.proto timestamp.proto wrappers.proto --proto_path=C:\GithubRepo\RealChatApp\third_party\google\protobuf --plugin=protoc-ge-dart=C:\protoc\bin\protoc.bat --dart_out=grpc:C:\GithubRepo\RealChatApp\flutter_chat_grpc\lib\api\v1\google\protobuf

@protoc chat.proto --proto_path=C:\GithubRepo\RealChatApp\third_party\google\protobuf\service --plugin=protoc-ge-dart=C:\protoc\bin\protoc.bat --dart_out=grpc:C:\GithubRepo\RealChatApp\flutter_chat_grpc\lib\api\v1

@echo Done