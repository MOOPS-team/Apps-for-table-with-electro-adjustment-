using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Table
{   
    [Serializable]
    class DayInfo
    {
        private string date;
        private int minutesScreenOn;

        public DayInfo() { }
        public DayInfo(string date, int minutesScreenOn)
        {
            this.date = date;
            this.minutesScreenOn = minutesScreenOn;
        }

        public int MinutesScreenOn
        {
            get
            {
                return minutesScreenOn;
            }
            set
            {
                minutesScreenOn = value;
            }
        }

        public string Date
        {
            get
            {
                return date;
            }
            set
            {
                date = value;
            }
        }

        public string ToHoursString()
        {
            return minutesScreenOn / 60 + "h " + minutesScreenOn % 60 + "m";
        }

        public string ToFullInfoString()
        {
            return date + "    ---    Screen On:  "
                        + minutesScreenOn / 60 + "h " + minutesScreenOn % 60 + "m";
        }
    }
}
