using System;

namespace BluethoothLE
{
    //Отримую інформацію про девайси
    public class InfoBluethoothLEDevice
    {
        #region Public Properties
       
        public DateTimeOffset BroadcastTime { get; }

        public ulong Address { get; }

        public string Name { get; }

        public short SignalStrength { get; }

        #endregion

        #region Constructor
        public InfoBluethoothLEDevice(ulong address, string name, short signalStrength, DateTimeOffset broadcastTime)
        {
            Address = address;
            Name = name;
            SignalStrength = signalStrength;
            BroadcastTime = broadcastTime;
        }
        #endregion

        public override string ToString()
        {
            return $"{(string.IsNullOrEmpty(Name) ? "[No name]" : Name)} {Address} ({SignalStrength})";
        }

    }
}
