using System;
using System.Collections.Generic;
using System.Linq;
using Windows.Devices.Bluetooth.Advertisement;
using Windows.Devices.Bluetooth;

namespace BluethoothLE
{
    public class MyBluetoothLEAdvertisementWatcher
    {

        #region Private Members

        private readonly BluetoothLEAdvertisementWatcher myWather;

        /// <summary>
        /// Список девайсів
        /// </summary>
        private readonly Dictionary<ulong, InfoBluethoothLEDevice> myDiscoveredDevices = 
            new Dictionary<ulong, InfoBluethoothLEDevice>();

        /// <summary>
        /// 
        /// </summary>
        private readonly object mThreadLock = new object();
        #endregion
        #region Public Properties
        /// <summary>
        /// Вказує чи триває пошук пристроїв
        /// </summary>
        public bool Listening => myWather.Status == BluetoothLEAdvertisementWatcherStatus.Started;

        /// <summary>
        /// Список відслідкованих девайсів
        /// </summary>
        public IReadOnlyCollection<InfoBluethoothLEDevice> DiscoveredDevices
        {
            get
            {
                CleanupTimeouts();

                lock (mThreadLock)
                {
                    return myDiscoveredDevices.Values.ToList().AsReadOnly();
                }

            }
        }


        /// <summary>
        /// перерва після того як девайс буде видалено з DiscoveredDevices
        /// </summary>
        public int HeartbeatTimeout { get; set; } = 5;

        #endregion
        #region Public Events

        /// <summary>
        /// Спрацює коли блютуз припинить пошук
        /// </summary>
        public event Action StoppedListening = () =>
        {
            
        };

        /// <summary>
        /// Спрацює коли блютуз почне пошук
        /// </summary>
        public event Action StartedListening = () =>
        {

        };

        /// <summary>
        /// перевіряє чи пристрій знайдено
        /// </summary>
        public event Action<InfoBluethoothLEDevice> DeviceDiscovered = (device) => {};

        /// <summary>
        /// перевіряє чи перевіряє чи знайдено новий пристрій
        /// </summary>
        public event Action<InfoBluethoothLEDevice> NewDeviceDiscovered = (device) => { };

        /// <summary>
        /// повідомить коли назва девайсу змінилася
        /// </summary>
        public event Action<InfoBluethoothLEDevice> DeviceNameChanged = (device) => { };

        /// <summary>
        /// повідомить коли девайc видалиться
        /// </summary>
        public event Action<InfoBluethoothLEDevice> DeviceTimeout = (device) => { };
        #endregion
        #region Constructor


        public MyBluetoothLEAdvertisementWatcher()
        {
            myWather = new BluetoothLEAdvertisementWatcher
            {
                ScanningMode = BluetoothLEScanningMode.Active
            };

        
            myWather.Received += WatcherAdvertisementReceived;

            ///Стежить коли watcher припинить пошук прийстроїв
            myWather.Stopped += (watcher, e) =>
            {
                StoppedListening();
            };

            myWather.Start();
        }
        #endregion
        #region Private Methods
        /// <summary>
        /// Прослуховувач пристроїв
        /// </summary>
        /// <param name="sender">Прослуховувач</param>
        /// <param name="args">Аргументи пристрою</param>
        private void WatcherAdvertisementReceived(BluetoothLEAdvertisementWatcher sender, BluetoothLEAdvertisementReceivedEventArgs args)
        {
            CleanupTimeouts();

            InfoBluethoothLEDevice device = null;

            ///Є нові пристрої?
            var newDiscovery = !myDiscoveredDevices.ContainsKey(args.BluetoothAddress);

            var nameChanged =
                //Якщо існує
                !newDiscovery &&
                //І нема пустого імені
                !string.IsNullOrEmpty(args.Advertisement.LocalName) &&
                //І імя відрізняється
                myDiscoveredDevices[args.BluetoothAddress].Name != args.Advertisement.LocalName;

            lock (mThreadLock)
            {
                var name = args.Advertisement.LocalName;

                //якщо нове імя порожнє, і ми його отримали
                if (string.IsNullOrEmpty(name) && !newDiscovery)
                    //Не міняти то, що може бути актуальним іменем
                    name = myDiscoveredDevices[args.BluetoothAddress].Name;


                device = new InfoBluethoothLEDevice
                (
                    address: args.BluetoothAddress,
                    name: name,
                    broadcastTime: args.Timestamp,
                    signalStrength: args.RawSignalStrengthInDBm

                );

                ///Додає/оновлює девайси в списку
                myDiscoveredDevices[args.BluetoothAddress] = device;
            }
            //Інформує про девайси
            DeviceDiscovered(device);

            if (nameChanged)
                DeviceNameChanged(device);

            //Інформує про нові пристрої..
            if (newDiscovery)
            {
                NewDeviceDiscovered(device);
            };


        }
        /// <summary>
        /// Видалити любих пристроїв з пройшовшим часом очікування 
        /// </summary>
        private void CleanupTimeouts()
        {
            lock(mThreadLock)
            {
                var threshold = DateTime.UtcNow - TimeSpan.FromSeconds(HeartbeatTimeout);

                //Любі пристрої які не відправили нову трансляцію...
                myDiscoveredDevices.Where(f => f.Value.BroadcastTime < threshold).ToList().ForEach(device =>
                {
                    //..видаляються
                    myDiscoveredDevices.Remove(device.Key);

                    //Проінформувати
                    DeviceTimeout(device.Value);

                });

            }
        }

        #endregion
        #region Public Methods
        /// <summary>
        /// Початок пошуку пристроїв
        /// </summary>
        public void StartListening()
        {
            lock (mThreadLock)
            {


                if (Listening)
                {
                    return;
                }

                myWather.Start();
            }
            StartedListening();
        }
        public void StopListening() 
        {
            lock (mThreadLock) 
            { 
                if (!Listening)
                {
                    return;
                }

                myWather.Stop();

  
                //Очистити девайси, щоб бути впевненим що список пристроїв чистий
                myDiscoveredDevices.Clear();
            }

        }

        #endregion
    }
}
