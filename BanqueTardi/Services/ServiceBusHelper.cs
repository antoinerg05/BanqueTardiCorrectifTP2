using Azure.Messaging.ServiceBus;
using System.Threading.Tasks;

public class ServiceBusHelper
{
    private readonly string _connectionString;
    private readonly string _queueName;

    public ServiceBusHelper(string connectionString, string queueName)
    {
        _connectionString = connectionString;
        _queueName = queueName;
    }

    public async Task SendMessageAsync(string message)
    {
        await using var client = new ServiceBusClient(_connectionString);
        ServiceBusSender sender = client.CreateSender(_queueName);

        try
        {
            ServiceBusMessage busMessage = new ServiceBusMessage(message);
            await sender.SendMessageAsync(busMessage);
        }
        finally
        {
            await sender.DisposeAsync();
        }
    }

    public async Task<string> ReceiveMessageAsync()
    {
        await using var client = new ServiceBusClient(_connectionString);
        ServiceBusReceiver receiver = client.CreateReceiver(_queueName);

        try
        {
            ServiceBusReceivedMessage message = await receiver.ReceiveMessageAsync();
            if (message != null)
            {
                string body = message.Body.ToString();
                await receiver.CompleteMessageAsync(message);
                return body;
            }
        }
        finally
        {
            await receiver.DisposeAsync();
        }

        return null;
    }
}
