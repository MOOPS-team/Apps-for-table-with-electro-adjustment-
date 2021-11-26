using BluethoothLE;
using System;



namespace MyConsoleAppp
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Bluethooth scaner: ");
            var watcher = new MyBluetoothLEAdvertisementWatcher();

            watcher.StartedListening += () =>
            {
                Console.ForegroundColor = ConsoleColor.DarkYellow;
                Console.WriteLine("Started listening: ");
            };

            watcher.StoppedListening += () =>
            {
                Console.ForegroundColor = ConsoleColor.Gray;
                Console.WriteLine("Stopped listening.");
            };

            watcher.NewDeviceDiscovered += (device) =>
            {
                Console.ForegroundColor = ConsoleColor.Green;
                Console.WriteLine($"New device: {device}");
            };

            watcher.DeviceNameChanged += (device) =>
            {
                Console.ForegroundColor = ConsoleColor.Yellow;
                Console.WriteLine($"Device name changed: {device}");
            };

              watcher.DeviceTimeout += (device) =>
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine($"Device timeout: {device}");
            };



            //Пошук пристроїв
            watcher.StartListening();

            while (true)
            {
                Console.ReadLine();

                var devices = watcher.DiscoveredDevices;
                Console.ForegroundColor = ConsoleColor.White;
                Console.WriteLine($"{devices.Count} devices...");

                foreach (var device in devices)
                    Console.WriteLine(device);
            }
        }
    }
}
