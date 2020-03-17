using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Grpc.Core;
using Microsoft.Extensions.Logging;
using Google.Protobuf.WellKnownTypes;
using Chat;
using RealChatServer.Providers;

namespace RealChatServer.Services
{
    public class ChatService : Chat.ChatService.ChatServiceBase
    {
        private readonly ILogger _logger;
        private readonly IChatProvider _chatProvider;

        public ChatService(IChatProvider chatProvider)
        {
            _chatProvider = chatProvider;
        }

        public override Task<Empty> send(StringValue request, ServerCallContext context)
        {
            _chatProvider.SetMessage(request.Value);
            return Task.FromResult(new Empty());
        }

        public override async Task Subscribe(Empty request, IServerStreamWriter<Message> responseStream, ServerCallContext context)
        {
            while(true)
            {
                if (_chatProvider.GetMessage() != string.Empty && _chatProvider.GetMessage() != null)
                {
                    await responseStream.WriteAsync(new Message { Text = $"Send Message : {_chatProvider.GetMessage()}" });
                    _chatProvider.SetMessage(string.Empty);
                }
            }

        }
    }
}
