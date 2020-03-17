using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace RealChatServer.Providers
{
    public class ChatProvider : IChatProvider
    {
        string _message;

        public String GetMessage()
        {
            return _message;
        }

        public void SetMessage(string message)
        {
            _message = message;
        }

    }
}
