using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Windows.Threading;
using System.Windows.Forms;
using System.Drawing;
using Microsoft.Win32;
using Table.Properties;
using System.Web.Script.Serialization;
using System.IO;

namespace Table
{
    public partial class MainWindow : Window
    {
        private DispatcherTimer notificationAboutUpTimer;
        private DispatcherTimer notificationAboutDownTimer;
        private DispatcherTimer screenTimer;
        private Notification notification;
        private System.Windows.Forms.NotifyIcon ni;
        //private DateTime startTime;
        private Position currentPosition;
        private DateTime lockTime;
        private DateTime unLockTime;
        private DateTime lastTimeOfNotification;
        private DayInfo today;
        private List<DayInfo> allDays;
        public MainWindow()
        {
            InitializeComponent();
            currentPosition = Position.DOWN;
            setUpTimers();
            SetUpIcon();
            placeProgram();
            SystemEvents.SessionSwitch +=
                new SessionSwitchEventHandler(SystemEvents_SessionSwitch);
            //SystemEvents.PowerModeChanged += OnSleepMode;
            loadDaysInfo();
            ScreenOn.Content = today.ToHoursString();
            Date.Content = "Today: " + DateTime.Now.Date.ToShortDateString();
            displaySettings();
        }

        public void addActionDone(string action)
        {
            Times.Items.Add(action + "  ---  " + DateTime.Now.ToLongTimeString());
        }

        public void addTime()
        {
            Times.Items.Add(DateTime.Now.ToLongTimeString());
        }

        public void setNotificationNotOpened()
        {
            notification = null;
        }

        private void displaySettings()
        {
            TimeUp.Content = "Time in upper position: " + Properties.Settings.Default.timeUp;
            TimeDown.Content = "Time in lower position: " + Properties.Settings.Default.timeDown;
        }

        private void saveSettings()
        {
            Properties.Settings.Default.Save();
        }

        private void handleDaySwitch(bool isSwitchedInSleepMode)
        {
            allDays.Add(today);
            PreviousDays.Items.Add(today.ToFullInfoString());
            Date.Content = "Today: " + DateTime.Now.Date.ToShortDateString();

            if (isSwitchedInSleepMode)
            {
                today = new DayInfo(DateTime.Now.Date.ToShortDateString(), 0);
                ScreenOn.Content = "0h 0m";
            }
            else
            {
                today = new DayInfo(DateTime.Now.Date.ToShortDateString(), -1);
            }

        }

        private void saveDaysInfo()
        {
            File.WriteAllText("daysInfo.dat", new JavaScriptSerializer().Serialize(allDays));
        }

        private void loadDaysInfo()
        {
            if (File.Exists("daysInfo.dat"))
            {
                allDays = new JavaScriptSerializer().Deserialize<List<DayInfo>>(File.ReadAllText("daysInfo.dat"));
                if (allDays[allDays.Count - 1].Date == DateTime.Now.Date.ToShortDateString())
                {
                    today = allDays[allDays.Count - 1];
                    allDays.RemoveAt(allDays.Count - 1);

                } else
                {
                    today = new DayInfo(DateTime.Now.Date.ToShortDateString(), 0);
                }

                foreach (DayInfo day in allDays)
                {
                    PreviousDays.Items.Add(day.ToFullInfoString());
                }
            }
            else
            {
                today = new DayInfo(DateTime.Now.Date.ToShortDateString(), 0);
                allDays = new List<DayInfo>();
            }
        }

        private void placeProgram()
        {
            var desktopWorkingArea = System.Windows.Forms.Screen.PrimaryScreen.WorkingArea;
            this.Left = desktopWorkingArea.Right - this.Width;
            this.Top = desktopWorkingArea.Bottom - this.Height;
        }

        private void sendNotification(string command)
        {
            this.notification = new Notification(this, command);
            notification.Show();
        }

        void setUpTimers()
        {
            notificationAboutDownTimer = new DispatcherTimer();
            notificationAboutDownTimer.Tick += notificationAboutDownTimerTick;

            notificationAboutUpTimer = new DispatcherTimer();
            notificationAboutUpTimer.Interval = new TimeSpan(0, Properties.Settings.Default.timeDown, 0);
            notificationAboutUpTimer.Tick += notificationAboutUpTimerTick;
            notificationAboutUpTimer.Start();

            screenTimer = new DispatcherTimer();
            screenTimer.Interval = new TimeSpan(0, 1, 0);
            screenTimer.Tick += screenOnTimerTick;
            screenTimer.Start();
        }

        void SetUpIcon()
        {
            this.ni = new System.Windows.Forms.NotifyIcon();
            this.ni.Icon = new System.Drawing.Icon("Table.ico");
            this.ni.Text = "TableController";
            this.ni.Visible = true;
            this.ni.Click += IconClicked;

            this.ni.ContextMenuStrip = new System.Windows.Forms.ContextMenuStrip();
            this.ni.ContextMenuStrip.Items.Add("Open", System.Drawing.Image.FromFile("Table.ico"), IconOpenClicked);
            this.ni.ContextMenuStrip.Items.Add("Close", System.Drawing.Image.FromFile("Table.ico"), IconCloseClicked);
        }

        private void IconCloseClicked(object sender, EventArgs e)
        {
            this.Close();
        }

        private void IconOpenClicked(object sender, EventArgs e)
        {
            this.Show();
            this.WindowState = WindowState.Normal;
        }

        private void IconClicked(object sender, EventArgs e)
        {
            System.Windows.Forms.MouseEventArgs mouseEvent = (System.Windows.Forms.MouseEventArgs) e;
            if (mouseEvent.Button != System.Windows.Forms.MouseButtons.Right)
            {
                this.Show();
                this.WindowState = WindowState.Normal;
            }
        }

        private void CloseButtonClick(object sender, EventArgs e)
        {
            this.Hide();
        }

        private void btnIncTimeUp_Click(object sender, RoutedEventArgs e)
        {
            if (Properties.Settings.Default.timeUp < Properties.Settings.Default.maxTimeUp)
            {
                Properties.Settings.Default.timeUp += 1;
                saveSettings();
                displaySettings();
            }
        }

        private void btnDecTimeUp_Click(object sender, RoutedEventArgs e)
        {
            if (Properties.Settings.Default.timeUp > Properties.Settings.Default.minTimeUp)
            {
                Properties.Settings.Default.timeUp -= 1;
                saveSettings();
                displaySettings();
            }
        }

        private void btnIncTimeDown_Click(object sender, RoutedEventArgs e)
        {
            if (Properties.Settings.Default.timeDown < Properties.Settings.Default.maxTimeDown)
            {
                Properties.Settings.Default.timeDown += 1;
                saveSettings();
                displaySettings();
            }
        }

        private void btnDecTimeDown_Click(object sender, RoutedEventArgs e)
        {
            if (Properties.Settings.Default.timeDown > Properties.Settings.Default.minTimeDown)
            {
                Properties.Settings.Default.timeDown -= 1;
                saveSettings();
                displaySettings();
            }
        }

        protected override void OnStateChanged(EventArgs e)
        {
            if (WindowState == System.Windows.WindowState.Minimized)
                this.Hide();

            base.OnStateChanged(e);
        }

        protected override void OnClosing(CancelEventArgs e)
        {

            if (notification != null)
            {
                notification.Close();
            }
            this.ni.Dispose();
            allDays.Add(today);
            saveDaysInfo();            

        }

        private void notificationAboutUpTimerTick(object sender, EventArgs e)
        {
            //Show_Toast_Notification("Hello!");
            //TimeLabel.Content = (DateTime.Now - this.startTime).ToString(@"hh\:mm\:ss");
            //TimeLabel.Content = DateTime.Now.ToLongTimeString();
            currentPosition = Position.UP;
            sendNotification(currentPosition.ToString());
            notificationAboutUpTimer.Stop();
            notificationAboutDownTimer.Interval = new TimeSpan(0, Properties.Settings.Default.timeUp, 0);
            notificationAboutDownTimer.Start();
        }

        private void notificationAboutDownTimerTick(object sender, EventArgs e)
        {
            currentPosition = Position.DOWN;
            sendNotification(currentPosition.ToString());
            notificationAboutDownTimer.Stop();
            notificationAboutUpTimer.Interval = new TimeSpan(0, Properties.Settings.Default.timeDown, 0);
            notificationAboutUpTimer.Start();
        }

        private void screenOnTimerTick(object sender, EventArgs e)
        {
            if (DateTime.Now.Date.ToShortDateString() != today.Date)
            {
                handleDaySwitch(false);
            }
            today.MinutesScreenOn += 1;
            ScreenOn.Content = today.ToHoursString();
        }

        private void SystemEvents_SessionSwitch(object sender, SessionSwitchEventArgs e)
        {
            switch (e.Reason)
            {
                case SessionSwitchReason.SessionLock:
                    lockTime = DateTime.Now;
                    screenTimer.Stop();
                    notificationAboutUpTimer.Stop();
                    notificationAboutDownTimer.Stop();
                    break;
                case SessionSwitchReason.SessionUnlock:
                    unLockTime = DateTime.Now;
                    Times.Items.Add(lockTime.ToLongTimeString()
                        + " - "
                        + unLockTime.ToLongTimeString());
                    if (DateTime.Now.Date.ToShortDateString() != today.Date)
                    {
                        handleDaySwitch(true);
                    }
                    screenTimer.Start();
                    currentPosition = Position.DOWN;
                    notificationAboutUpTimer.Interval = new TimeSpan(0, Properties.Settings.Default.timeDown, 0);
                    notificationAboutUpTimer.Start();
                    break;
            }
        }


        /*void OnSleepMode(Object sender, PowerModeChangedEventArgs e)
        {
            if (e.Mode == PowerModes.Suspend)
            {
                this.lockTime = DateTime.Now;
            }
            else if (e.Mode == PowerModes.Resume)
            {
                this.unLockTime = DateTime.Now;
                Times.Items.Add(this.lockTime.ToLongTimeString()
                    + " - "
                    + this.unLockTime.ToLongTimeString());
            }
        }*/
    }
}
