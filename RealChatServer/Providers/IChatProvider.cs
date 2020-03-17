using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace RealChatServer.Providers
{
    public interface IChatProvider
    {
        string GetMessage();
        void SetMessage(string message);
    }
}
