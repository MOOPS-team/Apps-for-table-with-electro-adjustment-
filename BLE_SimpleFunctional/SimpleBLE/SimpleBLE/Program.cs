using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Windows.Devices.Bluetooth;
using Windows.Devices.Bluetooth.Advertisement;
using Windows.Devices.Bluetooth.GenericAttributeProfile;
using Windows.Devices.Enumeration;
using Windows.Storage.Streams;

namespace SimpleBLE
{
    class Program
    {
        static DeviceInformation device = null;
        static async Task Main(string[] args)
        {
            string[] requestedProperties = { "System.Devices.Aep.DeviceAddress", "System.Devices.Aep.IsConnected" };

            DeviceWatcher deviceWatcher =
                        DeviceInformation.CreateWatcher(
                                BluetoothLEDevice.GetDeviceSelectorFromPairingState(false),
                                requestedProperties,
                                DeviceInformationKind.AssociationEndpoint);

            // Register event handlers before starting the watcher.
            // Added, Updated and Removed are required to get all nearby devices
            deviceWatcher.Added += DeviceWatcher_Added;
            deviceWatcher.Updated += DeviceWatcher_Updated;
            deviceWatcher.Removed += DeviceWatcher_Removed;

            // EnumerationCompleted and Stopped are optional to implement.
            deviceWatcher.EnumerationCompleted += DeviceWatcher_EnumerationCompleted;
            deviceWatcher.Stopped += DeviceWatcher_Stopped;

            // Start the watcher.
            deviceWatcher.Start();
            while (true)
            {
                if (device == null)
                {
                    Thread.Sleep(200);
                }
                else
                {
                    BluetoothLEDevice bluetoothLEDevice = await BluetoothLEDevice.FromIdAsync(device.Id);
                    Console.WriteLine($"  Pair with device {device.Name} - {device.Id}");
                    GattDeviceServicesResult servicesResult = await bluetoothLEDevice.GetGattServicesAsync();
                    if (servicesResult.Status == GattCommunicationStatus.Success)
                    {
                        Console.WriteLine("    Pairing succeed! Gatt services: ");
                        var services = servicesResult.Services;
                        foreach (var service in services)
                        {
                            Console.WriteLine($"      {service.Uuid}");

                            if (service.Uuid.ToString("N").Substring(4, 4) == "1800")
                            {
                                Console.WriteLine("Found service");
                                GattCharacteristicsResult characteristicsResult = await service.GetCharacteristicsAsync();

                                if (characteristicsResult.Status == GattCommunicationStatus.Success)
                                {
                                    var characteristics = characteristicsResult.Characteristics;
                                    foreach (var characteristic in characteristics)
                                    {
                                        Console.WriteLine("_____________");
                                        GattCharacteristicProperties properties = characteristic.CharacteristicProperties;
                                        if (properties.HasFlag(GattCharacteristicProperties.Read))
                                        {
                                            Console.WriteLine($"Properties for - {properties}");
                                        }

                                        if (properties.HasFlag(GattCharacteristicProperties.Write))
                                        {
                                            Console.WriteLine($"Properties for - {properties}");
                                        }

                                        if (properties.HasFlag(GattCharacteristicProperties.Notify))
                                        {
                                            Console.WriteLine($"Properties for - {properties}");
                                        }
                                    }
                                }
                            }

                        }
                    }
                    Console.WriteLine("Press any key to EXIT");
                    Console.ReadLine();
                }
            }
            deviceWatcher.Stop();

        }

        private static void Characteristic_ValueChanged(GattCharacteristic sender, GattValueChangedEventArgs args)
        {
            var reader = DataReader.FromBuffer(args.CharacteristicValue);
            var value = reader.ReadByte();
            Console.WriteLine($"           Value: {value}");
        }

        private static void DeviceWatcher_Stopped(DeviceWatcher sender, object args)
        {

        }

        private static void DeviceWatcher_EnumerationCompleted(DeviceWatcher sender, object args)
        {
            //throw new NotImplementedException();
        }

        private static void DeviceWatcher_Removed(DeviceWatcher sender, DeviceInformationUpdate args)
        {
            //throw new NotImplementedException();
        }

        private static void DeviceWatcher_Updated(DeviceWatcher sender, DeviceInformationUpdate args)
        {
            //throw new NotImplementedException();
        }

        private static void DeviceWatcher_Added(DeviceWatcher sender, DeviceInformation args)
        {
            Console.WriteLine($"{(string.IsNullOrEmpty(args.Name) ? "[No Name]" : args.Name)} [{args.Id}]");
            if (args.Name == "MIBOX4")
            {
                Console.WriteLine("MIBOX4 is here..");
                device = args;
            }
        }
    }
}